% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Appends COPIES of the remaining wit-classes to the FIRST given wit-class.
% The FIRST wit-class is then MODIFIED (NOT COPIED) accordingly. This works
% for WITec Project (*.WIP) and WITec Data (*.WID) WIT-structures.
% CAUTION: THIS CAN MERGE WIT-TREES WITH INCOMPATIBLE VERSIONS!
function [C_wit, varargout] = append(varargin),
    % Construct a 'only TData IDs'-flag array
    bw = cellfun(@iscell, varargin);
    varargin(bw) = cellfun(@(x) x{1}, varargin(bw), 'UniformOutput', false); % Remove cell-containers
    
    % Test input first
    ind_notwit = find(~cellfun(@(x) isa(x, 'wit'), varargin), 1);
    if ~isempty(ind_notwit), error('Input #%d expected to be a wit-class!', ind_notwit); end
    
    % Exclude all empty
    varargin = varargin(~cellfun(@isempty, varargin));
    
    % Exit if no non-empty input remaining
    C_wit = wit.Empty;
    if numel(varargin) == 0, return; end % Exit here if no inputs
    
    % Append everything to the first non-empty object
    C_wit = varargin{1}.Root; % Get the root
    varargin = varargin(2:end); % Exclude the first
    bw = bw(2:end); % Exclude the first
    if numel(varargin) == 0, return; end % Exit here if no more inputs
    
    % Load the counters
    Tag_ID = C_wit.regexp('^NextDataID', true);
    if isempty(Tag_ID), % Does not exist for WITec Data
        offset = max([C_wit.regexp('^ID<TData<Data \d+(<Data(<WITec (Project|Data))?)?$').Data])+1;
        if isempty(offset), offset = 1; end % No data yet
    else, offset = Tag_ID.Data; end
    if isempty(offset), offset = 1; end % In case of empty NextDataId
    Tag_Data = C_wit.regexp('^Data(<WITec (Project|Data))?$', true);
    Tag_ND = Tag_Data.search('NumberOfData', 'Data'); % Tag_ND = Tag_Data.regexp('^NumberOfData<', true); % MAJOR bottleneck
    ND = Tag_ND.Data;
    Tag_Viewer = C_wit.regexp('^Viewer(<WITec (Project|Data))?$', true);
    if ~isempty(Tag_Viewer), % Does not exist for WITec Data
        Tag_NV = Tag_Viewer.regexp('^NumberOfViewer<', true);
        NV = Tag_NV.Data;
    end
    
    % Loop through the other input
    DataOrDataClassNames = wit.Empty;
    ViewerOrViewerClassNames = wit.Empty;
    for ii = 1:numel(varargin),
        C_wit_ii = varargin{ii}.copy(); % Get copy of the given wit-tree
        varargout{ii} = C_wit_ii; % Save copies also as output
        
        % Repopulate all TData IDs first (TO ENSURE THAT INT32 IS ENOUGH!)
        Tags_with_TData_ID = C_wit_ii.regexp('^ID<TData<Data \d+(<Data(<WITec (Project|Data))?)?$'); % Only TData IDs
        Tags_with_ID = C_wit_ii.regexp('^(?!NextDataID)([^<]+ID(List)?(<[^<]*)*(<(Data|Viewer)(<WITec (Project|Data))?)?$)'); % List all other the IDs (except NextDataID) under Data and Viewer
%         fprintf('REPOPULATE\n');
        for jj = 1:numel(Tags_with_TData_ID),
            old = Tags_with_TData_ID(jj).Data;
            Tags_with_TData_ID(jj).Data = int32(jj); % Must be int32!
%             fprintf('TData ID: %d -> %d\n', old, jj);
            for kk = 1:numel(Tags_with_ID),
                if isa(Tags_with_ID(kk).Data, 'wit'), % SPECIAL CASE: ID list
                    ID_list = Tags_with_ID(kk).Data.regexp('^Data<');
                    if ~isempty(ID_list) && ~isempty(ID_list.Data), ID_list.Data(ID_list.Data == old) = int32(jj); end % Must be int32!
                elseif Tags_with_ID(kk).Data == old,
                    Tags_with_ID(kk).Data = int32(jj); % Must be int32!
                end
            end
        end
        
        % Then update all the IDs
        if bw(ii), Tags_with_ID = Tags_with_TData_ID; % Only TData IDs
        else, Tags_with_ID = [Tags_with_TData_ID Tags_with_ID]; end % List all the IDs under Data and Viewer
        ID_max = 0;
