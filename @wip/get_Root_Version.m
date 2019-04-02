% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Return empty if no Version is found
function Version = get_Root_Version(obj) % Can be wid-, wip- or wit-class
    Version = []; % If not found
    if ~isempty(obj),
        C_wit = wit.Empty; 
        if isa(obj, 'wit'), C_wit = obj;
        elseif isa(obj, 'wid'), C_wit = obj.Tag.Root;
        elseif isa(obj, 'wip'), C_wit = obj.Tree; end
        if ~isempty(C_wit), % Test if a tree exists
            Version_tag = C_wit.Root.search('Version', {'WITec (Project|Data)'});
            if ~isempty(Version_tag), % Test if a Version-tag was found
                Version = Version_tag.Data;
            end
        end
    end
end
