% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function destroy(obj, skipParent),
    if nargin < 2, skipParent = false; end % Do not skip the first parents
    for ii = 1:numel(obj),
        try,
            % Delete this object from the parent
            if ~skipParent,
                Parent_ii = obj(ii).Parent;
                if ~isempty(Parent_ii),
                    Parent_ii.Data = Parent_ii.Data(Parent_ii.Data ~= obj(ii));
                end
            end

            % Delete the children of this object and skip further parents
            destroy(obj(ii).Children, true);
        catch,
            % Do nothing if i.e. isvalid(obj(ii)) == false, which is not
            % Octave-compatible function.
        end
    end
    delete(obj);
end
