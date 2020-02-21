% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This returns the owner wid-object's Id for each given wit-object. If no
% owner is found, then returns 0.
function Ids = find_owner_id_to_this_wit(O_wit),
    Ids = zeros(size(O_wit), 'int32');
    for ii = 1:numel(O_wit),
        % Find one of the owner wid-object's main wit-tree branches
        Tag_Owner = O_wit(ii).regexp_ancestors('^Data \d+<');
        % Then find its ID-tag under its TData-tag
        Tag_Id = Tag_Owner.search('ID', 'TData', {'^Data \d+$'});
        if ~isempty(Tag_Id),
            Ids(ii) = Tag_Id.Data; % Store the found ID
        end
    end
end
