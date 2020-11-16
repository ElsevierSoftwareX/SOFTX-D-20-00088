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
[O_wid_dark, O_wip, ~] = wit.io.wip.read('-Manager', ...
    '--closepreview', '--singlesection', '--Title', 'SELECT ONE DARK', '--Type', 'TDGraph');
if isempty(O_wid_dark), return; end

% Remove the cosmic rays from the dark current (can be 0-D, 1-D, 2-D and
% 3-D datas) and average down into 0-D data.
[~, dark] = wit.io.fun.clever_statistics_and_outliers(O_wid_dark.Data, -3, 4); % Here -3 reads as NOT 3rd dimension

% Load and select the datas of interest
[O_wid, O_wip, O_wid_HtmlNames] = wit.io.wip.read(O_wip.File, '-ifall', '-Manager', ...
    '--nopreview', '--Title', 'SELECT NON-DARK', '--Type', 'TDGraph');
if isempty(O_wid), return; end

% Remove the selected dark current from the selection
bw_nondark = all(bsxfun(@ne, [O_wid.Id].', [O_wid_dark.Id]), 2);
O_wid = O_wid(bw_nondark);
O_wid_HtmlNames = O_wid_HtmlNames(bw_nondark);

% Ask if to make copies
makecopies = strncmp(questdlg('Would you like to 1) make copies OR 2) overwrite original?', 'How to proceed?', '1) Make copies', '2) Overwrite original', '1) Make copies'), '1)', 2);

% Remove the dark current
h = waitbar(0, 'Please wait...');
for ii = 1:numel(O_wid),
    if ~ishandle(h), return; end % Abort if cancelled!
    waitbar((ii-1)/numel(O_wid), h, sprintf('Processing data %d/%d. Please wait...', ii, numel(O_wid)));
    if makecopies, O_wid_new = O_wid(ii).copy(); % Make a copy
    else, O_wid_new = O_wid(ii); end % Do not make a copy
    O_wid_new.Data = double(O_wid_new.Data) - dark;
    O_wid_new.Name = sprintf('No Dark<%s', O_wid_new.Name);
end
if ~ishandle(h), return; end % Abort if cancelled!
waitbar(1, h, 'Completed! Writing...');

% Overwrite the file
O_wip.write();

% Close the waitbar
delete(findobj(allchild(0), 'flat', 'Tag', 'TMWWaitbar')); % Avoids the closing issues with close-function!
