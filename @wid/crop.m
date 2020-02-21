% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Crops a scalar TDBitmap, TDGraph or TDImage object, cropping its Data and
% its X, Y, Graph, Z ranges to the given pixel indices. The pixel indices
% are assumed to be either empty or scalar numeric values. Similarly,
% isDataCropped is assumed to be a scalar logical value. Any empty begin
% and end indices are set to first and last index of Data, respectively.
function [obj, Data_cropped, X_cropped, Y_cropped, Graph_cropped, Z_cropped] = crop(obj, ind_X_begin, ind_X_end, ind_Y_begin, ind_Y_end, ind_Graph_begin, ind_Graph_end, ind_Z_begin, ind_Z_end, isDataCropped),
    % Pop states (even if not used to avoid push-pop bugs)
    AutoCopyObj = obj(1).Project.popAutoCopyObj; % Get the latest value (may be temporary or permanent or default)
    AutoModifyObj = obj(1).Project.popAutoModifyObj; % Get the latest value (may be temporary or permanent or default)
    
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
        
        % Get Transformations
        [TX, TY, TGraph, TZ] = deal(Info.XTransformation, Info.YTransformation, Info.GraphTransformation, Info.ZTransformation);
        
        % Copy Transformations if shared and unshare
        [TX, TY, TGraph, TZ] = obj.copy_Others_if_shared_and_unshare(TX, TY, TGraph, TZ); 
        
        % X
        if ~isempty(TX), % Continue only if there is transformation
            TX_Data = TX.Data; % And its data
            switch(TX.Type), % Adjust the pixel offset accordingly
                case 'TDLinearTransformation',
                    TX_Data.TDLinearTransformation.ModelOrigin_D = TX_Data.TDLinearTransformation.ModelOrigin_D - (ind_X_begin - 1);
                    TX_Data.TDLinearTransformation.ModelOrigin = TX_Data.TDLinearTransformation.ModelOrigin - (ind_X_begin - 1);
                case 'TDLUTTransformation',
                    TX_Data.TDLUTTransformation.LUT = TX_Data.TDLUTTransformation.LUT(ind_X_begin:ind_X_end);
                    TX_Data.TDLUTTransformation.LUTSize = ind_X_end-ind_X_begin+1;
                case 'TDSpaceTransformation',
                    TX_Data.TDSpaceTransformation.ViewPort3D.ModelOrigin(1) = TX_Data.TDSpaceTransformation.ViewPort3D.ModelOrigin(1) - (ind_X_begin - 1);
                case 'TDSpectralTransformation',
                    TX_Data.TDSpectralTransformation.nC = TX_Data.TDSpectralTransformation.nC - (ind_X_begin - 1);
            end
            TX.Data = TX_Data; % Write all changes at once
        end
        
        % Y
        if ~isempty(TY), % Continue only if there is transformation
            TY_Data = TY.Data; % And its data
            switch(TY.Type), % Adjust the pixel offset accordingly
                case 'TDLinearTransformation',
                    TY_Data.TDLinearTransformation.ModelOrigin_D = TY_Data.TDLinearTransformation.ModelOrigin_D - (ind_Y_begin - 1);
                    TY_Data.TDLinearTransformation.ModelOrigin = TY_Data.TDLinearTransformation.ModelOrigin - (ind_Y_begin - 1);
                case 'TDLUTTransformation',
                    TY_Data.TDLUTTransformation.LUT = TY_Data.TDLUTTransformation.LUT(ind_Y_begin:ind_Y_end);
                    TY_Data.TDLUTTransformation.LUTSize = ind_Y_end-ind_Y_begin+1;
                case 'TDSpaceTransformation',
                    TY_Data.TDSpaceTransformation.ViewPort3D.ModelOrigin(2) = TY_Data.TDSpaceTransformation.ViewPort3D.ModelOrigin(2) - (ind_Y_begin - 1);
                case 'TDSpectralTransformation',
                    TY_Data.TDSpectralTransformation.nC = TY_Data.TDSpectralTransformation.nC - (ind_Y_begin - 1);
            end
            TY.Data = TY_Data; % Write all changes at once
        end
        
        % Graph
        if ~isempty(TGraph), % Continue only if there is transformation
            TGraph_Data = TGraph.Data; % And its data
            switch(TGraph.Type), % Adjust the pixel offset accordingly
                case 'TDLinearTransformation',
                    TGraph_Data.TDLinearTransformation.ModelOrigin_D = TGraph_Data.TDLinearTransformation.ModelOrigin_D - (ind_Graph_begin - 1);
                    TGraph_Data.TDLinearTransformation.ModelOrigin = TGraph_Data.TDLinearTransformation.ModelOrigin - (ind_Graph_begin - 1);
                case 'TDLUTTransformation',
                    TGraph_Data.TDLUTTransformation.LUT = TGraph_Data.TDLUTTransformation.LUT(ind_Graph_begin:ind_Graph_end);
                    TGraph_Data.TDLUTTransformation.LUTSize = ind_Graph_end-ind_Graph_begin+1;
                case 'TDSpaceTransformation',
                    error('TDSpaceTransformation cannot be GraphTransformation!');
                case 'TDSpectralTransformation',
                    TGraph_Data.TDSpectralTransformation.nC = TGraph_Data.TDSpectralTransformation.nC - (ind_Graph_begin - 1);
            end
            TGraph.Data = TGraph_Data; % Write all changes at once
        end
        
        % Z
        if ~isempty(TZ), % Continue only if there is transformation
            TZ_Data = TZ.Data; % And its data
            switch(TZ.Type), % Adjust the pixel offset accordingly
                case 'TDLinearTransformation',
                    TZ_Data.TDLinearTransformation.ModelOrigin_D = TZ_Data.TDLinearTransformation.ModelOrigin_D - (ind_Z_begin - 1);
                    TZ_Data.TDLinearTransformation.ModelOrigin = TZ_Data.TDLinearTransformation.ModelOrigin - (ind_Z_begin - 1);
                case 'TDLUTTransformation',
                    TZ_Data.TDLUTTransformation.LUT = TZ_Data.TDLUTTransformation.LUT(ind_Z_begin:ind_Z_end);
                    TZ_Data.TDLUTTransformation.LUTSize = ind_Z_end-ind_Z_begin+1;
                case 'TDSpaceTransformation',
                    TZ_Data.TDSpaceTransformation.ViewPort3D.ModelOrigin(3) = TZ_Data.TDSpaceTransformation.ViewPort3D.ModelOrigin(3) - (ind_Z_begin - 1);
                case 'TDSpectralTransformation',
                    TZ_Data.TDSpectralTransformation.nC = TZ_Data.TDSpectralTransformation.nC - (ind_Z_begin - 1);
            end
            TZ.Data = TZ_Data; % Write all changes at once
        end
    end
end
