% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function gitlab(),
    % Open the toolbox's main url
    url = 'https://gitlab.com/jtholmi/wit_io';
    fprintf('Opening the main page of the WITio toolbox at GitLab:\n%s\n', url);
    web(url, '-browser');
end
