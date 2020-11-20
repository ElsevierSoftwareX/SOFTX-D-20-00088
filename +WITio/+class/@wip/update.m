% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Call update when Project Data needs to be updated according to its Tree.
function update(obj),
    % Check consistency of wid with wit and update wid accordingly

    % First find all the Data tags in the WIT-tree
    Tree_Data_tag = obj.Tree.regexp('^Data(<WITec (Project|Data))?$', true);
    N_Tree = Tree_Data_tag.search('NumberOfData', 'Data').Data;
    Tree_Data_tags = Tree_Data_tag.regexp('^Data \d+(<Data(<WITec (Project|Data))?)?$');

    % Then find all the Data tags in the obj.Data
    N_Data = numel(obj.Data);
    Data_Tags_struct = [obj.Data.Tag];
    Data_Data_tags = [Data_Tags_struct.Data];

    % Then match same handles
    bw = false(N_Tree, N_Data);
    for ii = 1:N_Tree,
        for jj = 1:N_Data,
            if Tree_Data_tags(ii) == Data_Data_tags(jj), % Test if SAME HANDLE
                bw(ii,jj) = true;
                break; % To remove possible duplicates in obj.Data
            end
        end
    end
    bw_Tree = any(bw, 2); % False = add a missing Tree tag as a new Data object
    bw_Data = any(bw, 1); % True = keep a Data object

    % Remove duplicates and add missing Tree objects
    obj.Data = [obj.Data(bw_Data); WITio.class.wid(Tree_Data_tags(~bw_Tree))];
end
