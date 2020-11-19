% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function changes to the scripts folder and lists them
function scripts(),
    % Get the toolbox examples folder
    path = fullfile(WITio.path.package, '+scripts');
    fprintf('Changing current folder to the scripts folder of the WITio toolbox:\n%s\n', path);
    
    % Change folder to the toolbox scripts folder
    cd(path);
    
    % Find all script cases
    S = dir(path);
    S = S(~[S.isdir]); % Exclude directories
    [~, names, ext] = cellfun(@fileparts, {S.name}, 'UniformOutput', false);
    names = names(strcmp(ext, '.m')); % Keep *.m files
    
    % List them
    for ii = 1:numel(names),
        fprintf('WITio.scripts.%s\n', names{ii});
    end
end
