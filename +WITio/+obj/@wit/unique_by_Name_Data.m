% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This mimics the builtin unique behaviour, but only compares the Name and
% Data properties of the wit Tree objects. This implementation ignores the
% obj array shape. The sorting order for little-endian and big-endian
% ordered machines is different. This function has 4th output, which allows
% sorting of original input. This is nearly as fast as the sort method.
function [obj_unique, ind_in, ind_out, ind_sort] = unique_by_Name_Data(obj), %#ok
    [ind_out, ind_sort, B_unique] = unique_helper(obj);
    
    % Finalize
    ind_in = reshape(ind_sort(B_unique), [], 1); % Force column like built-in unique
    obj_unique = obj(ind_in); % Partial sort objects only once
    
    function [L_unique, ind_sort, B_unique] = unique_helper(obj), %#ok
        N_obj = numel(obj);
        Names = {obj.NameNow}; % This is faster than direct indexing of objects
        Datas = {obj.DataNow}; % This is faster than direct indexing of objects
        Numels = zeros(N_obj, 1);
        NamesClassesNumels = cell(N_obj, 1);
        B_wit = false(N_obj, 1);
        for ii = 1:N_obj, %#ok
            Data_ii = Datas{ii};
            Numel_ii = numel(Data_ii);
            Class_ii = class(Data_ii);
            Numels(ii) = Numel_ii;
            NamesClassesNumels{ii} = [Names{ii} Class_ii char(typecast(Numel_ii, 'uint8'))];
            if strcmp(Class_ii, 'WITio.obj.wit'), B_wit(ii) = true; end %#ok
        end

        % Sort tags by Names (1st), Classes (2nd) and Numels (3rd)
        [NamesClassesNumels, ind_sort] = sort(NamesClassesNumels); % Use built-in sort for speed!

        Numels = Numels(ind_sort);
        Datas = Datas(ind_sort);
        B_wit = B_wit(ind_sort);

        % Find possible obj duplicates
        B_unique = [true; ~strcmp(NamesClassesNumels(1:end-1), NamesClassesNumels(2:end))];
        L_unique = cumsum(B_unique); % Label unique

        % Loop through possible duplicates
        for ii = 1:L_unique(end), %#ok
            B_ii = L_unique == ii;
            sum_B_ii = sum(B_ii);
            if sum_B_ii <= 1, continue; end % Skip if not many
            
            ind_ii_first = find(B_ii, 1, 'first');
            
            Numels_ii = Numels(ind_ii_first);
            if Numels_ii == 0, continue; end % Skip if empty
            
            if B_wit(ind_ii_first), %#ok % Process wit
                Children_ii = vertcat(Datas{B_ii}); % wit Tree object arrays are always row vectors
                ind_link_ii = zeros(size(Children_ii));
%                 [ind_link_ii(:,Numels_ii), ind_sort_ii_update] = unique_helper(Children_ii(:,Numels_ii));
%                 for jj = Numels_ii-1:-1:1, %#ok
%                     [ind_link_ii(ind_sort_ii_update,jj), ind_sort_ii_update] = unique_helper(Children_ii(ind_sort_ii_update,jj));
%                     ind_sort_ii_update = ind_sort_ii_update(ind_sort_ii_update);
%                 end
%                 ind_link_ii_sorted = ind_link_ii(ind_sort_ii_update,:);
                for jj = Numels_ii:-1:1, %#ok
                    ind_link_ii(:,jj) = unique_helper(Children_ii(:,jj));
                end
                
                % Use built-in sortrows for speed!
                [ind_link_ii_sorted, ind_sort_ii_update] = sortrows(ind_link_ii);
                
                % Indirect label comparison
                B_cmp_neighbour_ii = any(diff(ind_link_ii_sorted, 1, 1), 2);
            else, %#ok % Process non-wit
                if Numels_ii == 1, %#ok % Direct sort for scalars
                    Datas_ii = vertcat(Datas{B_ii});
                else, %#ok % Indirect char-sort for vectors
                    Datas_ii = reshape(Datas(B_ii), [], 1); % Force column
                    for jj = 1:sum_B_ii, Datas_ii{jj} = to_char_array(Datas_ii{jj}); end % Convert to char-array (to utilize crazy sort speeds!)
                end

                % Use built-in sort for speed!
                [Datas_ii_sorted, ind_sort_ii_update] = sort(Datas_ii);

                if Numels_ii(1) == 1, %#ok % Direct comparison for scalars
                    B_cmp_neighbour_ii = Datas_ii_sorted(1:end-1) ~= Datas_ii_sorted(2:end);
                else, %#ok % Indirect char array comparison for vectors
                    B_cmp_neighbour_ii = ~strcmp(Datas_ii_sorted(1:end-1), Datas_ii_sorted(2:end));
                end
            end

            % Update uniques
            B_unique(B_ii) = [true; B_cmp_neighbour_ii];

            % Sort indices
            ind_sort_ii = ind_sort(B_ii);
            ind_sort(B_ii) = ind_sort_ii(ind_sort_ii_update);
        end
        
        % Finalize
        L_unique = cumsum(B_unique(:)); % Update label
        L_unique(ind_sort) = L_unique; % Unsort
    end
    
    function str = to_char_array(input), %#ok
        if islogical(input), str = char(uint8(reshape(input, 1, []))); %#ok % Handle casting of logicals
        elseif iscell(input), %#ok
            str = cellfun(@to_char_array, reshape(input, 1, []), 'UniformOutput', false);
            str = [cellfun(@(x) char(typecast(numel(x), 'uint8')), str, 'UniformOutput', false); str]; % Append typecasted numels as delimeters with no risk of false positives
%             str(2,:) = {char(0)}; % Append (unlikely) 0-characters as delimeters with small risk of false positives
            str = [str{:}]; % Merge together
        elseif ischar(input), str = reshape(input, 1, []);
        else, str = char(typecast(reshape(input, 1, []), 'uint8')); end
    end
end
