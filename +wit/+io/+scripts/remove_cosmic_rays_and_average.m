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
[O_wid, O_wip, O_wid_HtmlNames] = wit.io.read('-ifall', '-Manager', '--closepreview', '--Type', 'TDGraph', '--SubType', 'Time');
if isempty(O_wid), return; end

% Ask if to make copies
makecopies = strncmp(questdlg('Would you like to 1) make copies OR 2) overwrite original?', 'How to proceed?', '1) Make copies', '2) Overwrite original', '1) Make copies'), '1)', 2);

% Remove the cosmic rays
h = waitbar(0, 'Please wait...');
for ii = 1:numel(O_wid),
    if ~ishandle(h), return; end % Abort if cancelled!
    waitbar((ii-1)/numel(O_wid), h, sprintf('Processing data %d/%d. Please wait...', ii, numel(O_wid)));
    if makecopies, O_wid_new = O_wid(ii).copy(); % Make a copy
    else, O_wid_new = O_wid(ii); end % Do not make a copy
    [~, O_wid_new.Data] = wit.io.fun.clever_statistics_and_outliers(O_wid_new.Data, 1, 4);
    O_wid_new.SubType = 'Point';
    O_wid_new.Name = sprintf('Clever Mean<%s', O_wid_new.Name);
end
if ~ishandle(h), return; end % Abort if cancelled!
waitbar(1, h, 'Completed! Writing...');

% Overwrite the file
O_wip.write();

% Close the waitbar
delete(findobj(allchild(0), 'flat', 'Tag', 'TMWWaitbar')); % Avoids the closing issues with close-function!
