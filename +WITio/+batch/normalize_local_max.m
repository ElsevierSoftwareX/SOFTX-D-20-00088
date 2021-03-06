% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Normalizes the spectrum (preferably without dark current and cosmic rays)
% by dividing it with maximum value of the given range.

% Get local range
strs = inputdlg({'Lower bound for the local maximum:', 'Upper bound for the local maximum:', 'ForceSpectralUnit:'}, 'Input', [1 35; 1 35; 1 35], {'-Inf', 'Inf', '(rel. 1/cm)'});
if isempty(strs), return; end % Stop if cancelled
bounds = str2double(strs(1:2));
SpectralUnit = strs{3};
if any(isnan(bounds) | bounds(1) == bounds(2)), return; end % Stop if invalid input
bounds = [min(bounds) max(bounds)]; % Rearrange bounds

% Load and select the datas of interest
[O_wid, O_wip, O_wit] = WITio.read('-ifall', '-SpectralUnit', SpectralUnit, '-Manager', ...
    '--nopreview', '--Title', 'SELECT NORMALIZABLE DATA', '--Type', 'TDGraph');
if isempty(O_wid), return; end

% Ask if to make copies
makecopies = strncmp(questdlg('Would you like to 1) make copies OR 2) overwrite original?', 'How to proceed?', '1) Make copies', '2) Overwrite original', '1) Make copies'), '1)', 2);

% Renormalize
h = WITio.tbx.waitbar(0, 'Please wait...');
for ii = 1:numel(O_wid),
    if ~ishandle(h), return; end % Abort if cancelled!
    WITio.tbx.waitbar((ii-1)/numel(O_wid), h, sprintf('Processing data %d/%d. Please wait...', ii, numel(O_wid)));
    if makecopies, O_wid_new = O_wid(ii).copy(); % Make a copy
    else, O_wid_new = O_wid(ii); end % Do not make a copy
    new_Data = O_wid_new.Data;
    [Data_range, Graph_range] = WITio.obj.wid.crop_Graph_with_bg_helper(new_Data, O_wid_new.Info.Graph, bounds, 0, 0);
    O_wid_new.Data = double(new_Data) ./ double(max(Data_range, [], 3));
    O_wid_new.Name = sprintf('Normalized[%g,%g]<%s', bounds(1), bounds(2), O_wid_new.Name);
end
if ~ishandle(h), return; end % Abort if cancelled!
WITio.tbx.waitbar(1, h, 'Completed! Writing...');

% Overwrite the files
for ii = 1:numel(O_wip), O_wip(ii).write(); end

WITio.tbx.delete_waitbars; % Close the waitbar
