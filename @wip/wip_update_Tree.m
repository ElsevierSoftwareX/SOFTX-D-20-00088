% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Update is always called when wip Project object may need to be updated
% with respect to its underlying wit Tree object.
function tf = wip_update_Tree(obj),
    tf = false;
    if obj.noupdate, return; end
    
    obj.noupdate = true; % Avoid infinite recursion via get.Tree
    RootTag = obj.Tree;
    obj.noupdate = false;
    
    % Stop if RootTag is invalid or deleted!
    try,
        RootModificationsLatestAt = RootTag.ModificationsLatestAt;
        RootModifications = RootModificationsLatestAt.Modifications;
    catch, % Above errors only if RootTag is invalid or deleted!
        delete(obj);
        return;
    end
    
    % Stop if no Root-tag modifications are detected
    if ~isempty(obj.RootModifications) && ...
            RootModificationsLatestAt == obj.RootModificationsLatestAt && ...
            RootModifications == obj.RootModifications,
        return;
    end
    
    % Update wit Tree object to its root
    RootTag = RootTag.Root;
    obj.Tree = RootTag;
    
    % Update the related modification tracking variables
    obj.RootModificationsLatestAt = RootTag.ModificationsLatestAt;
    obj.RootModifications = RootTag.ModificationsLatestAt.Modifications;
    
    % Update return flag
    tf = true;
end
