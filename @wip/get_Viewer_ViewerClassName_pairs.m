% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Returns valid ViewerClassName/Viewer-pairs of wit Tree objects only if
% there is only one common Root! Otherwise, returns all empty.
function [Pairs, Root] = get_Viewer_ViewerClassName_pairs(O_wit),
    Pairs = wit.empty;
    % Continue only if the wit Tree object array has one common Root
    Root = wit.empty;
    if isempty(O_wit), return; end % Stop for empty input
    for ii = 1:numel(O_wit),
        if isempty(Root), Root = O_wit(ii).Root;
        elseif Root ~= O_wit(ii).Root,
            Root = wit.empty;
            return;
        end
    end
    % Continue only if the wit Tree object array has a valid Viewer-tag
    Tag_Viewer = Root.regexp('^Viewer(<WITec (Project|Data))?$', true);
    if isempty(Tag_Viewer),
        return;
    end
    % Collect valid pairs
    for ii = 1:numel(O_wit),
        O_wit_ii = O_wit(ii);
        % Test if the input is a parent or its child
        if isempty(regexp(O_wit_ii.FullName, '^([^<]*<)*Viewer(ClassName)? \d+<Viewer(<WITec (Project|Data))?$', 'once')),
            % If not, then consider only the WIP/WID-formatted ViewerClassName and Viewer -pairs
            Tags_1 = Tag_Viewer.search({'^ViewerClassName \d+$'}, 'Viewer');
            Tags_2 = Tag_Viewer.search({'^Viewer \d+$'}, 'Viewer');
            strs_1 = strrep({Tags_1.Name}, 'ViewerClassName ', '');
            strs_2 = strrep({Tags_2.Name}, 'Viewer ', '');
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
            while isempty(regexp(O_wit_ii.Name, '^Viewer(ClassName)? \d+$', 'once')),
                O_wit_ii = O_wit_ii.Parent;
            end
            % Construct the search strings
            str_2 = strrep(O_wit_ii.Name, 'ClassName', ''); % Viewer <number>
            str_1 = strrep(str_2, 'Viewer', 'ViewerClassName'); % ViewerClassName <number>
            % Search for the specified Viewer and ViewerClassName
            Tag_1 = Tag_Viewer.search(str_1, 'Viewer'); % ViewerClassName <number>
            Tag_2 = Tag_Viewer.search(str_2, 'Viewer'); % Viewer <number>
            % Create a tag pair
            if ~isempty(Tag_1) && ~isempty(Tag_2),
                Pairs(end+1,:) = [Tag_1 Tag_2];
            end
        end
    end

    % Remove duplicates
    Pairs = unique(Pairs, 'rows');
end
