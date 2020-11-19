% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function return the folder string of this package.
function path = path(),
    path = fileparts([mfilename('fullpath') '.m']);
end
