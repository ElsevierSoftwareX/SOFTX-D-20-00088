% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Update is always called when wip Project object may need to be updated
% with respect to its underlying wit Tree object.
function wip_update_Tree(obj),
    if obj.isUpdatingTree, return; end
    obj.isUpdatingTree = true;
    OldTree = obj.Tree;
    NewTree = OldTree.Root;
    if OldTree ~= NewTree,
        obj.Tree = NewTree;
        delete(obj.TreeObjectBeingDestroyedListener);
        delete(obj.TreeObjectModifiedListener);
        obj.TreeObjectBeingDestroyedListener = NewTree.addlistener('ObjectBeingDestroyed', @(s,e) delete(obj));
        obj.TreeObjectModifiedListener = NewTree.addlistener('ObjectModified', @(s,e) wip_update_Tree(obj));
    end
    obj.wip_update_Data();
    obj.isUpdatingTree = false;
end
