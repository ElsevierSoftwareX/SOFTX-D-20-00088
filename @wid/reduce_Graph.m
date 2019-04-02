% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Use this function to reduce the TDGraph object Data and its Graph ranges
% to the given pixel indices [ind_range(1), ind_range(2)]. It is assumed that the
% given object and pixel indices are valid.
function [obj, Data_reduced, Graph_reduced] = reduce_Graph(obj, ind_range, Data_reduced, Graph_reduced)
    % Copy the object if permitted
    if isempty(obj.Project) || obj.Project.AutoCopyObj,
        obj = obj.copy();
    end
    
    % Load the object Info and Graph once
    Info = obj.Info;
    Graph = Info.Graph;
    
    % Find Graph range indices and reduce Graph transformation
    if isempty(ind_range),
        bw = Graph >= min(Graph_reduced(:)) & Graph < max(Graph_reduced(:));
        ind_range = [find(bw, 1, 'first') find(bw, 1, 'last')];
    elseif numel(ind_range) == 2,
        % Truncate the input
        if ind_range(1) < 1, ind_range(1) = 1; end
        if ind_range(1) > Info.GraphSize, ind_range(1) = Info.GraphSize; end
        if ind_range(2) < 1, ind_range(2) = 1; end
        if ind_range(2) > Info.GraphSize, ind_range(2) = Info.GraphSize; end

        % Get reduced data
        if sum(size(Graph) ~= 1) <= 1, Graph_reduced = Graph(ind_range(1):ind_range(2)); % Accepts scalar or vector Graph
        else, Graph_reduced = Graph(:,:,ind_range(1):ind_range(2),:); end % Assumes 4-D Graph (CUSTOM: to be implemented i.e. using 2nd Graph and shared LUTTransformation or just an elongated LUTTransformation)
        if nargin < 3, Data_reduced = obj.Data(:,:,ind_range(1):ind_range(2),:); end % Reduce data if not provided
    else,
        error('Index range must be a vector with length of 2!');
    end
    
    % Modify the object (or its copy) if permitted
    if isempty(obj.Project) || obj.Project.AutoModifyObj,
        % Update the object
        obj.Data = Data_reduced; % Updating this affects Info.Graph calculus. Correct order is to do this last.
        GT = Info.GraphTransformation; % Get the graph transformation object
        if ~isempty(GT) && ~isempty(ind_range), % Continue only if there is transformation and not out of range
            GT_Data = GT.Data; % And its data
            switch(GT.Type), % Adjust the pixel offset accordingly
                case 'TDLinearTransformation',
                    GT.Data.TDLinearTransformation.ModelOrigin_D = GT_Data.TDLinearTransformation.ModelOrigin_D - (ind_range(1) - 1);
                    GT.Data.TDLinearTransformation.ModelOrigin = GT_Data.TDLinearTransformation.ModelOrigin - (ind_range(1) - 1);
                case 'TDLUTTransformation',
                    GT.Data.TDLUTTransformation.LUT = GT_Data.TDLUTTransformation.LUT(ind_range(1):ind_range(2));
                    GT.Data.TDLUTTransformation.LUTSize = ind_range(2)-ind_range(1)+1;
                case 'TDSpaceTransformation',
                    error('TDSpaceTransformation cannot be GraphTransformation!');
                case 'TDSpectralTransformation',
                    GT.Data.TDSpectralTransformation.nC = GT_Data.TDSpectralTransformation.nC - (ind_range(1) - 1);
            end
        end
    end
end
