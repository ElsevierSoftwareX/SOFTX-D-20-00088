% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function return the WITio.dev package folder.
function path = dev(),
    path = fullfile(WITio.tbx.path.package, '+dev');
end
