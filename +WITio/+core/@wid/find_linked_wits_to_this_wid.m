% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This returns the linked wit-objects pointing directly to the provided
% wid-objects.
function O_wit = find_linked_wits_to_this_wid(obj),
    O_wit = WITio.core.wit.empty;
    for ii = 1:numel(obj),
        if isfield(obj(ii).Tag, 'Data'),
            % Get the parent tag of the wid-object's wit-tree branches
            tags = [obj(ii).Tag.Data.Parent WITio.core.wit.empty];
            % List all the project's ID-tags (except NextDataID and
            % ID<TData) under the Data-tag
            tags = tags.regexp('^(?!NextDataID)([^<]+ID(List)?(<[^<]*)*(<Data(<WITec (Project|Data))?)?$)');
            % Keep only those ID-tags that point directly to this object
            O_wit = [O_wit tags.match_by_Data_criteria(@(x) any(x == obj.Id))];
        end
    end
end
