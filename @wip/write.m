% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function write(obj, File),
    if nargin < 2, File = obj.File; end
    if obj.OnWriteRemoveViewers, obj.reset_Viewers; end
    if obj.OnWriteRemoveDuplicateTransformations, obj.destroy_duplicate_Transformations; end
    obj.Tree.write(File);
end
