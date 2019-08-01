% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Calculates spatial average for the given object (be it TDBitmap, TDGraph
% or TDImage).
function [obj, Average] = spatial_average(obj)
    % Copy the object if permitted
    if obj.Project.popAutoCopyObj, % Get the latest value (may be temporary or permanent or default)
        obj = obj.copy();
    end
    
    % Calculate spatial average, mimicing nanmean behaviour
    Data = obj.Data;
    bw_nan = isnan(Data);
    Data(bw_nan) = 0; % Set NaN to zeros in order to use sums
    Average = sum(sum(Data, 1), 2)./sum(sum(~bw_nan, 1), 2); % Same as nanmean applied to both dimensions
    
    % Modify the object (or its copy) if permitted
    if obj.Project.popAutoModifyObj, % Get the latest value (may be temporary or permanent or default)
        obj.Data = Average;
        obj.Name = sprintf('Spatial Average<%s', obj.Name);
        obj.SubType = 'Point'; % Only relevant if Type == TDGraph
    end
end
