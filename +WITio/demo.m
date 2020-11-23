% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function changes to the demo folder and lists all the demo cases
function demo(),
    % Get the toolbox demo folder
    path = WITio.tbx.path.demo;
    fprintf('Changing current folder to the demo folder of the WITio toolbox:\n%s\n', path);
    
    % Change folder to the toolbox demo folder
    cd(path);
    
    % Find all demo cases
    S = dir(path);
    S = S(~[S.isdir]); % Exclude directories
    [~, names, ext] = cellfun(@fileparts, {S.name}, 'UniformOutput', false);
    names = names(strcmp(ext, '.m')); % Keep *.m files
    
    % List them
    for ii = 1:numel(names),
        fprintf('WITio.demo.%s\n', names{ii});
    end
end
