% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function write(obj, File),
    if nargin < 2, File = obj.File; end
    if obj.OnWriteDestroyAllViewers, obj.destroy_all_Viewers; end
    if obj.OnWriteDestroyDuplicateTransformations, obj.destroy_duplicate_Transformations; end
    obj.Tree.write(File);
end
