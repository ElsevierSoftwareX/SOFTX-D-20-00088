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
% This interactive script was implemented 24.7.2018 by Joonas Holmi

% Load and select the dark current
[C_wid_dark, C_wip, ~] = wip.read('-Manager', ...
    {'-closepreview', '-singlesection', '-Title', 'SELECT ONE DARK', '-Type', 'TDGraph'});
if isempty(C_wid_dark), return; end

% Remove the cosmic rays from the dark current (can be 0-D, 1-D, 2-D and
% 3-D datas) and average down into 0-D data.
[~, dark] = clever_statistics_and_outliers(reshape(permute(C_wid_dark.Data, [3 1 2 4]), C_wid_dark.Info.GraphSize, []), 2, 4);
dark = ipermute(dark, [3 1 2 4]);

% Load and select the datas of interest
[C_wid, C_wip, n] = wip.read(C_wip.File, '-ifall', '-Manager', ...
    {'-nopreview', '-Title', 'SELECT NON-DARK', '-Type', 'TDGraph'});
if isempty(C_wid), return; end

% Remove the selected dark current from the selection
bw_nondark = all(bsxfun(@ne, [C_wid.Id].', [C_wid_dark.Id]), 2);
C_wid = C_wid(bw_nondark);
n = n(bw_nondark);

% Ask if to make copies
makecopies = strncmp(questdlg('Would you like to 1) make copies OR 2) overwrite original?', 'How to proceed?', '1) Make copies', '2) Overwrite original', '1) Make copies'), '1)', 2);

% Remove the dark current
h = waitbar(0, 'Please wait...');
for ii = 1:numel(C_wid),
    if ~ishandle(h), return; end % Abort if cancelled!
    waitbar((ii-1)/numel(C_wid), h, sprintf('Processing data %d/%d. Please wait...', ii, numel(C_wid)));
    if makecopies, C_wid_new = C_wid(ii).copy(); % Make a copy
    else, C_wid_new = C_wid(ii); end % Do not make a copy
    C_wid_new.Data = double(C_wid_new.Data) - dark;
    C_wid_new.Name = sprintf('No Dark<%s', C_wid_new.Name);
end
if ~ishandle(h), return; end % Abort if cancelled!
waitbar(1, h, 'Completed! Writing...');

% Overwrite the file
C_wip.write();

% Close the waitbar
delete(findobj(allchild(0), 'flat', 'Tag', 'TMWWaitbar')); % Avoids the closing issues with close-function!
