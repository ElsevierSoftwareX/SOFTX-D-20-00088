% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Prefer toolbox installer (*.mltbx) instead when using R2014b or newer!
% Nevertheless, this is safe to call and will also remove all the previous
% versions of this toolbox from the path.
function WITio_rmpath_addpath(),% Remove previous versions of this toolbox from path
    fprintf('Removing the old WITio toolbox folders from MATLAB path if found...\n');
    p = path; % Get old path
    p = regexprep(p, ['[^\' pathsep ']*\' filesep '(wit_io|WITio)' '\' filesep '?[^\' pathsep ']*\' pathsep '?'], ''); % Remove any mention of wit_io
    path(p); % Set new path
    
    % Add this toolbox to path
    [toolbox_path, ~, ~] = fileparts([mfilename('fullpath') '.m']);
    fprintf('Adding the new WITio toolbox folder to MATLAB path...\n%s\n', toolbox_path);
    addpath(toolbox_path); % Then add this toolbox
    
    % Try permanently save the new path (and it may require Admin-rights!)
    try, savepath; fprintf('Changes saved permanently!\n');
    catch, warning('Cannot make permanent changes without Admin-rights!'); end
end
