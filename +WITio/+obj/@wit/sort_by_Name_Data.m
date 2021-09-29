% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This mimics the builtin sort behaviour, but only compares the Name and
% Data properties of the wit Tree objects. This implementation ignores the
% obj array shape. The sorting order for little-endian and big-endian
% ordered machines is different.
function [obj_sorted, ind_sort] = sort_by_Name_Data(obj), %#ok
    ind_sort = sort_helper(obj);
    obj_sorted = obj(ind_sort); % Sort objects only once
    
    function ind_sort = sort_helper(obj), %#ok
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
            NamesClassesNumels{ii} = [Names{ii} Class_ii char(typecast(Numel_ii, 'uint16'))];
            if strcmp(Class_ii, 'WITio.obj.wit'), B_wit(ii) = true; end %#ok
        end

        % Sort tags by Names (1st), Classes (2nd) and Numels (3rd)
        [NamesClassesNumels, ind_sort] = sort(NamesClassesNumels); % Use built-in sort for speed!

        Numels = Numels(ind_sort);
        Datas = Datas(ind_sort);
        B_wit = B_wit(ind_sort);

        % Find possible obj duplicates
        L_unique = cumsum([true; ~strcmp(NamesClassesNumels(1:end-1), NamesClassesNumels(2:end))]); % Label unique

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
                ind_sort_ii_update = sort_helper(Children_ii(:,Numels_ii));
                for jj = Numels_ii-1:-1:1, %#ok
                    ind_sort_ii_update = ind_sort_ii_update(sort_helper(Children_ii(ind_sort_ii_update,jj)));
                end
            else, %#ok % Process non-wit
                if Numels_ii == 1, %#ok % Direct sort for scalars
                    Datas_ii = [Datas{B_ii}];
                else, %#ok % Indirect char-sort for vectors
                    Datas_ii = Datas(B_ii);
                    for jj = 1:sum_B_ii, Datas_ii{jj} = to_char_array(Datas_ii{jj}); end % Convert to char-array (to utilize crazy sort speeds!)
                end
                [~, ind_sort_ii_update] = sort(Datas_ii); % Use built-in sort for speed!
            end

            % Sort indices
            ind_sort_ii = ind_sort(B_ii);
            ind_sort(B_ii) = ind_sort_ii(ind_sort_ii_update);
        end
    end
    
    function str = to_char_array(input), %#ok
        if islogical(input), %#ok % Handle casting of logicals
            str = reshape(input, 1, []);
            if mod(numel(input), 2), str(end+1) = false; end % Append false if odd length
            str = char(typecast(uint8(str), 'uint16'));
        elseif iscell(input), %#ok
            str = cellfun(@to_char_array, reshape(input, 1, []), 'UniformOutput', false);
            str = [cellfun(@(x) char(typecast(numel(x), 'uint16')), str, 'UniformOutput', false); str]; % Append typecasted numels as delimeters with no risk of false positives
%             str(2,:) = {char(0)}; % Append (unlikely) 0-characters as delimeters with small risk of false positives
            str = [str{:}]; % Merge together
        elseif ischar(input), str = reshape(input, 1, []);
        elseif isa(input, 'uint8') || isa(input, 'int8'), %#ok % Handle casting of int8/uint8
            str = reshape(input, 1, []);
            if mod(numel(input), 2), str(end+1) = 0; end % Append 0 if odd length
            str = char(typecast(str, 'uint16'));
        else, str = char(typecast(reshape(input, 1, []), 'uint16')); end
    end
end
