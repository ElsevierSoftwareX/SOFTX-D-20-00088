% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Update is always called when wip Project object may need to be updated
% with respect to its underlying wit Tree object.
function wip_update_Data(obj, isObjectBeingDestroyed),
    if nargin < 2, isObjectBeingDestroyed = false; end

    % CASE: Data-tag is being destroyed
    if isObjectBeingDestroyed,
        delete(obj.DataObjectBeingDestroyedListener);
        delete(obj.DataObjectModifiedListener);
        obj.TreeData = wit.empty;
        obj.TreeDataModifiedCount = [];
        obj.DataObjectBeingDestroyedListener = [];
        obj.DataObjectModifiedListener = [];
        obj.Data = wid.empty;
        return;
    end
    
    % OTHERWISE: Update Data-tag
    TreeData = obj.TreeData;
    if isempty(TreeData),
        TreeData = obj.Tree.regexp('^Data(<WITec (Project|Data))?$', true);
        if isempty(TreeData),
            delete(obj.DataObjectBeingDestroyedListener);
            delete(obj.DataObjectModifiedListener);
            obj.TreeData = wit.empty;
            obj.TreeDataModifiedCount = [];
            obj.DataObjectBeingDestroyedListener = [];
            obj.DataObjectModifiedListener = [];
            obj.Data = wid.empty;
        else,
            delete(obj.DataObjectBeingDestroyedListener);
            delete(obj.DataObjectModifiedListener);
            obj.TreeData = TreeData;
            obj.TreeDataModifiedCount = TreeData.ModifiedCount;
            obj.DataObjectBeingDestroyedListener = TreeData.addlistener('ObjectBeingDestroyed', @(s,e) wip_update_Data(obj, true));
            obj.DataObjectModifiedListener = TreeData.addlistener('ObjectModified', @(s,e) wip_update_Data(obj));
            obj.Data = reshape(wid(obj), [], 1); % Force column vector
        end
        return;
    else,
        MC = TreeData.ModifiedCount;
        if MC == obj.TreeDataModifiedCount,
            return; % Do nothing
        end
        MDI = TreeData.ModifiedDescendantIndices;
        MDP = TreeData.ModifiedDescendantProperty;
        MDM = TreeData.ModifiedDescendantMeta; % Use this to determine exactly which objects were added and which removed
        if numel(MDI) == 0, % Continue if Data-tag has been directly modified
            if strcmp(MDP, 'Parent'),
                TreeData = obj.Tree.regexp('^Data(<WITec (Project|Data))?$', true);
                if isempty(TreeData),
                    delete(obj.DataObjectBeingDestroyedListener);
                    delete(obj.DataObjectModifiedListener);
                    obj.TreeData = wit.empty;
                    obj.TreeDataModifiedCount = [];
                    obj.DataObjectBeingDestroyedListener = [];
                    obj.DataObjectModifiedListener = [];
                    obj.Data = wid.empty;
                else,
                    delete(obj.DataObjectBeingDestroyedListener);
                    delete(obj.DataObjectModifiedListener);
                    obj.TreeData = TreeData;
                    obj.TreeDataModifiedCount = MC;
                    obj.DataObjectBeingDestroyedListener = TreeData.addlistener('ObjectBeingDestroyed', @(s,e) wip_update_Data(obj, true));
                    obj.DataObjectModifiedListener = TreeData.addlistener('ObjectModified', @(s,e) wip_update_Data(obj));
                    obj.Data = reshape(wid(obj), [], 1); % Force column vector
                end
            elseif strcmp(MDP, 'Children'), % New child added (and maybe children removed)
                obj.Data = reshape(wid(obj), [], 1); % Force column vector
            elseif strcmp(MDP, 'Data'), % Data-tag becomes invalid
                delete(obj.DataObjectBeingDestroyedListener);
                delete(obj.DataObjectModifiedListener);
                obj.TreeData = wit.empty;
                obj.TreeDataModifiedCount = [];
                obj.DataObjectBeingDestroyedListener = [];
                obj.DataObjectModifiedListener = [];
                obj.Data = wid.empty;
            elseif strcmp(MDP, 'Name'), % Data-tag becomes invalid
                delete(obj.DataObjectBeingDestroyedListener);
                delete(obj.DataObjectModifiedListener);
                obj.TreeData = wit.empty;
                obj.TreeDataModifiedCount = [];
                obj.DataObjectBeingDestroyedListener = [];
                obj.DataObjectModifiedListener = [];
                obj.Data = wid.empty;
            end
        elseif numel(MDI) == 1, % Continue if Data-tag's Children have been directly modified
            if strcmp(MDP, 'Parent'), % New child added (and maybe children removed)
                obj.Data = reshape(wid(obj), [], 1); % Force column vector
                obj.TreeDataModifiedCount = MC;
            elseif strcmp(MDP, 'Data'), 
                obj.TreeDataModifiedCount = MC;
                return; % Do nothing
            elseif strcmp(MDP, 'Children'),
                obj.TreeDataModifiedCount = MC;
                return; % Do nothing
            elseif strcmp(MDP, 'Name'), % Child may become invalid
                obj.TreeDataModifiedCount = MC;
                obj.Data = reshape(wid(obj), [], 1); % Force column vector
            end
        end
    end
end
