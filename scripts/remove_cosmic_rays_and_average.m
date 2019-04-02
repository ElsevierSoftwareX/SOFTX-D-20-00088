% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Use 'clever statistics' to remove occasional cosmic ray spikes from (and
% calculate the mean for) each given Time Series (Fast) measurement.
%
% Algorithm is based on an article written by G. Buzzi-Ferraris and
% F. Manenti: 'Outlier detection in large data sets'
% Source: http://dx.doi.org/10.1016/j.compchemeng.2010.11.004
%
% This interactive script was implemented 24.7.2018 by Joonas Holmi

% Load and select the datas of interest
[C_wid, C_wip, n] = wip.read('-ifall', '-Manager', {'-closepreview', '-Type', 'TDGraph', '-SubType', 'Time'});
if isempty(C_wid), return; end

% Ask if to make copies
makecopies = strncmp(questdlg('Would you like to 1) make copies OR 2) overwrite original?', 'How to proceed?', '1) Make copies', '2) Overwrite original', '1) Make copies'), '1)', 2);

% Remove the cosmic rays
h = waitbar(0, 'Please wait...');
for ii = 1:numel(C_wid),
    if ~ishandle(h), return; end % Abort if cancelled!
    waitbar((ii-1)/numel(C_wid), h, sprintf('Processing data %d/%d. Please wait...', ii, numel(C_wid)));
    if makecopies, C_wid_new = C_wid(ii).copy(); % Make a copy
    else, C_wid_new = C_wid(ii); end % Do not make a copy
    [~, C_wid_new.Data] = clever_statistics_and_outliers(C_wid_new.Data, 1, 4);
    C_wid_new.SubType = 'Point';
    C_wid_new.Name = sprintf('Clever Mean<%s', C_wid_new.Name);
end
if ~ishandle(h), return; end % Abort if cancelled!
waitbar(1, h, 'Completed! Writing...');

% Overwrite the file
C_wip.write();

% Close the waitbar
delete(findobj(allchild(0), 'flat', 'Tag', 'TMWWaitbar')); % Avoids the closing issues with close-function!
