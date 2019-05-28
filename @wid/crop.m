% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Use this function to reduce the TDBitmap, TDGraph or TDImage object Data
% and its X, Y, Graph, Z ranges to the given pixel indices. It is assumed
% that the given object and pixel indices are valid. If any of the begin
% indices are [], then they are set 1. If any of the end indices are [],
% then they are set to the end of Data.
function [obj, Data_reduced, X_reduced, Y_reduced, Graph_reduced, Z_reduced] = crop(obj, ind_X_begin, ind_X_end, ind_Y_begin, ind_Y_end, ind_Graph_begin, ind_Graph_end, ind_Z_begin, ind_Z_end)
    % Copy the object if permitted
    if isempty(obj.Project) || obj.Project.AutoCopyObj,
        obj = obj.copy();
    end
    
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
    X_reduced = Info.X(ind_X_begin:ind_X_end);
    Y_reduced = Info.Y(ind_Y_begin:ind_Y_end);
    Graph_reduced = Info.Graph(ind_Graph_begin:ind_Graph_end);
    Z_reduced = Info.Z(ind_Z_begin:ind_Z_end);
    Data_reduced = obj.Data(ind_X_begin:ind_X_end,ind_Y_begin:ind_Y_end,ind_Graph_begin:ind_Graph_end,ind_Z_begin:ind_Z_end);
    
    % Modify the object (or its copy) if permitted
    if isempty(obj.Project) || obj.Project.AutoModifyObj,
        % Update the object
        obj.Data = Data_reduced; % Update the data accordingly

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
