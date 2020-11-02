% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Returns valid DataClassName/Data-pairs of wit Tree objects. Second output
% denotes how many Roots were accessed during this scan.
function [Pairs, Roots] = get_Data_DataClassName_pairs(O_wit),
    Pairs = wit.empty;
    if isempty(O_wit),
        Roots = wit.empty;
        return; % Stop for empty input
    end
    
    % Collect roots and tags for pairs
    Roots = wit.empty;
    Tags_1 = wit.empty;
    Tags_2 = wit.empty;
    for ii = 1:numel(O_wit),
        % Get wit Tree object
        O_wit_ii = O_wit(ii);
        
        % Append its Root to Roots if not present
        Root_ii = O_wit_ii.Root;
        if all(Roots ~= Root_ii), Roots(end+1) = Root_ii; end
        
        % Move down/up within the wit Tree object tree-structure
        if isempty(regexp(O_wit_ii.FullName, '^([^<]*<)*Data(ClassName)? \d+(<Data(<WITec (Project|Data))?)?$', 'once')),
            % Step down to get content of the main Data-tag (if it exists)
            O_wit_ii = O_wit_ii.regexp('^Data(<WITec (Project|Data))$', true);
            [Tags_1_ii, Tags_2_ii] = O_wit_ii.regexp_children('^DataClassName \d+$', '^Data \d+$');
            Tags_1 = [Tags_1 Tags_1_ii];
            Tags_2 = [Tags_2 Tags_2_ii];
        else,
            % Step up to get one of the pairs
            while isempty(regexp(O_wit_ii.Name, '^Data(ClassName)? \d+$', 'once')),
                O_wit_ii = [O_wit_ii.Parent wit.empty];
            end
            if strncmp(O_wit_ii.Name, 'DataClassName', 13), Tags_1(end+1) = O_wit_ii;
            else, Tags_2(end+1) = O_wit_ii; end
        end
    end
    
    % Parse valid pairs
    strs_1 = strrep({Tags_1.Name}, 'DataClassName ', '');
    strs_2 = strrep({Tags_2.Name}, 'Data ', '');
    N_strs_1 = numel(strs_1);
    N_strs_2 = numel(strs_2);
    [strs_1, jj2ind] = sort(strs_1);
    [strs_2, kk2ind] = sort(strs_2);
    kk = 1;
    for jj = 1:N_strs_1,
        while kk <= N_strs_2,
            if strcmp(strs_1{jj}, strs_2{kk}),
                Pairs(end+1,:) = [Tags_1(jj2ind(jj)) Tags_2(kk2ind(kk))];
                break;
            end
            kk = kk + 1;
        end
    end
    
    % Remove duplicates
    Pairs = unique(Pairs, 'rows');
end
