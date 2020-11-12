% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Update is always called when wip Project object may need to be updated
% with respect to its underlying wit Tree object.
function wip_update_Tree(obj),
    OldTree = obj.Tree;
    NewTree = OldTree.Root;
    if OldTree ~= NewTree,
        obj.Tree = NewTree;
        delete(obj.TreeObjectModifiedListener);
        obj.TreeObjectModifiedListener = NewTree.addlistener('ObjectModified', @() wip_update_Tree(obj));
        obj.wip_update_Data();
    end
end
