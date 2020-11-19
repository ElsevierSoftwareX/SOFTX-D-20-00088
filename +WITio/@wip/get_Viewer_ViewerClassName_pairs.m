% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Returns valid ViewerClassName/Viewer-pairs of wit Tree objects. Second
% output denotes how many Roots were accessed during this scan.
function [Pairs, Roots] = get_Viewer_ViewerClassName_pairs(O_wit),
    Pairs = WITio.wit.empty;
    if isempty(O_wit),
        Roots = WITio.wit.empty;
        return; % Stop for empty input
    end
    
    % Collect roots and tags for pairs
    Roots = WITio.wit.empty;
    Tags_1 = WITio.wit.empty;
    Tags_2 = WITio.wit.empty;
    for ii = 1:numel(O_wit),
        % Get wit Tree object
        O_wit_ii = O_wit(ii);
        
        % Append its Root to Roots if not present
        Root_ii = O_wit_ii.Root;
        if all(Roots ~= Root_ii), Roots(end+1) = Root_ii; end
        
        % Move down/up within the wit Tree object tree-structure
        if isempty(regexp(O_wit_ii.FullName, '^([^<]*<)*Viewer(ClassName)? \d+(<Viewer(<WITec (Project|Data))?)?$', 'once')),
            % Step down to get content of the main Viewer-tag (if it exists)
            O_wit_ii = O_wit_ii.regexp('^Viewer(<WITec (Project|Data))$', true);
            [Tags_1_ii, Tags_2_ii] = O_wit_ii.regexp_children('^ViewerClassName \d+$', '^Viewer \d+$');
            Tags_1 = [Tags_1 Tags_1_ii];
            Tags_2 = [Tags_2 Tags_2_ii];
        else,
            % Step up to get one of the pairs
            while isempty(regexp(O_wit_ii.Name, '^Viewer(ClassName)? \d+$', 'once')),
                O_wit_ii = [O_wit_ii.Parent WITio.wit.empty];
            end
            if strncmp(O_wit_ii.Name, 'ViewerClassName', 15), Tags_1(end+1) = O_wit_ii;
            else, Tags_2(end+1) = O_wit_ii; end
        end
    end
    
    % Parse valid pairs
    strs_1 = strrep({Tags_1.Name}, 'ViewerClassName ', '');
    strs_2 = strrep({Tags_2.Name}, 'Viewer ', '');
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
