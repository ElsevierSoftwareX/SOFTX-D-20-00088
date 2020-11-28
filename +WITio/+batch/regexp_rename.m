% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Renames the selected data names using regexprep-syntax [1].
% [1] https://se.mathworks.com/help/matlab/ref/regexprep.html

% Load and select the datas of interest
[O_wid, O_wip, O_wit] = WITio.read('-ifall', '-batch', '-Manager', ...
    '--all', '--nopreview', '--Title', 'SELECT DATA TO RENAME');
if isempty(O_wid), return; end

O_wid.manager('-nopreview', '-Title', 'SELECTED DATA', '-closepreview');
fig = findall(0, 'tag', 'WITio_project_manager_gcf'); % Works with both figures and uifigures

options = struct();
options.WindowStyle = 'normal'; % Allow interaction with the Project Manager
% Unfortunately, R2019b deactivates Project Manager -window due to a bug in 
% inputdlg's WindowStyle behaviour for uifigures! A bug report (and its
% solution has been filed to MathWorks in 7th February 2020.

% Set regexprep parameters
strs = inputdlg({sprintf('Regexprep ''expression'':'), 'Regexprep ''replace'':'}, 'Input', [1 35; 1 35], {'', ''}, options);
if ishandle(fig), close(fig); end % Close Project Manager if not closed
if isempty(strs), return; end % Stop if cancelled

% Ask if to make copies
makecopies = strncmp(questdlg('Would you like to 1) make copies OR 2) overwrite original?', 'How to proceed?', '1) Make copies', '2) Overwrite original', '1) Make copies'), '1)', 2);

% Renormalize
h = waitbar(0, 'Please wait...');
count = 0;
for ii = 1:numel(O_wid),
    if ~ishandle(h), return; end % Abort if cancelled!
    waitbar((ii-1)/numel(O_wid), h, sprintf('Processing data %d/%d. Please wait...', ii, numel(O_wid)));
    if makecopies, O_wid_new = O_wid(ii).copy(); % Make a copy
    else, O_wid_new = O_wid(ii); end % Do not make a copy
    str_old = O_wid_new.Name;
    str_new = regexprep(str_old, strs{1}, strs{2});
    O_wid_new.Name = str_new;
    if ~strcmp(str_old, str_new),
        fprintf('Renamed ''%s'' to ''%s''\n', str_old, str_new);
        count = count+1;
    end
end
fprintf('Total number of renamed objects: %d\n', count);
if ~ishandle(h), return; end % Abort if cancelled!
waitbar(1, h, 'Completed! Writing...');

% Overwrite the files
for ii = 1:numel(O_wip), O_wip(ii).write(); end

WITio.tbx.delete_waitbars; % Close the waitbar
