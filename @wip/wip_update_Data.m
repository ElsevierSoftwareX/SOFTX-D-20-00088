% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Update is always called when wip Project object may need to be updated
% with respect to its underlying wit Tree object.
function tf = wip_update_Data(obj),
    tf = false;
    if ~obj.wip_update_Tree, return; end
    
    % Stop if no Data-tag modifications are detected
    DataTag = obj.DataTag;
    if ~isempty(obj.DataModifications) && ~isempty(DataTag) && ...
            DataTag.ModificationsLatestAt == obj.DataModificationsLatestAt && ...
            DataTag.ModificationsLatestAt.Modifications == obj.DataModifications,
        return;
    end
    
    obj.noupdate = true; % Avoid infinite recursion via get.Tree
    RootTag = obj.Tree;
    obj.noupdate = false;
    
    % Update Data-tag
    DataTag = RootTag.regexp('^Data(<WITec (Project|Data))?$', true);
    obj.DataTag = DataTag;
    
    % Update the related modification tracking variables
    if ~isempty(DataTag),
        obj.DataModificationsLatestAt = DataTag.ModificationsLatestAt;
        obj.DataModifications = DataTag.ModificationsLatestAt.Modifications;
    end
    
    % It is computationally cheaper to recreate all objects than
    % selectively recreate some of them
    Data = wid(obj);
    obj.Data = Data(:); % Force column vector
    
    % Update return flag
    tf = true;
end
