% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Appends COPIES of the remaining wit-classes to the FIRST given wit-class.
% The FIRST wit-class is then MODIFIED (NOT COPIED) accordingly. This works
% for WITec Project (*.WIP) and WITec Data (*.WID) WIT-structures.
% CAUTION: THIS CAN MERGE WIT-TREES WITH INCOMPATIBLE VERSIONS!
function [O_wit, varargout] = append(varargin),
    % Construct a 'only TData IDs'-flag array
    bw = cellfun(@iscell, varargin);
    varargin(bw) = cellfun(@(x) x{1}, varargin(bw), 'UniformOutput', false); % Remove cell-containers
    
    % Test input first
    ind_notwit = find(~cellfun(@(x) isa(x, 'wit'), varargin), 1);
    if ~isempty(ind_notwit), error('Input #%d expected to be a wit-class!', ind_notwit); end
    
    % Exclude all empty
    bw_notempty = ~cellfun(@isempty, varargin);
    bw = bw(bw_notempty);
    varargin = varargin(bw_notempty);
    
    % Exit if no non-empty input remaining
    O_wit = wit.empty;
    if numel(varargin) == 0, return; end % Exit here if no inputs
    
    % Append everything to the first non-empty object
    
    O_wit = varargin{1}.Root; % Get the root
    varargin = varargin(2:end); % Exclude the first
    bw = bw(2:end); % Exclude the first
    if numel(varargin) == 0, return; end % Exit here if no more inputs
    
    % Load the counters
    [Tag_ID, Tag_Data, Tag_Viewer] = O_wit.search_children('NextDataID', 'Data', 'Viewer');
    if isempty(Tag_ID), % Does not exist for WITec Data
        offset = max([Tag_Data.regexp('^ID<TData<Data \d+<').Data])+1;
        if isempty(offset), offset = 1; end % No data yet
    else, offset = Tag_ID.Data; end
    if isempty(offset), offset = 1; end % In case of empty NextDataId
    Tag_ND = Tag_Data.search_children('NumberOfData');
    ND = Tag_ND.Data;
    Tag_NV = Tag_Viewer.search_children('NumberOfViewer');
    if ~isempty(Tag_Viewer), % Does not exist for WITec Data
        NV = Tag_NV.Data;
    end
    
    % Loop through the other input
    DataOrDataClassNames = wit.empty;
    ViewerOrViewerClassNames = wit.empty;
    varargout = cell(size(varargin));
    for ii = 1:numel(varargin),
        O_wit_ii = varargin{ii}.copy(); % Get copy of the given wit-tree
        varargout{ii} = O_wit_ii; % Save copies also as output
        [Data_ii, Viewer_ii] = O_wit_ii.search_children('Data', 'Viewer');
        Both_ii = [Data_ii Viewer_ii];
        
        Data_Pairs = wip.get_Data_DataClassName_pairs(O_wit_ii);
        Viewer_Pairs = wip.get_Viewer_ViewerClassName_pairs(O_wit_ii);
        
        % Repopulate all TData IDs first (TO ENSURE THAT INT32 IS ENOUGH!)
        Tags_with_TData_ID = Data_Pairs(:,2).search_children('TData').search_children('ID'); % Only TData IDs
        old = [Tags_with_TData_ID.Data];
        new = int32(1:numel(Tags_with_TData_ID)); % Must be int32!
        for jj = 1:numel(Tags_with_TData_ID),
            Tags_with_TData_ID(jj).Data = new(jj);
        end
        % Use sparse mapper from old to new Id
        old2new = sparse(double(old), ones(size(old)), double(new));
        Tags_with_ID = Both_ii.regexp_all_Names('.+ID(List)?'); % List all other the IDs (except NextDataID) under Data and Viewer
        for jj = 1:numel(Tags_with_ID),
            if isa(Tags_with_ID(jj).Data, 'wit'), % SPECIAL CASE: ID list
                ID_list = Tags_with_ID(jj).search_children('Data');
                if ~isempty(ID_list) && ~isempty(ID_list.Data),
                    ID_list_Data = ID_list.Data;
                    B_nonzero = ID_list_Data ~= 0;
                    ID_list.Data(B_nonzero) = int32(full(old2new(ID_list_Data(B_nonzero)))); % Must be int32!
                end
            elseif Tags_with_ID(jj).Data ~= 0,
                Tags_with_ID(jj).Data = int32(full(old2new(Tags_with_ID(jj).Data))); % Must be int32!
            end
        end
        
        % Then update all the IDs
        if bw(ii), Tags_with_ID = Tags_with_TData_ID; % Only TData IDs
        else, Tags_with_ID = [Tags_with_TData_ID Tags_with_ID]; end % List all the IDs under Data and Viewer
        ID_max = 0;
        for jj = 1:numel(Tags_with_ID),
            if isa(Tags_with_ID(jj).Data, 'wit'), % SPECIAL CASE: ID list
                ID_list = Tags_with_ID(jj).search_children('Data');
                if ~isempty(ID_list) && ~isempty(ID_list.Data), % Skip empty
                    ID_max = max(ID_max, max(ID_list.Data));
                    ID_list.Data = int32(ID_list.Data + offset-1); % Must be int32!
                end
            elseif Tags_with_ID(jj).Data ~= 0, % Proceed if non-zero ID
                ID_max = max(ID_max, Tags_with_ID(jj).Data);
                Tags_with_ID(jj).Data = int32(Tags_with_ID(jj).Data + offset-1); % Must be int32!
            end
        end
        
        % Update the Data/DataClassName-pair numbering and append them
        for jj = 1:size(Data_Pairs, 1),
            Data_Pairs(jj,1).Name = sprintf('DataClassName %d', ND);
            Data_Pairs(jj,2).Name = sprintf('Data %d', ND);
            ND = ND+1;
        end
        DataOrDataClassNames = [DataOrDataClassNames reshape(Data_Pairs.', 1, [])]; % Store the modified copies
        
        if ~isempty(Tag_Viewer), % Does not exist for WITec Data
            % Update the Viewer/ViewerClassName-pair numbering and append them
            for jj = 1:size(Viewer_Pairs, 1),
                Viewer_Pairs(jj,1).Name = sprintf('ViewerClassName %d', NV);
                Viewer_Pairs(jj,2).Name = sprintf('Viewer %d', NV);
                NV = NV+1;
            end
            ViewerOrViewerClassNames = [ViewerOrViewerClassNames reshape(Viewer_Pairs.', 1, [])]; % Store the modified copies
        end
        
        % Update the counters
        offset = offset + ID_max;
    end
    
    % Set new Children only once
    Tag_Data.Data = [Tag_ND.Siblings DataOrDataClassNames Tag_ND]; % MAJOR bottleneck
    if ~isempty(Tag_Viewer), Tag_Viewer.Data = [Tag_NV.Siblings ViewerOrViewerClassNames Tag_NV]; end % Does not exist for WITec Data
    
    % Update the counters
    if ~isempty(Tag_ID), Tag_ID.Data = int32(offset); end % Must be int32! % Does not exist for WITec Data
    Tag_ND.Data = ND;
    if ~isempty(Tag_Viewer), Tag_NV.Data = NV; end % Does not exist for WITec Data
end
