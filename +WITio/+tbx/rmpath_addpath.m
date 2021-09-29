% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Prefer toolbox installer (*.mltbx) instead when using R2014b or newer!
% Nevertheless, this is safe to call and will also remove all the previous
% versions of this toolbox from the path.
function rmpath_addpath(folder_latest_WITio), %#ok % Remove previous versions of this toolbox from path
    fprintf('\nRemoving the old WITio toolbox folders from the MATLAB path if found...\n');
    p = path; % Get old path
    p = regexprep(p, ['[^\' pathsep ']*\' filesep '(wit_io|WITio)' '\' filesep '?[^\' pathsep ']*\' pathsep '?'], ''); % Remove any mention of wit_io
    path(p); % Set new path
    
    % Add this toolbox to path
    fprintf('Adding the new WITio toolbox folder to the MATLAB path if not found...\n');
    addpath(folder_latest_WITio); % Then add this toolbox
    addpath(genpath(fullfile(folder_latest_WITio, 'third party'))); % And its 3rd party libraries
    
    % Try permanently save the new path (and it may require Admin-rights!)
    try, %#ok
        status = savepath;
        if status == 0, fprintf('Changes saved permanently!\n');
        else, warn_about_admin_rights; end
    catch, warn_about_admin_rights; end
    
    function warn_about_admin_rights(),
        % Temporarily disable backtrace
        prev_state = warning('query', 'backtrace');
        warning('off', 'backtrace');
        reset_warning_onCleanup = onCleanup(@() warning(prev_state));
        % Then warn without backtrace
        warning('Cannot make permanent changes without Admin-rights!');
    end
end
