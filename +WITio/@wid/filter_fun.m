% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% * Requires [F, (I_new)] = fun(I, X, dim), where I is a 3-D intensity
% matrix, X is a 3-D spectral matrix, dim is the dimension of calculus, and
% F is a 3-D result matrix, where the dim'th dimension size is the number
% of result variables. Here (I_new) is OPTIONAL and creates new TDGraph for
% it.
% * Assumes that fun uses bsxfun-functionality, because I and X do not need
% to be same size and only size(I, dim) == size(X, dim) is quaranteed!
function [new_obj, varargout] = filter_fun(obj, fun, str_fun, varargin),
    % Get obj Project (even if it does not exist)
    Project = obj.Project;
    
    % Pop states (even if not used to avoid push-pop bugs)
    AutoCreateObj = Project.popAutoCreateObj; % Get the latest value (may be temporary or permanent or default)
    
    new_obj = WITio.wid.empty;
    
    Project.pushAutoCopyObj(false); % Temporarily don't allow copying
    Project.pushAutoModifyObj(false); % Temporarily don't allow modifying
    
    % Limit the 3rd dimension range and apply linear background removal (if set)
    [~, Data_range, Graph_range, Data_range_bg] = obj.filter_bg(varargin{:});
    
    % If a scalar or vector Graph_range, then force it to the dim'th dimension
    if sum(size(Graph_range) ~= 1) <= 1, 
        Graph_range = ipermute(Graph_range(:), [3 1 2]); % Most of the time Graph_range is a vector
    end
    
    % Evaluate the result
    N_outputs = abs(nargout(fun));
    if N_outputs == 1,
        result = fun(Data_range, Graph_range, 3);
        Data_range_new = [];
    elseif N_outputs == 2,
        [result, Data_range_new] = fun(Data_range, Graph_range, 3);
        Data_range_new = bsxfun(@plus, Data_range_new, Data_range_bg); % Restore removed linear background
    else,
        error('The given fun-function has incorrect amount of nargout: %d', N_outputs);
    end
    
    % Get obj Name, Version and Root
    Name = obj.Name;
    Version = WITio.wip.get_Root_Version(obj);
    Root = obj.Tag.Root;
    
    % Get transformations and interpretations (but do not copy them even if popAutoCopyObj == true)
    SpaceT = [obj.Tag.Data.regexp('^SpaceTransformationID<TDGraph<', true).Data 0];
    if Version == 7,
        SpaceST = [obj.Tag.Data.regexp('^SecondaryTransformationID<TDGraph<', true).Data 0]; %v7
    end
%     DataI = [obj.Tag.Data.regexp('^ZInterpretationID<TDGraph<', true).Data 0];
    
    % Create a new TDImage object for each result
    if ~iscell(str_fun), str_fun = {str_fun}; end % Force str_fun a cell of strings
    for ii = 1:size(result, 3),
        result_ii = result(:,:,ii,:); % Third : here is not really needed and was added for potential later code upgrade to 4-D matrices (27.2.2019)
        varargout{ii} = result_ii; % Store this result as (ii+1)'th output
        
        % Create new object if permitted
        if AutoCreateObj,
            new_obj(ii) = WITio.wid.new_Image(Root); % This does not add newly created object to Project yet!
            new_obj(ii).Name = sprintf('%s[%g-%g]<%s', str_fun{ii}, varargin{1}(1), varargin{1}(2), Name); % Generate new name
            new_obj(ii).Data = result_ii; % Save result-variable content as Data

            % Give it the same transformations and interpretations
            new_obj(ii).Tag.Data.regexp('^PositionTransformationID<TDImage<', true).Data = int32(SpaceT(1)); % Must be int32!
            if Version == 7,
                new_obj(ii).Tag.Data.regexp('^SecondaryTransformationID<TDImage<', true).Data = int32(SpaceST(1)); %v7 % Must be int32!
            end
            % Avoid setting DataUnit, because the result_ii units are unknown.
        end
    end
    
    % These were AUTOMATICALLY added to the wip Project object!
    
    % OPTIONAL: Create a new TDGraph object for I_new, which is returned by
    % fitting algorithms, in order to visually test the fitting result.
    if ~isempty(Data_range_new)
        varargout{end+1} = Data_range_new; % Store this result as last output
        
        % Create new object if permitted
        if AutoCreateObj, 
            Project.pushAutoCopyObj(true); % Temporarily allow copying
            Project.pushAutoModifyObj(true); % Temporarily allow modifying

            new_TDGraph = obj.crop_Graph([], Data_range_new, Graph_range); % Which uses wid.copy-function that automatically appends new copy (and its LinksToOthers) to the Project
            new_TDGraph.Name = sprintf('%s[%g-%g]<%s', str_fun{end}, varargin{1}(1), varargin{1}(2), Name); % Generate new name

            new_obj = [new_obj new_TDGraph]; % Also return new_TDGraph
        end
    end
end
