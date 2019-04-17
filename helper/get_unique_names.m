% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Mimics matlab.lang.makeUniqueStrings(strs, true(size(strs)), maxStringLength) behaviour, missing before R2014a
function strs = get_unique_names(strs, maxStringLength)
    if nargin < 2, maxStringLength = namelengthmax; end
    if iscell(strs) && ~isempty(strs),
        % Truncate strs if too long
        for ii = 1:numel(strs), strs{ii} = strs{ii}(1:min(numel(strs{ii}), maxStringLength)); end
%         strs = regexprep(strs, sprintf('^(.{0,%d}).*$', maxStringLength), '$1'); % The length of the character vector is less than or equal to maxStringLength.
        
        % Work with sorted strs
        [strs_sorted, ind_sorted] = sort(strs);
        N = numel(strs_sorted);
        
        % Construct group strings
        ind_to_group = zeros(size(strs_sorted));
        group_str = strs_sorted(1);
        group_counter = 1;
        group_first = true;
        ind_to_group(1) = 1;
        N_groups = 1;
        bw_match_previous = strcmp(strs_sorted(1:end-1), strs_sorted(2:end)); % Vectorized
        for ii = 2:N,
            % Add new group
            bw_match_previous_group = bw_match_previous(ii-1); % strcmp(group_str{end}, strs_sorted{ii});
            if ~bw_match_previous_group || ... % If no match with previous group
                    group_first(end), % If match with previous group but not first
                group_first(end+1) = ~bw_match_previous_group;
                group_str{end+1} = strs_sorted{ii};
                group_counter(end+1) = 1;
                N_groups = N_groups + 1;
            % Otherwise append to old group
            else, group_counter(end) = group_counter(end) + 1; end
            ind_to_group(ii) = N_groups;
        end
        
        % Parse group counters (> 0) and truncate
        counters = zeros(size(strs_sorted));
        bw_lock = false(size(strs_sorted)); % Needed to avoid modifications of locked counters
        for ii = 1:N_groups,
            if group_first(ii), % Parse only if first
                bw = ind_to_group == ii;
                str = group_str{ii};
                str_truncated = regexprep(str, '^(.*)_[0-9]+$', '$1');
                % Parse counter
                str_counter = str(numel(str_truncated)+2:end); % Counter str without underscore '_'
                counters(bw) = sum((str_counter-'0').*10.^(numel(str_counter)-1:-1:0)); % ASCII integer to number
                if counters(bw) > 0, % Update group str only if non-zero counter was found
                    group_str{ii} = str_truncated;
                    bw_lock(bw) = true;
                end
            end
        end
        
        % Assign element counters one group at the time
        for ii = 1:N_groups,
            if group_first(ii), continue; end
            % Loop until there are no duplicates OR error
            while true,
                str = group_str{ii};
                N_str = numel(str);
                
                % Match with the previous groups
                ind_match_ii = find(strcmp(group_str, str));

                % Find their elements
                bw_same_ii = ind_to_group == ii;
                bw_same = false(size(bw_same_ii));
                for jj = ind_match_ii, bw_same = bw_same | ind_to_group == jj; end
                
                % Generate unique counters (except locked)
                locked_counters = counters(bw_same & bw_lock); % Already sorted
                sp_locked = sparse(locked_counters,ones(size(locked_counters)),ones(size(locked_counters)), numel(locked_counters)+sum(bw_same_ii), 1);
                counters(bw_same_ii) = find(~sp_locked, sum(bw_same_ii));
                
                % Find if group str should be truncated
                truncate = min([0 maxStringLength-(N_str+floor(log10(counters(bw_same_ii)))+2)]);

                % Stop if no truncation is needed
                if truncate == 0,
                    bw_lock(ind_to_group == ii) = true; % Lock these numbers
                    break;
                end
                
                % Error if group str becomes too short
                N_str = N_str + truncate;
                if N_str < 1,
                    error('Combination of input arguments cannot be made unique.');
                end
                
                % Truncate group str
                group_str{ii} = str(1:N_str);
            end
        end
        
        % Convert counters to str array
        bw_zero = counters == 0;
        N_digits = ceil(log10(counters+1));
        N_digits_max = max(N_digits);
        counter_digits = zeros(numel(counters), N_digits_max);
        for jj = size(counter_digits, 2):-1:1,
           counter_digits(:,jj) = mod(counters(:), 10);
           counters(:) = (counters(:) - counter_digits(:,jj))./10;
        end
        str_counter = char(counter_digits + '0');
        
        % Construct unique strings
        for ii = 1:N,
            if bw_zero(ii), strs_sorted{ii} = group_str{ind_to_group(ii)};
            else, strs_sorted{ii} = [group_str{ind_to_group(ii)} '_' str_counter(ii,N_digits_max-N_digits(ii)+1:end)]; end % Faster than dec2base or sprintf
%             else, strs_sorted{ii} = [group_str{ind_to_group(ii)} '_' dec2base(counters(ii), 10)]; end
%             else, strs_sorted{ii} = sprintf('%s_%d', group_str{ind_to_group(ii)}, counters(ii)); end
        end
        
        % Restore original unsorted order
        strs(ind_sorted) = strs_sorted;
    else, strs = strs(1:min(numel(strs), maxStringLength)); end % Truncate
end
