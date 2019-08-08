% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function destroy(obj, skipParent),
    if nargin < 2, skipParent = false; end % Do not skip the first parents
    for ii = 1:numel(obj),
        if ~obj(ii).isvalid, continue; end % Skip deleted
        % Delete this object from the parent
        Parent_ii = obj(ii).Parent;
        if ~skipParent && ~isempty(Parent_ii),
            Parent_ii.Data = Parent_ii.Data(Parent_ii.Data ~= obj(ii));
        end
        % Delete the children of this object and skip further parents
        destroy(obj(ii).Children, true);
    end
    delete(obj);
end
