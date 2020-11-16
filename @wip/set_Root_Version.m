% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Set Version if found
function set_Root_Version(obj, Version) % Can be wid-, wip- or wit-class
    if ~isempty(obj),
        O_wit = wit.io.wit.empty; 
        if isa(obj, 'wit.io.wit'), O_wit = obj;
        elseif isa(obj, 'wid'), O_wit = obj.Tag.Root;
        elseif isa(obj, 'wip'), O_wit = obj.Tree; end
        if ~isempty(O_wit), % Test if a tree exists
            Version_tag = O_wit.Root.search('Version', {'WITec (Project|Data)'});
            if ~isempty(Version_tag), % Test if a Version-tag was found
                Version_tag.Data = int32(Version);
            end
        end
    end
end
