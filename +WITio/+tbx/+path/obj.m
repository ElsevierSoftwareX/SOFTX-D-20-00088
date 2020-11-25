% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function return the WITio.obj package folder.
function path = obj(),
    path = fullfile(WITio.tbx.path.package, '+obj');
end
