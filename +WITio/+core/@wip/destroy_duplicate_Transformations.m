% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Destroys all duplicate Transformations that ONLY differ in their TData.
function destroy_duplicate_Transformations(obj),
    O_wid = obj.Data;
    Types = {O_wid.Type};
    
    % Keep only the transformations
    B_T = ~cellfun(@isempty, regexp(Types, 'Transformation$', 'once'));
    O_wid = O_wid(B_T);
    Types = Types(B_T);
    inds = 1:numel(O_wid);
    Datas = {O_wid.Data};
    
    % Loop through the transformations
    B_destroyed = false(1, numel(O_wid));
    for ii = inds,
        if B_destroyed(ii), continue; end % Skip if already destroyed
        B_next = inds > ii & ~B_destroyed;
        B_next(B_next) = strcmp(Types(B_next), Types{ii});
        inds_next = find(B_next);
        for jj = 1:numel(inds_next),
            ind_jj = inds_next(jj);
            if isequal_nested_structs(Datas{ii}, Datas{ind_jj}),
                linked_tags = WITio.core.wid.find_linked_wits_to_this_wid(O_wid(ind_jj));
                for nn = 1:numel(linked_tags),
                    linked_tags(nn).Data(linked_tags(nn).Data == O_wid(ind_jj).Id) = O_wid(ii).Id;
                end
                delete(O_wid(ind_jj));
                B_destroyed(ind_jj) = true;
            end
        end
    end
    
    function tf = isequal_nested_structs(A, B),
        tf = false;
        if isstruct(A) == false && isstruct(B) == false,
            tf = isequal(A, B);
            return; % Exit if both are not structs
        elseif isstruct(A) == false || isstruct(B) == false,
            return; % Exit if either is not struct
        end
        A_fields = fieldnames(A);
        A_values = struct2cell(A);
        B_fields = fieldnames(B);
        B_values = struct2cell(B);
        if numel(A_fields) ~= numel(B_fields) || ...
            numel(A_values) ~= numel(B_values),
            return;
        end
        for cc = 1:numel(A_fields),
            if ~strcmp(A_fields{cc}, B_fields{cc}) || ...
                    ~isequal_nested_structs(A_values{cc}, B_values{cc}),
                return;
            end
        end
        tf = true;
    end
end
