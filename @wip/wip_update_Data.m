% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Update is always called when wip Project object may need to be updated
% with respect to its underlying wit Tree object.
function wip_update_Data(obj, isObjectBeingDestroyed),
    % Delete old listeners
    delete(obj.DataObjectBeingDestroyedListener);
    delete(obj.DataObjectModifiedListener);
    
    % Discard old wid Data objects
    obj.Data = wid.empty;
    
    % CASE: Data-tag is being destroyed
    if nargin > 1 && isObjectBeingDestroyed,
        obj.DataObjectBeingDestroyedListener = [];
        obj.DataObjectModifiedListener = [];
        return;
    end
    
    % OTHERWISE: Update Data-tag
    Data = obj.Tree.regexp('^Data(<WITec (Project|Data))?$', true);
    if ~isempty(Data),
        obj.DataObjectBeingDestroyedListener = Data.addlistener('ObjectBeingDestroyed', @() wip_update_Data(obj, true));
        obj.DataObjectModifiedListener = Data.addlistener('ObjectModified', @() wip_update_Data(obj));
        
        % It is computationally cheaper to recreate all objects than
        % selectively recreate some of them
        obj.Data = reshape(wid(obj), [], 1); % Force column vector
    end
end
