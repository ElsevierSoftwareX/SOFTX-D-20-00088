% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function return the WITio.icons package folder.
function path = icons(),
    path = fullfile(WITio.tbx.path.package, '+demo');
end
