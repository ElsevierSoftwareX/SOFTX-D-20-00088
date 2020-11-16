% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function is intended to be ran inside the Code Ocean compute
% capsule, intended to non-interactively demonstrate all the example cases
% in the toolbox. This can be used to test the toolbox stability as well.
function examples(AutoCloseInSeconds, ExampleCases, AutoStopEdit, Verbose),
    if nargin < 1 || isempty(AutoCloseInSeconds), AutoCloseInSeconds = 0; end % By default, auto close without any delay
    if nargin < 2 || isempty(ExampleCases), ExampleCases = {}; end % By default, go through all example cases
    if nargin < 3 || isempty(AutoStopEdit), AutoStopEdit = true; end % By default, auto stop editor opening
    if nargin < 4 || isempty(Verbose), Verbose = false; end % By default, less verbose for faster non-interactive mode
    
    old_AutoCloseInSeconds = wit.io.pref.get('AutoCloseInSeconds', Inf);
    wit.io.pref.set('AutoCloseInSeconds', AutoCloseInSeconds);
    ocu = onCleanup(@() wit.io.pref.set('AutoCloseInSeconds', old_AutoCloseInSeconds)); % Restore original value on close
    
    old_AutoStopEdit = wit.io.pref.get('AutoStopEdit', false);
    wit.io.pref.set('AutoStopEdit', AutoStopEdit);
    ocu2 = onCleanup(@() wit.io.pref.set('AutoStopEdit', old_AutoStopEdit)); % Restore original value on close
    
    old_Verbose = wit.io.pref.get('Verbose', true);
    wit.io.pref.set('Verbose', Verbose);
    ocu3 = onCleanup(@() wit.io.pref.set('Verbose', old_Verbose)); % Restore original value on close
    
    % Find all example cases
    pathstr = fullfile(wit.io.path, '+examples');
    S = dir(pathstr);
    S = S(~[S.isdir]); % Exclude directories
    
    files = fullfile(pathstr, {S.name});
    [~, names, ext] = cellfun(@fileparts, files, 'UniformOutput', false);
    
    % Keep *.m files
    bw_m_files = strcmp(ext, '.m');
    names = names(bw_m_files);
    files = files(bw_m_files);
    
    % Select example cases if user has provided such input
    if ischar(ExampleCases), ExampleCases = {ExampleCases}; end % Enclose to a cell
    if ~isempty(ExampleCases),
        bw_select = false(size(names));
        for ii = 1:numel(ExampleCases),
            bw_select = bw_select | strncmp(names, ExampleCases{ii}, numel(ExampleCases{ii}));
        end
        names = names(bw_select);
        files = files(bw_select);
    end
    
    % Clear Command Window
    clc;
    
    % Run all examples cases one by one
    isPassed = false(size(names));
    elapsedTimeInSeconds = nan(size(names));
    for ii = 1:numel(names),
        str_msg = 'NON-INTERACTIVE MODE (interruptable with Ctrl+C):';
        str_dashes = repmat('-', [1 max(numel(str_msg), numel(names{ii}))]);
        fprintf('%s\n%s\n%s\n%s\n\n', str_dashes, str_msg, names{ii}, str_dashes);
        tictoc = tic;
        isPassed(ii) = wit.io.tests.examples_helper(names{ii});
        elapsedTimeInSeconds(ii) = toc(tictoc);
        fprintf('\n\n');
    end
    
    % Print passed/failed summary in the end
    str_msg = 'PASSED/FAILED SUMMARY:';
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
