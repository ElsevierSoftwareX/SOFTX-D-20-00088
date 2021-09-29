% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Update is always called when wip Project object may need to be updated
% with respect to its underlying wit Tree object.
% THIS DOES NOT SUPPORT WIP PROJECT OBJECT ARRAYS!
function wip_update_Tree(obj), %#ok
    if obj.isUpdatingTree, return; end
    obj.isUpdatingTree = true; resetOnCleanup = onCleanup(@() reset_isUpdatingTree(obj)); % Cleanup should work on user interrupts (Ctrl+C) and errors
    
    OldTree = obj.Tree;
    NewTree = OldTree.Root;
    if OldTree ~= NewTree, %#ok
        obj.Tree = NewTree;
        delete(obj.TreeObjectBeingDestroyedListener);
        delete(obj.TreeObjectModifiedListener);
        obj.TreeObjectBeingDestroyedListener = NewTree.addlistener('ObjectBeingDestroyed', @(s,e) delete(obj));
        obj.TreeObjectModifiedListener = NewTree.addlistener('ObjectModified', @(s,e) wip_update_Tree(obj));
    end
    obj.wip_update_Data();
    
    function reset_isUpdatingTree(obj), %#ok
        obj.isUpdatingTree = false;
    end
end
