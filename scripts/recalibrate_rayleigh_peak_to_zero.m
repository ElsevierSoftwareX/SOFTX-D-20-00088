% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Substract the selected DARK CURRENT from the selected DATA.
%
% Post-processing used for DARK CURRENT:
% Use 'clever statistics' to remove occasional cosmic ray spikes from (and
% calculate the mean for) measurement.
%
% Algorithm is based on an article written by G. Buzzi-Ferraris and
% F. Manenti: 'Outlier detection in large data sets'
% Source: http://dx.doi.org/10.1016/j.compchemeng.2010.11.004
%
% This interactive script was implemented 5.3.2019 by Joonas Holmi

% Load and select the dark current
[C_wid_w_Rayleigh, C_wip, ~] = wip.read('-SpectralUnit', '(rel. 1/cm)', '-Manager', ...
    {'-closepreview', '-singlesection', '-Title', 'SELECT ONE DATA WITH RAYLEIGH-PEAK', '-Type', 'TDGraph'});
if isempty(C_wid_w_Rayleigh), return; end

% Gauss-fit the Rayleigh-peak and find its wavelength
Range_0 = [-25 25]; % Rayleigh-peak
C_0 = C_wid_w_Rayleigh.filter_gaussian(Range_0); % Gauss filtering with removal of linear background.
[~, Rayleigh_rel_invcm] = clever_statistics_and_outliers(C_0(2).Data, [], 4); % Calculate mean using clever 4-sigmas statistics (Robust against outliers)
Rayleigh_nm = C_wid_w_Rayleigh.interpret_Graph('(nm)', Rayleigh_rel_invcm); % Calculate mean excitation wavelength

% Load and select the datas of interest
[C_wid, C_wip, n] = wip.read(C_wip.File, '-ifall', '-Manager', ...
    {'-nopreview', '-Title', 'SELECT DATA THAT CAN BE CORRECTED', '-Type', 'TDGraph'});
if isempty(C_wid), return; end

% Ask if to make copies
makecopies = strncmp(questdlg('Would you like to 1) make copies OR 2) overwrite original?', 'How to proceed?', '1) Make copies', '2) Overwrite original', '1) Make copies'), '1)', 2);

% Recalibrate the Rayleigh-peaks to zero
h = waitbar(0, 'Please wait...');
for ii = 1:numel(C_wid),
    if ~ishandle(h), return; end % Abort if cancelled!
    waitbar((ii-1)/numel(C_wid), h, sprintf('Processing data %d/%d. Please wait...', ii, numel(C_wid)));
    if makecopies, C_wid_new = C_wid(ii).copy(); % Make a copy
    else, C_wid_new = C_wid(ii); end % Do not make a copy
    GI = C_wid_new.Info.GraphInterpretation;
    GI.Data.TDSpectralInterpretation.ExcitationWaveLength = Rayleigh_nm; % Permanently recalibrate the Rayleigh peak to zero!
    C_wid_new.Name = sprintf('Rayleigh@0<%s', C_wid_new.Name);
end
if ~ishandle(h), return; end % Abort if cancelled!
waitbar(1, h, 'Completed! Writing...');

% Overwrite the file
C_wip.write();

% Close the waitbar
delete(findobj(allchild(0), 'flat', 'Tag', 'TMWWaitbar')); % Avoids the closing issues with close-function!
