% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function is intended to be ran only inside the Code Ocean compute
% capsule, intended to non-interactively demonstrate all the example cases
% in the toolbox.
function wit_io_for_code_ocean_compute_capsule(AutoCloseInSeconds),
    if nargin == 0, AutoCloseInSeconds = 0; end % By default, auto close without any delay
    wit_io_pref_set('AutoCloseInSeconds', AutoCloseInSeconds);
    ocu = onCleanup(@() wit_io_pref_set('AutoCloseInSeconds', Inf)); % Restore original value on close
    
    % Find all example cases
    pathstr = fileparts([mfilename('fullpath') '.m']);
    S = dir(fullfile(pathstr, 'EXAMPLE cases'));
    S = S(~[S.isdir]); % Exclude directories
    names = {S.name};
    [~, names, ext] = cellfun(@fileparts, names, 'UniformOutput', false);
    names = names(strcmp(ext, '.m')); % Keep *.m files
    
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
        isPassed(ii) = wit_io_for_code_ocean_compute_capsule_helper(names{ii});
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