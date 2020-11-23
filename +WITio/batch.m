% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function changes to the batch folder and lists all the batch cases
function batch(),
    % Get the toolbox batch folder
    path = WITio.tbx.path.batch;
    fprintf('Changing current folder to the batch folder of the WITio toolbox:\n%s\n', path);
    
    % Change folder to the toolbox batch folder
    cd(path);
    
    % Find all batch cases
    S = dir(path);
    S = S(~[S.isdir]); % Exclude directories
    [~, names, ext] = cellfun(@fileparts, {S.name}, 'UniformOutput', false);
    names = names(strcmp(ext, '.m')); % Keep *.m files
    
    % List them
    for ii = 1:numel(names),
        fprintf('WITio.batch.%s\n', names{ii});
    end
end
