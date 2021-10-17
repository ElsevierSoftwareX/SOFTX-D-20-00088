% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Quickly get the file Data and Viewer counters. This can be applied even
% on hundreds of files at once. If no 'files' are given, then it opens a
% folder selection dialog box.
function [N_Data, N_Viewer, files] = get_Data_Viewer_counts(files),
    if nargin == 0, files = WITio.dev.tools.get_dir_files_recursively(); end
    
    % Keep only *.wip and *.wid files
    [~, ~, ext] = cellfun(@fileparts, files, 'UniformOutput', false);
    B_wit = strcmpi(ext, '.wip') | strcmpi(ext, '.wid');
    files = files(B_wit);
    
    % Open such files and collect Version-statistics
    N_Data = nan(size(files));
    N_Viewer = nan(size(files));
    for ii = 1:numel(files),
        fprintf('File %d/%d OR %s:\n', ii, numel(files), files{ii});
        % Read UNTIL Version-tag is found, skipping everything unessential
        try, WITio.obj.wit.read(files{ii}, 4096, @skip_Data_criteria_for_obj, @error_criteria_for_obj);
        catch, end
        fprintf('NumberOfData = %d, NumberOfViewer = %d\n', N_Data(ii), N_Viewer(ii));
    end
    
    function tf = skip_Data_criteria_for_obj(O_wit),
        tf = true;
        O_wit_Name = O_wit.Name;
        O_wit_Parent = O_wit.Parent;
        if isempty(O_wit_Parent), O_wit_Parent_Name = '';
        else, O_wit_Parent_Name = O_wit_Parent.Name; end
        if strcmp(O_wit_Parent_Name, '') && (strcmp(O_wit_Name, 'WITec Project') || strcmp(O_wit_Name, 'WITec Data')),
            tf = false;
        elseif (strcmp(O_wit_Parent_Name, 'WITec Project') || strcmp(O_wit_Parent_Name, 'WITec Data')) && (strcmp(O_wit_Name, 'Data') || strcmp(O_wit_Name, 'Viewer')),
            tf = false;
        elseif strcmp(O_wit_Parent_Name, 'Data') && strcmp(O_wit_Name, 'NumberOfData'),
            tf = false;
        elseif strcmp(O_wit_Parent_Name, 'Viewer') && strcmp(O_wit_Name, 'NumberOfViewer'),
            tf = false;
        end
    end
    
    function error_criteria_for_obj(O_wit),
        O_wit_Name = O_wit.Name;
        if strcmp(O_wit_Name, 'NumberOfData'), % Test if tag's name is 'NumberOfData'
            N_Data(ii) = O_wit.Data; % Store the NumberOfData
        elseif strcmp(O_wit_Name, 'NumberOfViewer'), % Test if tag's name is 'NumberOfViewer'
            N_Viewer(ii) = O_wit.Data; % Store the NumberOfViewer
        end
        if ~isnan(N_Data(ii)) && ~isnan(N_Viewer(ii)),
            error('File NumberOfData and NumberOfViewer were found!'); % Abort the file reading by throwing an error
        end
    end
end
