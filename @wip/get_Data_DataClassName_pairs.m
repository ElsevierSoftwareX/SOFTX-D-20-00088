% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function Pairs = get_Data_DataClassName_pairs(O_wit),
    % Test the given input and gather valid tags to be added
    Pairs = wit.empty;
    for ii = 1:numel(O_wit),
        C_ii = O_wit(ii);
        % Test if the input is a parent or its child
        if isempty(regexp(C_ii.FullName, '^([^<]*<)*Data(ClassName)? \d+<Data(<WITec (Project|Data))?$', 'once')),
            % If not, then consider only the WIP/WID-formatted DataClassName and Data -pairs
            Root = [C_ii.Root];
            Tag_Data = Root.regexp('^Data(<WITec (Project|Data))?$', true);
            Tags_1 = Tag_Data.search({'^DataClassName \d+$'}, 'Data');
            Tags_2 = Tag_Data.search({'^Data \d+$'}, 'Data');
            strs_1 = strrep({Tags_1.Name}, 'DataClassName ', '');
            strs_2 = strrep({Tags_2.Name}, 'Data ', '');
            [strs_1, ind_sort1] = sort(strs_1);
            Tags_1 = Tags_1(ind_sort1);
            [strs_2, ind_sort2] = sort(strs_2);
            Tags_2 = Tags_2(ind_sort2);
            % Parse the pairs
            jj_match = 1;
            for jj = 1:numel(strs_1),
                str_1_jj = strs_1{jj};
                while jj_match < numel(strs_2),
                    if strcmp(str_1_jj, strs_2{jj_match}),
                        Pairs(end+1,:) = [Tags_1(jj) Tags_2(jj_match)];
                        break;
                    end
                    jj_match = jj_match + 1;
                end
            end
        else, % Continue here if the input is a parent or its child
            % Step up the tree until one of the tag pairs if found
            while isempty(regexp(C_ii.Name, '^Data(ClassName)? \d+$', 'once')),
                C_ii = C_ii.Parent;
            end
            % Construct the search strings
            str_2 = strrep(C_ii.Name, 'ClassName', ''); % Data <number>
            str_1 = strrep(str_2, 'Data', 'DataClassName'); % DataClassName <number>
            % Search for the specified Data and DataClassName
            Tag_Data = C_ii.Parent;
            Tag_1 = Tag_Data.search(str_1, 'Data'); % DataClassName <number>
            Tag_2 = Tag_Data.search(str_2, 'Data'); % Data <number>
            % Create a tag pair
            if ~isempty(Tag_1) && ~isempty(Tag_2),
                Pairs(end+1,:) = [Tag_1 Tag_2];
            end
        end
    end

    % Remove duplicates
    Pairs = unique(Pairs, 'rows');
end
