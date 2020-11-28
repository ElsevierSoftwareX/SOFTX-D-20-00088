% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Recalibrate the Raman spectrum's Rayleigh-peak (or 0-peak) to zero by
% automatically fitting a Gaussian function to the peak within range of
% [-25, 25] rel. 1/cm and reshifting of the X-axis with the new laser
% excitation wavelength.

% Load and select the data with Rayleigh-peak
[O_wid_w_Rayleigh, O_wip, ~] = WITio.read('-batch', '-SpectralUnit', 'rel. 1/cm', '-Manager', ...
    '--closepreview', '--singlesection', '--Title', 'SELECT ONE DATA WITH RAYLEIGH-PEAK', '--Type', 'TDGraph');
if isempty(O_wid_w_Rayleigh), return; end

% Gauss-fit the Rayleigh-peak and find its wavelength
Range_0 = [-25 25]; % Rayleigh-peak
C_0 = O_wid_w_Rayleigh.filter_gaussian(Range_0); % Gauss filtering with removal of linear background.
[~, Rayleigh_rel_invcm] = WITio.fun.clever_statistics_and_outliers(C_0(2).Data, [], 4); % Calculate mean using clever 4-sigmas statistics (Robust against outliers)
Rayleigh_nm = O_wid_w_Rayleigh.interpret_Graph('(nm)', Rayleigh_rel_invcm); % Calculate mean excitation wavelength

% Load and select the datas of interest
[O_wid, O_wip, O_wit] = WITio.read(O_wip.File, '-ifall', '-Manager', ...
    '--nopreview', '--Title', 'SELECT DATA THAT CAN BE CORRECTED', '--Type', 'TDGraph');
if isempty(O_wid), return; end

% Ask if to make copies
makecopies = strncmp(questdlg('Would you like to 1) make copies OR 2) overwrite original?', 'How to proceed?', '1) Make copies', '2) Overwrite original', '1) Make copies'), '1)', 2);

% Recalibrate the Rayleigh-peaks to zero
h = waitbar(0, 'Please wait...');
for ii = 1:numel(O_wid),
    if ~ishandle(h), return; end % Abort if cancelled!
    waitbar((ii-1)/numel(O_wid), h, sprintf('Processing data %d/%d. Please wait...', ii, numel(O_wid)));
    if makecopies, O_wid_new = O_wid(ii).copy(); % Make a copy
    else, O_wid_new = O_wid(ii); end % Do not make a copy
    GI = O_wid_new.Info.GraphInterpretation;
    GI.Data.TDSpectralInterpretation.ExcitationWaveLength = Rayleigh_nm; % Permanently recalibrate the Rayleigh peak to zero!
    O_wid_new.Name = sprintf('Rayleigh@0<%s', O_wid_new.Name);
end
if ~ishandle(h), return; end % Abort if cancelled!
waitbar(1, h, 'Completed! Writing...');

% Overwrite the files
for ii = 1:numel(O_wip), O_wip(ii).write(); end

WITio.tbx.delete_waitbars; % Close the waitbar
