% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Prefer toolbox installer (*.mltbx) instead (and its uninstallation)!
function permanent_unload_or_rmpath(toolbox_path, ispermanent),
    if nargin < 1 || isempty(toolbox_path),
        this_script = [mfilename('fullpath') '.m'];
        [root, ~, ~] = fileparts(this_script);
        toolbox_path = root; % This if in the same folder as wit_io
    end
    if nargin < 2, ispermanent = true; end
    toolbox_paths_wo_git = regexprep(genpath(toolbox_path), '[^;]*(?<=\.git)[^;]*;', ''); % Exclude all .git folders from addpath
    rmpath(toolbox_paths_wo_git); % Remove all subfolder dependencies!
    if ispermanent,
        try, savepath; % Permanently save the dependencies (requires Admin-rights!)
        catch, warning('Cannot make permanent changes without Admin-rights!'); end
    end
end

% MANUAL & TEMPORARY WAY: Right-click wit_io's main folder in "Current
% Folder"-view and from the context menu left-click "Remove from Path" and
% "Selected Folders and Subfolders".
