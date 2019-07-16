% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Renames the selected data names using regexprep-syntax [1].
% [1] https://se.mathworks.com/help/matlab/ref/regexprep.html

% This interactive script was implemented 29.5.2019 by Joonas Holmi

% Load and select the datas of interest
[O_wid, O_wip, O_wid_HtmlNames] = wip.read('-ifall', '-Manager', ...
    {'-all', '-nopreview', '-Title', 'SELECT DATA TO RENAME'});
if isempty(O_wid), return; end

% Set regexprep parameters
strs = inputdlg({sprintf('i.e. ''%s''\n\n%s', O_wid(1).Name, 'Regexprep ''expression'':'), 'Regexprep ''replace'':'}, 'Input', [1 35; 1 35], {'', ''});
if isempty(strs), return; end % Stop if cancelled

% Ask if to make copies
makecopies = strncmp(questdlg('Would you like to 1) make copies OR 2) overwrite original?', 'How to proceed?', '1) Make copies', '2) Overwrite original', '1) Make copies'), '1)', 2);

% Renormalize
h = waitbar(0, 'Please wait...');
for ii = 1:numel(O_wid),
    if ~ishandle(h), return; end % Abort if cancelled!
    waitbar((ii-1)/numel(O_wid), h, sprintf('Processing data %d/%d. Please wait...', ii, numel(O_wid)));
    if makecopies, O_wid_new = O_wid(ii).copy(); % Make a copy
    else, O_wid_new = O_wid(ii); end % Do not make a copy
    O_wid_new.Name = regexprep(O_wid_new.Name, strs{1}, strs{2});
end
if ~ishandle(h), return; end % Abort if cancelled!
waitbar(1, h, 'Completed! Writing...');

% Overwrite the file
O_wip.write();

% Close the waitbar
delete(findobj(allchild(0), 'flat', 'Tag', 'TMWWaitbar')); % Avoids the closing issues with close-function!
