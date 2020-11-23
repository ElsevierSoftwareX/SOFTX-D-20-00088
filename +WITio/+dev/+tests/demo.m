% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function is intended to be ran inside the Code Ocean compute
% capsule, intended to non-interactively demonstrate all the demo cases
% in the toolbox. This can be used to test the toolbox stability as well.
function demo(DemoCases, AutoCloseInSeconds, AutoStopEdit, Verbose),
    if nargin < 1 || isempty(DemoCases), DemoCases = {}; end % By default, go through all demo cases
    if nargin < 2 || isempty(AutoCloseInSeconds), AutoCloseInSeconds = 0; end % By default, auto close without any delay
    if nargin < 3 || isempty(AutoStopEdit), AutoStopEdit = true; end % By default, auto stop editor opening
    if nargin < 4 || isempty(Verbose), Verbose = false; end % By default, less verbose for faster non-interactive mode
    
    old_AutoCloseInSeconds = WITio.tbx.pref.get('AutoCloseInSeconds', Inf);
    WITio.tbx.pref.set('AutoCloseInSeconds', AutoCloseInSeconds);
    ocu = onCleanup(@() WITio.tbx.pref.set('AutoCloseInSeconds', old_AutoCloseInSeconds)); % Restore original value on close
    
    old_AutoStopEdit = WITio.tbx.pref.get('AutoStopEdit', false);
    WITio.tbx.pref.set('AutoStopEdit', AutoStopEdit);
    ocu2 = onCleanup(@() WITio.tbx.pref.set('AutoStopEdit', old_AutoStopEdit)); % Restore original value on close
    
    old_Verbose = WITio.tbx.pref.get('Verbose', true);
    WITio.tbx.pref.set('Verbose', Verbose);
    ocu3 = onCleanup(@() WITio.tbx.pref.set('Verbose', old_Verbose)); % Restore original value on close
    
    % Find all demo cases
    pathstr = WITio.tbx.path.demo;
    S = dir(pathstr);
    S = S(~[S.isdir]); % Exclude directories
    
    files = cellfun(@(n) fullfile(pathstr, n), {S.name}, 'UniformOutput', false); % Backward compatible with R2011a
    [~, names, ext] = cellfun(@fileparts, files, 'UniformOutput', false);
    
    % Keep *.m files
    bw_m_files = strcmp(ext, '.m');
    names = names(bw_m_files);
    files = files(bw_m_files);
    
    % Select demo cases if user has provided such input
    if ischar(DemoCases), DemoCases = {DemoCases}; end % Enclose to a cell
    if ~isempty(DemoCases),
        bw_select = false(size(names));
        for ii = 1:numel(DemoCases),
            bw_select = bw_select | strncmp(names, DemoCases{ii}, numel(DemoCases{ii}));
        end
        names = names(bw_select);
        files = files(bw_select);
    end
    
    % Clear Command Window
    clc;
    
    % Run all demo cases one by one
    isPassed = false(size(names));
    elapsedTimeInSeconds = nan(size(names));
    for ii = 1:numel(names),
        str_msg = 'NON-INTERACTIVE MODE (interruptable with Ctrl+C):';
        str_dashes = repmat('-', [1 max(numel(str_msg), numel(names{ii}))]);
        fprintf('%s\n%s\n%s\n%s\n\n', str_dashes, str_msg, names{ii}, str_dashes);
        tictoc = tic;
        isPassed(ii) = WITio.dev.tests.demo_helper(names{ii});
        elapsedTimeInSeconds(ii) = toc(tictoc);
        fprintf('\n\n');
    end
    
    % Print passed/failed summary in the end
    str_msg = sprintf('PASSED/FAILED SUMMARY for MATLAB %s:', builtin('version'));
    str_dashes = repmat('-', [1 max(numel(str_msg), max(cellfun(@numel, names))+9+17)]);
    fprintf('%s\n%s\n', str_dashes, str_msg);
    for ii = 1:numel(names),
        if isPassed(ii), str_msg_ii = sprintf('Passed in %.4g seconds', elapsedTimeInSeconds(ii)); 
        else, str_msg_ii = 'Failed'; end
        str_spaces_ii = repmat(' ', [1 numel(str_dashes)-numel(names{ii})-1-6-1-17]);
        fprintf('%s:%s%s!\n', names{ii}, str_spaces_ii, str_msg_ii);
    end
    fprintf('Total elapsed time is %.4g seconds.\n', sum(elapsedTimeInSeconds));
    fprintf('%s\n\n', str_dashes);
end
