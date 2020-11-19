% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function files = get_dir_files_recursively(folder),
    files = {};
    if nargin == 0, % If no folder is provided, then ask for it
        % Select folder in which to begin recursive search of files
        folder = uigetdir(WITio.pref.get('latest_folder', cd));
        if folder == 0, return; end % Abort as no folder was selected!
        WITio.pref.set('latest_folder', folder);
    end
    S = dir(folder);
    files = cellfun(@(n) fullfile(folder, n), {S(~[S.isdir]).name}, 'UniformOutput', false); % Backward compatible with R2011a
    subfolders = {S([S.isdir]).name};
    for ii = 1:numel(subfolders),
        if strcmp(subfolders{ii}, '.') || strcmp(subfolders{ii}, '..'),
            continue; % Skip . and ..
        end
        files = [files WITio.dev.get_dir_files_recursively(fullfile(folder, subfolders{ii}))];
    end
    files = files(:); % Force column vector
end
