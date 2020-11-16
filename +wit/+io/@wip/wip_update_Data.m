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
        obj.TreeData = wit.io.wit.empty;
        obj.TreeDataModifiedCount = [];
        obj.DataObjectBeingDestroyedListener = [];
        obj.DataObjectModifiedListener = [];
        obj.Data = wit.io.wid.empty;
        return;
    end
    
    % OTHERWISE: Update Data-tag
    TreeData = obj.TreeData;
    if isempty(TreeData),
        TreeData = obj.Tree.regexp('^Data(<WITec (Project|Data))?$', true);
        if isempty(TreeData),
            delete(obj.DataObjectBeingDestroyedListener);
            delete(obj.DataObjectModifiedListener);
            obj.TreeData = wit.io.wit.empty;
            obj.TreeDataModifiedCount = [];
            obj.DataObjectBeingDestroyedListener = [];
            obj.DataObjectModifiedListener = [];
            obj.Data = wit.io.wid.empty;
        else,
            delete(obj.DataObjectBeingDestroyedListener);
            delete(obj.DataObjectModifiedListener);
            obj.TreeData = TreeData;
            obj.TreeDataModifiedCount = TreeData.ModifiedCount;
            obj.DataObjectBeingDestroyedListener = TreeData.addlistener('ObjectBeingDestroyed', @(s,e) wip_update_Data(obj, true));
            obj.DataObjectModifiedListener = TreeData.addlistener('ObjectModified', @(s,e) wip_update_Data(obj));
            obj.Data = reshape(wit.io.wid(obj), [], 1); % Force column vector
        end
        return;
    else,
        MC = TreeData.ModifiedCount;
        if MC == obj.TreeDataModifiedCount, return; % Do nothing
        else, obj.TreeDataModifiedCount = MC; end
        MDI = TreeData.ModifiedDescendantIndices;
        MDP = TreeData.ModifiedDescendantProperty;
        MDM = TreeData.ModifiedDescendantMeta; % Use this to determine exactly which objects were added and which removed
        if numel(MDI) == 0, % Continue if Data-tag has been directly modified
            if strcmp(MDP, 'Parent'), % Data-tag becomes invalid
                TreeData = obj.Tree.regexp('^Data(<WITec (Project|Data))?$', true);
                if isempty(TreeData),
                    delete(obj.DataObjectBeingDestroyedListener);
                    delete(obj.DataObjectModifiedListener);
                    obj.TreeData = wit.io.wit.empty;
                    obj.TreeDataModifiedCount = [];
                    obj.DataObjectBeingDestroyedListener = [];
                    obj.DataObjectModifiedListener = [];
                    obj.Data = wit.io.wid.empty;
                else,
                    delete(obj.DataObjectBeingDestroyedListener);
                    delete(obj.DataObjectModifiedListener);
                    obj.TreeData = TreeData;
                    obj.DataObjectBeingDestroyedListener = TreeData.addlistener('ObjectBeingDestroyed', @(s,e) wip_update_Data(obj, true));
                    obj.DataObjectModifiedListener = TreeData.addlistener('ObjectModified', @(s,e) wip_update_Data(obj));
                    obj.Data = reshape(wit.io.wid(obj), [], 1); % Force column vector
                end
            elseif strcmp(MDP, 'Children'), % Data-tag gains new children: some may be added and some may be removed.
                TreeData_Children = TreeData.Children;
                current_Ids = [TreeData_Children.Id];
                obj_Data = obj.Data;
                current_Data_Ids = zeros(numel(obj_Data), 2);
                for ii = 1:numel(obj_Data),
                    obj_Data_ii_Tag = obj_Data(ii).Tag;
                    current_Data_Ids(ii,:) = [obj_Data_ii_Tag.Data.Id obj_Data_ii_Tag.DataClassName.Id];
                end
                current_Data_Ids = reshape(current_Data_Ids, 1, []);
                added_Ids = MDM{1,2};
                removed_Ids = MDM{2,2};
                bw_added = false(size(current_Ids));
                bw_removed = false(size(current_Data_Ids));
                if ~isempty(current_Ids) && ~isempty(added_Ids),
                    bw_added = any(bsxfun(@eq, current_Ids, added_Ids(:)), 1);
                end
                if ~isempty(current_Data_Ids) && ~isempty(removed_Ids),
                    bw_removed = any(bsxfun(@eq, current_Data_Ids, removed_Ids(:)), 1);
                end
                bw_removed = reshape(bw_removed, [], 2);
                bw_removed = any(bw_removed, 2);
                enableOnCleanup = disableObjectModified([TreeData.Root TreeData]); % Temporarily disable the Project related wit-class ObjectModified events
                obj_Data = [obj_Data(~bw_removed); reshape(wit.io.wid(TreeData_Children(bw_added)), [], 1)];
                obj.Data = obj_Data; % Force column vector
                % Update TreeData counter
                Tag_NV = TreeData.search_children('NumberOfData');
                if ~isempty(Tag_NV),
                    Tag_NV.Data = Tag_NV.Data - sum(bw_removed) + sum(bw_added); % Reduce the number by one
                end
                % Update the ordinal numberings
                for ii = 1:numel(obj_Data),
                    obj_Data(ii).OrdinalNumber = ii;
                end
            elseif strcmp(MDP, 'Data'), % Data-tag becomes empty
                delete(obj.DataObjectBeingDestroyedListener);
                delete(obj.DataObjectModifiedListener);
                obj.TreeData = wit.io.wit.empty;
                obj.TreeDataModifiedCount = [];
                obj.DataObjectBeingDestroyedListener = [];
                obj.DataObjectModifiedListener = [];
                obj.Data = wit.io.wid.empty;
            elseif strcmp(MDP, 'Name'), % Data-tag becomes invalid
                delete(obj.DataObjectBeingDestroyedListener);
                delete(obj.DataObjectModifiedListener);
                obj.TreeData = wit.io.wit.empty;
                obj.TreeDataModifiedCount = [];
                obj.DataObjectBeingDestroyedListener = [];
                obj.DataObjectModifiedListener = [];
                obj.Data = wit.io.wid.empty;
            end
        elseif numel(MDI) == 1, % Continue if Data-tag's Children have been directly modified
            % From parent's point of view, it never sees strcmp(MDP, 'Parent') == true.
            if strcmp(MDP, 'Data'), % A child of Data-tag remains valid
                return; % Do nothing
            elseif strcmp(MDP, 'Children'), % A child of Data-tag remains valid
                return; % Do nothing
            elseif strcmp(MDP, 'Name'), % A child of Data-tag may become invalid
                TreeData_Children = TreeData.Children;
                obj_Data = obj.Data;
                current_Data_Ids = zeros(numel(obj_Data), 2);
                for ii = 1:numel(obj_Data),
                    obj_Data_ii_Tag = obj_Data(ii).Tag;
                    current_Data_Ids(ii,:) = [obj_Data_ii_Tag.Data.Id obj_Data_ii_Tag.DataClassName.Id];
                end
                TreeData_Child = TreeData_Children(MDI);
                if ~strncmp(TreeData_Child.Name, 'DataClassName ', 14) && ~strncmp(TreeData_Child.Name, 'Data ', 5),
                    removed_Ids = TreeData_Child.Id;
                    bw_removed = false(size(current_Data_Ids));
                    if ~isempty(current_Data_Ids) && ~isempty(removed_Ids),
                        bw_removed = any(bsxfun(@eq, current_Data_Ids, removed_Ids(:)), 1);
                    end
                    bw_removed = reshape(bw_removed, [], 2);
                    bw_removed = any(bw_removed, 2);
                    obj_Data = obj_Data(~bw_removed);
                    obj.Data = obj_Data; % Force column vector
                    enableOnCleanup = disableObjectModified([TreeData.Root TreeData]); % Temporarily disable the Project related wit-class ObjectModified events
                    % Update TreeData counter
                    Tag_NV = TreeData.search_children('NumberOfData');
                    if ~isempty(Tag_NV),
                        Tag_NV.Data = Tag_NV.Data - 1; % Reduce the number by one
                    end
                    % Update the ordinal numberings
                    for ii = 1:numel(obj_Data),
                        obj_Data(ii).OrdinalNumber = ii;
                    end
                end
            end
        end
    end
end
