% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Return empty if no Version is found
% THIS DOES NOT SUPPORT WIP PROJECT OBJECT ARRAYS!
function Version = get_Root_Version(obj) % Can be wid-, wip- or wit-class
    Version = []; % If not found
    if ~isempty(obj),
        O_wit = WITio.obj.wit.empty; 
        if isa(obj, 'WITio.obj.wit'), O_wit = obj;
        elseif isa(obj, 'WITio.obj.wid'), O_wit = obj.Tag.Root;
        elseif isa(obj, 'WITio.obj.wip'), O_wit = obj.Tree; end
        if ~isempty(O_wit), % Test if a tree exists
            Version_tag = O_wit.Root.search('Version', {'WITec (Project|Data)'});
            if ~isempty(Version_tag), % Test if a Version-tag was found
                Version = Version_tag.Data;
            end
        end
    end
end
