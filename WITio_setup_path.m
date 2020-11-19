% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Prefer toolbox installer (*.mltbx) instead when using R2014b or newer!
% Nevertheless, this is safe to call and will also remove all the previous
% versions of this toolbox from the path.
function WITio_setup_path(),
    % Remove previous versions of this toolbox from path
    p = path; % Get old path
    p = regexprep(p, ['[^\' pathsep ']*\' filesep 'wit_io' '\' filesep '?[^\' pathsep ']*\' pathsep '?'], ''); % Remove any mention of wit_io
    path(p); % Set new path
    
    % Add this toolbox to path
    [toolbox_path, ~, ~] = fileparts([mfilename('fullpath') '.m']);
    addpath(toolbox_path); % Then add this toolbox
    
    % Try permanently save the new path (and it may require Admin-rights!)
    try, savepath;
    catch, warning('Cannot make permanent changes without Admin-rights!'); end
end
