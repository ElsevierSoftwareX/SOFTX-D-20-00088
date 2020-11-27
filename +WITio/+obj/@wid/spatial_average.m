% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Calculates spatial average for the given object (be it TDBitmap, TDGraph
% or TDImage).
function [obj, Average] = spatial_average(obj),% Copy the object if permitted
    if WITio.tbx.pref.get('wip_AutoCopyObj', true), obj = obj.copy(); end
    
    % Calculate spatial average, mimicing nanmean behaviour
    Data = obj.Data;
    bw_nan = isnan(Data);
    Data(bw_nan) = 0; % Set NaN to zeros in order to use sums
    Average = sum(sum(Data, 1), 2)./sum(sum(~bw_nan, 1), 2); % Same as nanmean applied to both dimensions
    
    % Modify the object (or its copy) if permitted
    if WITio.tbx.pref.get('wip_AutoModifyObj', true),
        obj.Data = Average;
        obj.Name = sprintf('Spatial Average<%s', obj.Name);
        obj.SubType = 'Point'; % Only relevant if Type == TDGraph
        
        % Load the object info once
        Info = obj.Info;
        
        T = Info.XTransformation; % Get the space transformation object
        if ~isempty(T) && strcmp(T.Type, 'TDSpaceTransformation'), % Continue only if there is transformation
            T_Data = T.Data; % Get its data
            T_Data.TDSpaceTransformation.ViewPort3D.ModelOrigin(1) = T_Data.TDSpaceTransformation.ViewPort3D.ModelOrigin(1) - (Info.XSize-1)/2;
            T_Data.TDSpaceTransformation.ViewPort3D.ModelOrigin(2) = T_Data.TDSpaceTransformation.ViewPort3D.ModelOrigin(2) - (Info.YSize-1)/2;
            T_Data.TDSpaceTransformation.ViewPort3D.ModelOrigin(3) = T_Data.TDSpaceTransformation.ViewPort3D.ModelOrigin(3) - (Info.ZSize-1)/2;
            T.Data = T_Data; % Write all changes at once
        end
    end
end
