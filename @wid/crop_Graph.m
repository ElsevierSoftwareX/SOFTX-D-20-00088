% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Use this function to crop the TDGraph object Data and its Graph ranges to
% the given pixel indices [ind_range(1), ind_range(2)]. It is assumed that
% the given object and pixel indices are valid.
function [obj, Data_cropped, Graph_cropped] = crop_Graph(obj, ind_range, Data_cropped, Graph_cropped),
    % Pop states (even if not used to avoid push-pop bugs)
    AutoCopyObj = obj.Project.popAutoCopyObj; % Get the latest value (may be temporary or permanent or default)
    AutoModifyObj = obj.Project.popAutoModifyObj; % Get the latest value (may be temporary or permanent or default)
    
    % Copy the object if permitted
    if AutoCopyObj, obj = obj.copy(); end
    
    % Load the object Info and Graph once
    Info = obj.Info;
    Graph = Info.Graph;
    
    % Find Graph range indices and reduce Graph transformation
    if isempty(ind_range),
        bw = Graph >= min(Graph_cropped(:)) & Graph < max(Graph_cropped(:));
        ind_range = [find(bw, 1, 'first') find(bw, 1, 'last')];
    elseif numel(ind_range) == 2,
        % Truncate the input
        if ind_range(1) < 1, ind_range(1) = 1; end
        if ind_range(1) > Info.GraphSize, ind_range(1) = Info.GraphSize; end
        if ind_range(2) < 1, ind_range(2) = 1; end
        if ind_range(2) > Info.GraphSize, ind_range(2) = Info.GraphSize; end

        % Get reduced data
        if sum(size(Graph) ~= 1) <= 1, Graph_cropped = Graph(ind_range(1):ind_range(2)); % Accepts scalar or vector Graph
        else, Graph_cropped = Graph(:,:,ind_range(1):ind_range(2),:); end % Assumes 4-D Graph (CUSTOM: to be implemented i.e. using 2nd Graph and shared LUTTransformation or just an elongated LUTTransformation)
        if nargin < 3, Data_cropped = obj.Data(:,:,ind_range(1):ind_range(2),:); end % Reduce data if not provided
    else,
        error('Index range must be a vector with length of 2!');
    end
    
    % Modify the object (or its copy) if permitted
    if AutoModifyObj,
        % Update the object
        obj.Data = Data_cropped; % Updating this affects Info.Graph calculus. Correct order is to do this last.
        
        % Get Transformations
        TGraph = Info.GraphTransformation;
        
        % Copy Transformations if shared and unshare
        TGraph = obj.copy_Others_if_shared_and_unshare(TGraph);
        
        % Graph
        if ~isempty(TGraph) && ~isempty(ind_range), % Continue only if there is transformation and not out of range
            TGraph_Data = TGraph.Data; % And its data
            switch(TGraph.Type), % Adjust the pixel offset accordingly
                case 'TDLinearTransformation',
                    TGraph_Data.TDLinearTransformation.ModelOrigin_D = TGraph_Data.TDLinearTransformation.ModelOrigin_D - (ind_range(1) - 1);
                    TGraph_Data.TDLinearTransformation.ModelOrigin = TGraph_Data.TDLinearTransformation.ModelOrigin - (ind_range(1) - 1);
                case 'TDLUTTransformation',
                    TGraph_Data.TDLUTTransformation.LUT = TGraph_Data.TDLUTTransformation.LUT(ind_range(1):ind_range(2));
                    TGraph_Data.TDLUTTransformation.LUTSize = ind_range(2)-ind_range(1)+1;
                case 'TDSpaceTransformation',
                    error('TDSpaceTransformation cannot be GraphTransformation!');
                case 'TDSpectralTransformation',
                    TGraph_Data.TDSpectralTransformation.nC = TGraph_Data.TDSpectralTransformation.nC - (ind_range(1) - 1);
            end
            TGraph.Data = TGraph_Data; % Write all changes at once
        end
    end
end
