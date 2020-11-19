% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function returns the base folder string of this package.
function path = basepath(),
    path = regexprep(WITio.path, '([\\\/]+\+[^\\\/]*)+$', ''); % Step back the package folders
end
