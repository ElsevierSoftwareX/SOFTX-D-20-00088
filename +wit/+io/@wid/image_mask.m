% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [obj, Data_NaN_masked] = image_mask(obj, varargin),
    % Pop states (even if not used to avoid push-pop bugs)
    AutoCopyObj = obj.Project.popAutoCopyObj; % Get the latest value (may be temporary or permanent or default)
    AutoModifyObj = obj.Project.popAutoModifyObj; % Get the latest value (may be temporary or permanent or default)
    
    % Abort if no mask input
    if numel(varargin) == 0, return; end
    
    % Continue only if obj is valid
    if strcmp('TDBitmap', obj.Type) || (strcmp('TDGraph', obj.Type) && strcmp('Image', obj.SubType)) || strcmp('TDImage', obj.Type),
        % Copy the object if permitted
        if AutoCopyObj, obj = obj.copy(); end
        
        % PROCESS MASK INPUTS
        varargin = cellfun(@(x) x(:).', varargin, 'UniformOutput', false); % Force varargin content row-vectors
        obj_Masks = [varargin{:}]; % And make a long row-vector from varargin row-vector content
        Data_mask = all(obj_Masks.merge_Data(3), 3);
        [~, Data_NaN_masked] = wit.io.fun.data_mask(obj.Data, Data_mask);
        
        % Modify the object (or its copy) if permitted
        if AutoModifyObj,
            obj.Name = sprintf('Masked<%s', obj.Name);
            obj.Data = Data_NaN_masked;
        end
    else,
        warning('Invalid Type! Image masks is only apply for TDBitmap, Image<TDGraph and TDImage. ABORTING...');
        return; % Abort if illegal type!
    end
end
