% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Gets to the toolbox main folder
function cd(),
    WITio_folder = WITio.tbx.path;
    fprintf('Changing current folder to the main folder of the WITio toolbox:\n%s\n', WITio_folder);
    
    % Change folder to the toolbox main folder
    cd(WITio_folder);
end
