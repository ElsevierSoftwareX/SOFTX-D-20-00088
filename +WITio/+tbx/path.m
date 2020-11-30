% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function returns the WITio toolbox folder.
function path = path(),
    path = fileparts([mfilename('fullpath') '.m']);
    path = regexprep(path, '([\\\/]+\+[^\\\/]*)+$', ''); % Step back the package '+'-prefixed folders
end
