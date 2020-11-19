% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function return the WITio package folder.
function path = package(),
    path = fileparts([mfilename('fullpath') '.m']);
    path = regexprep(path, '[\\\/]+\+[^\\\/]*$', ''); % Step back one package '+'-prefixed folder
end