%         fprintf('UPDATE\n');
        for jj = 1:numel(Tags_with_ID),
            if isa(Tags_with_ID(jj).Data, 'wit'), % SPECIAL CASE: ID list
                ID_list = Tags_with_ID(jj).Data.regexp('^Data<');
                if ~isempty(ID_list) && ~isempty(ID_list.Data), % Skip empty
                    ID_max = max(ID_max, max(ID_list.Data));
                    ID_list.Data = int32(ID_list.Data + offset-1); % Must be int32!
                end
            elseif Tags_with_ID(jj).Data ~= 0, % Proceed if non-zero ID
                ID_max = max(ID_max, Tags_with_ID(jj).Data);
%                 fprintf('ID: %d -> %d\n', Tags_with_ID(jj).Data, Tags_with_ID(jj).Data + offset-1);
                Tags_with_ID(jj).Data = int32(Tags_with_ID(jj).Data + offset-1); % Must be int32!
            end
        end
        
        % Update the Data/DataClassName-pair numbering and append them
        DataClassNames = C_wit_ii.regexp('^DataClassName \d+(<Data(<WITec (Project|Data))?)?$');
        Datas = C_wit_ii.regexp('^Data \d+(<Data(<WITec (Project|Data))?)?$');
        str_DataClassNames = {DataClassNames.Name}; % Store names before the update to avoid dynamic bugs!
        str_Datas = {Datas.Name}; % Store names before the update to avoid dynamic bugs!
        for jj = 1:numel(str_DataClassNames),
            bw_pair = strcmp(str_Datas, strrep(str_DataClassNames{jj}, 'ClassName', ''));
            DataClassNames(jj).Name = regexprep(str_DataClassNames{jj}, '\d+', sprintf('%d', ND));
            Datas(bw_pair).Name = regexprep(str_Datas{bw_pair}, '\d+', sprintf('%d', ND));
            ND = ND+1;
            DataOrDataClassNames = [DataOrDataClassNames DataClassNames(jj) Datas(bw_pair)]; % Store the modified copies in sorted order
        end
%         DataOrDataClassNames = [DataOrDataClassNames reshape([DataClassNames(:)'; Datas(:)'], 1, [])]; % Store the modified copies
        
        if ~isempty(Tag_Viewer), % Does not exist for WITec Data
            % Update the Viewer/ViewerClassName-pair numbering and append them
            ViewerClassNames = C_wit_ii.regexp('^ViewerClassName \d+(<Viewer(<WITec (Project|Data))?)?$');
            Viewers = C_wit_ii.regexp('^Viewer \d+(<Viewer(<WITec (Project|Data))?)?$');
            str_ViewerClassNames = {ViewerClassNames.Name}; % Store names before the update to avoid dynamic bugs!
            str_Viewers = {Viewers.Name}; % Store names before the update to avoid dynamic bugs!
            for jj = 1:numel(str_ViewerClassNames),
                bw_pair = strcmp(str_Viewers, strrep(str_ViewerClassNames{jj}, 'ClassName', ''));
                ViewerClassNames(jj).Name = regexprep(str_ViewerClassNames{jj}, '\d+', sprintf('%d', ND));
                Viewers(bw_pair).Name = regexprep(str_Viewers{bw_pair}, '\d+', sprintf('%d', ND));
                NV = NV+1;
                ViewerOrViewerClassNames = [ViewerOrViewerClassNames ViewerClassNames(jj) Viewers(bw_pair)]; % Store the modified copies in sorted order
            end
%             ViewerOrViewerClassNames = [ViewerOrViewerClassNames reshape([ViewerClassNames(:)'; Viewers(:)'], 1, [])]; % Store the modified copies
        end
        
        % Update the counters
        offset = offset + ID_max;
    end
    
    % Set new Children only once
    Tag_Data.Data = [Tag_ND.Siblings DataOrDataClassNames Tag_ND]; % MAJOR bottleneck
    if ~isempty(Tag_Viewer), Tag_Viewer.Data = [Tag_NV.Siblings ViewerOrViewerClassNames Tag_NV]; end % Does not exist for WITec Data
    
    % Update the counters
    if ~isempty(Tag_ID), Tag_ID.Data = offset; end % Does not exist for WITec Data
    Tag_ND.Data = ND;
    if ~isempty(Tag_Viewer), Tag_NV.Data = NV; end % Does not exist for WITec Data
end
