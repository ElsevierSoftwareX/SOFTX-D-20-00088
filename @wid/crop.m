% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Crops a scalar TDBitmap, TDGraph or TDImage object, cropping its Data and
% its X, Y, Graph, Z ranges to the given pixel indices. The pixel indices
% are assumed to be either empty or scalar numeric values. Similarly,
% isDataCropped is assumed to be a scalar logical value. Any empty begin
% and end indices are set to first and last index of Data, respectively.
function [obj, Data_cropped, X_cropped, Y_cropped, Graph_cropped, Z_cropped] = crop(obj, ind_X_begin, ind_X_end, ind_Y_begin, ind_Y_end, ind_Graph_begin, ind_Graph_end, ind_Z_begin, ind_Z_end, isDataCropped)
    % Pop states (even if not used to avoid push-pop bugs)
    AutoCopyObj = obj.Project.popAutoCopyObj; % Get the latest value (may be temporary or permanent or default)
    AutoModifyObj = obj.Project.popAutoModifyObj; % Get the latest value (may be temporary or permanent or default)
    
    if nargin < 2, ind_X_begin = []; end
    if nargin < 3, ind_X_end = []; end
    if nargin < 4, ind_Y_begin = []; end
    if nargin < 5, ind_Y_end = []; end
    if nargin < 6, ind_Graph_begin = []; end
    if nargin < 7, ind_Graph_end = []; end
    if nargin < 8, ind_Z_begin = []; end
    if nargin < 9, ind_Z_end = []; end
    if nargin < 10, isDataCropped = false; end
    
    % Test object
    if numel(obj) ~= 1 || ...
            ~strcmp(obj.Type, 'TDBitmap') && ...
            ~strcmp(obj.Type, 'TDGraph') && ...
            ~strcmp(obj.Type, 'TDImage'),
        error('Only a scalar TDBitmap, TDGraph or TDImage object can be cropped!');
    end
    
    % Test indices
    if ~isempty(ind_X_begin) && (~isscalar(ind_X_begin) || ~isnumeric(ind_X_begin)) || ...
            ~isempty(ind_X_end) && (~isscalar(ind_X_end) || ~isnumeric(ind_X_end)) || ...
            ~isempty(ind_Y_begin) && (~isscalar(ind_Y_begin) || ~isnumeric(ind_Y_begin)) || ...
            ~isempty(ind_Y_end) && (~isscalar(ind_Y_end) || ~isnumeric(ind_Y_end)) || ...
            ~isempty(ind_Graph_begin) && (~isscalar(ind_Graph_begin) || ~isnumeric(ind_Graph_begin)) || ...
            ~isempty(ind_Graph_end) && (~isscalar(ind_Graph_end) || ~isnumeric(ind_Graph_end)) || ...
            ~isempty(ind_Z_begin) && (~isscalar(ind_Z_begin) || ~isnumeric(ind_Z_begin)) || ...
            ~isempty(ind_Z_end) && (~isscalar(ind_Z_end) || ~isnumeric(ind_Z_end)),
        error('Only empty or scalar numeric indices are allowed!');
    end
    
    % Test boolean
    if ~isscalar(isDataCropped) || ~(islogical(isDataCropped) || isnumeric(isDataCropped)),
        error('Only scalar logical or numeric value for isDataCropped is allowed!');
    end
    
    % Copy the object if permitted
    if AutoCopyObj, obj = obj.copy(); end
    
    % Load the object info once
    Info = obj.Info;
    
    % Truncate the input
    if isempty(ind_X_begin) || ind_X_begin < 1, ind_X_begin = 1; end
    if ind_X_begin > Info.XSize, ind_X_begin = Info.XSize; end
    if ind_X_end < 1, ind_X_end = 1; end
    if isempty(ind_X_end) || ind_X_end > Info.XSize, ind_X_end = Info.XSize; end
    
    if isempty(ind_Y_begin) || ind_Y_begin < 1, ind_Y_begin = 1; end
    if ind_Y_begin > Info.YSize, ind_Y_begin = Info.YSize; end
    if ind_Y_end < 1, ind_Y_end = 1; end
    if isempty(ind_Y_end) || ind_Y_end > Info.YSize, ind_Y_end = Info.YSize; end
    
    if isempty(ind_Graph_begin) || ind_Graph_begin < 1, ind_Graph_begin = 1; end
    if ind_Graph_begin > Info.GraphSize, ind_Graph_begin = Info.GraphSize; end
    if ind_Graph_end < 1, ind_Graph_end = 1; end
    if isempty(ind_Graph_end) || ind_Graph_end > Info.GraphSize, ind_Graph_end = Info.GraphSize; end
    
    if isempty(ind_Z_begin) || ind_Z_begin < 1, ind_Z_begin = 1; end
    if ind_Z_begin > Info.ZSize, ind_Z_begin = Info.ZSize; end
    if ind_Z_end < 1, ind_Z_end = 1; end
    if isempty(ind_Z_end) || ind_Z_end > Info.ZSize, ind_Z_end = Info.ZSize; end
    
    % Get reduced data
    X_cropped = Info.X(ind_X_begin:ind_X_end);
    Y_cropped = Info.Y(ind_Y_begin:ind_Y_end);
    Graph_cropped = Info.Graph(ind_Graph_begin:ind_Graph_end);
    Z_cropped = Info.Z(ind_Z_begin:ind_Z_end);
    
    if isDataCropped, Data_cropped = obj.Data;
    else, Data_cropped = obj.Data(ind_X_begin:ind_X_end,ind_Y_begin:ind_Y_end,ind_Graph_begin:ind_Graph_end,ind_Z_begin:ind_Z_end); end
    
    % Modify the object (or its copy) if permitted
    if AutoModifyObj,
        % Update the object
        if ~isDataCropped,
            obj.Data = Data_cropped; % Update the data accordingly
        end

        T = Info.XTransformation; % Get the x transformation object
        if ~isempty(T), % Continue only if there is transformation
            T_Data = T.Data; % And its data
            switch(T.Type), % Adjust the pixel offset accordingly
                case 'TDLinearTransformation',
                    T_Data.TDLinearTransformation.ModelOrigin_D = T_Data.TDLinearTransformation.ModelOrigin_D - (ind_X_begin - 1);
                    T_Data.TDLinearTransformation.ModelOrigin = T_Data.TDLinearTransformation.ModelOrigin - (ind_X_begin - 1);
                case 'TDLUTTransformation',
                    T_Data.TDLUTTransformation.LUT = T_Data.TDLUTTransformation.LUT(ind_X_begin:ind_X_end);
                    T_Data.TDLUTTransformation.LUTSize = ind_X_end-ind_X_begin+1;
                case 'TDSpaceTransformation',
                    T_Data.TDSpaceTransformation.ViewPort3D.ModelOrigin(1) = T_Data.TDSpaceTransformation.ViewPort3D.ModelOrigin(1) - (ind_X_begin - 1);
                case 'TDSpectralTransformation',
                    T_Data.TDSpectralTransformation.nC = T_Data.TDSpectralTransformation.nC - (ind_X_begin - 1);
            end
            T.Data = T_Data; % Write all changes at once
        end

        T = Info.YTransformation; % Get the y transformation object
        if ~isempty(T), % Continue only if there is transformation
            T_Data = T.Data; % And its data
            switch(T.Type), % Adjust the pixel offset accordingly
                case 'TDLinearTransformation',
                    T_Data.TDLinearTransformation.ModelOrigin_D = T_Data.TDLinearTransformation.ModelOrigin_D - (ind_Y_begin - 1);
                    T_Data.TDLinearTransformation.ModelOrigin = T_Data.TDLinearTransformation.ModelOrigin - (ind_Y_begin - 1);
                case 'TDLUTTransformation',
                    T_Data.TDLUTTransformation.LUT = T_Data.TDLUTTransformation.LUT(ind_Y_begin:ind_Y_end);
                    T_Data.TDLUTTransformation.LUTSize = ind_Y_end-ind_Y_begin+1;
                case 'TDSpaceTransformation',
                    T_Data.TDSpaceTransformation.ViewPort3D.ModelOrigin(2) = T_Data.TDSpaceTransformation.ViewPort3D.ModelOrigin(2) - (ind_Y_begin - 1);
                case 'TDSpectralTransformation',
                    T_Data.TDSpectralTransformation.nC = T_Data.TDSpectralTransformation.nC - (ind_Y_begin - 1);
            end
            T.Data = T_Data; % Write all changes at once
        end

        T = Info.GraphTransformation; % Get the graph transformation object
        if ~isempty(T), % Continue only if there is transformation
            T_Data = T.Data; % And its data
            switch(T.Type), % Adjust the pixel offset accordingly
                case 'TDLinearTransformation',
                    T_Data.TDLinearTransformation.ModelOrigin_D = T_Data.TDLinearTransformation.ModelOrigin_D - (ind_Graph_begin - 1);
                    T_Data.TDLinearTransformation.ModelOrigin = T_Data.TDLinearTransformation.ModelOrigin - (ind_Graph_begin - 1);
                case 'TDLUTTransformation',
                    T_Data.TDLUTTransformation.LUT = T_Data.TDLUTTransformation.LUT(ind_Graph_begin:ind_Graph_end);
                    T_Data.TDLUTTransformation.LUTSize = ind_Graph_end-ind_Graph_begin+1;
                case 'TDSpaceTransformation',
                    error('TDSpaceTransformation cannot be GraphTransformation!');
                case 'TDSpectralTransformation',
                    T_Data.TDSpectralTransformation.nC = T_Data.TDSpectralTransformation.nC - (ind_Graph_begin - 1);
            end
            T.Data = T_Data; % Write all changes at once
        end

        T = Info.ZTransformation; % Get the z transformation object
        if ~isempty(T), % Continue only if there is transformation
            T_Data = T.Data; % And its data
            switch(T.Type), % Adjust the pixel offset accordingly
                case 'TDLinearTransformation',
                    T_Data.TDLinearTransformation.ModelOrigin_D = T_Data.TDLinearTransformation.ModelOrigin_D - (ind_Z_begin - 1);
                    T_Data.TDLinearTransformation.ModelOrigin = T_Data.TDLinearTransformation.ModelOrigin - (ind_Z_begin - 1);
                case 'TDLUTTransformation',
                    T_Data.TDLUTTransformation.LUT = T_Data.TDLUTTransformation.LUT(ind_Z_begin:ind_Z_end);
                    T_Data.TDLUTTransformation.LUTSize = ind_Z_end-ind_Z_begin+1;
                case 'TDSpaceTransformation',
                    T_Data.TDSpaceTransformation.ViewPort3D.ModelOrigin(3) = T_Data.TDSpaceTransformation.ViewPort3D.ModelOrigin(3) - (ind_Z_begin - 1);
                case 'TDSpectralTransformation',
                    T_Data.TDSpectralTransformation.nC = T_Data.TDSpectralTransformation.nC - (ind_Z_begin - 1);
            end
            T.Data = T_Data; % Write all changes at once
        end
    end
end
