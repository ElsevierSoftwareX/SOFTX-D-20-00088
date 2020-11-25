% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function return the WITio.tbx package folder.
function path = tbx(),
    path = fullfile(WITio.tbx.path.package, '+tbx');
end
