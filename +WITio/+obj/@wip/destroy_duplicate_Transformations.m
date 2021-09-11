% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Destroys all duplicate Transformations that ONLY differ in their TData.
function destroy_duplicate_Transformations(obj),
    for ii = 1:numel(obj),
        O_wid = obj(ii).Data;
        Types = {O_wid.Type};

        % Keep only the transformations
        B_T = ~cellfun(@isempty, regexp(Types, 'Transformation$', 'once'));
        O_wid = O_wid(B_T);
        inds = 1:numel(O_wid);
        Tags = [O_wid.Tag];
        Tags_DataClassNames = [Tags.DataClassName]; % Skip major redundancy by avoiding implicit DataTree_get!
        DataClassNames = {Tags_DataClassNames.Data};
        DataClassNames_unique = unique(DataClassNames);
        Tags_Datas = [Tags.Data]; % Skip major redundancy by avoiding implicit DataTree_get!
        first_at = zeros(size(inds));
        B_unique = false(size(inds));
        for jj = 1:numel(DataClassNames_unique), % Look through different kinds of transformations
            DataClassNames_unique_jj = DataClassNames_unique{jj};
            B_jj = strcmp(DataClassNames, DataClassNames_unique_jj);
            inds_jj = inds(B_jj);
            Tags_Datas_jj = Tags_Datas(B_jj).search_children(DataClassNames_unique_jj);
            [~, ia, ic] = Tags_Datas_jj.unique_by_Name_Data(); % Find duplicates
            first_at(B_jj) = inds_jj(ia(ic));
            B_unique(inds_jj(ia)) = true;
        end
        
        % Stop if no duplicates were found
        if all(B_unique), return; end
        
        % List all the project's ID-tags (except NextDataID, ServiceID, LicenseID, LastApplicationSessionIDs and ID<TData)
        tags = obj(ii).Tree.regexp_all_Names('^(?!NextDataID|ServiceID|LicenseID|LastApplicationSessionIDs).+ID(List)?$');
        tags_Ids = {tags.Data};
        Ids_all_old = double(unique([tags_Ids{:}]));
        
        % Create sparse map from old Ids to new Ids
        Ids = [O_wid.Id];
        Ids_old = Ids(~B_unique);
        Ids_new = Ids(first_at(~B_unique));
        S = sparse(Ids_all_old+1, ones(size(Ids_all_old)), Ids_all_old);
        S(Ids_old+1) = Ids_new;
        
        % Update the Ids
        for jj = 1:numel(tags_Ids),
            tags_Ids{jj} = int32(full(S(tags_Ids{jj}+1)));
        end
        
        delete_siblings(O_wid(~B_unique));
    end
end
