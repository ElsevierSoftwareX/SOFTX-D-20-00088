% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function map = colormap_mpl(m, option),
    if nargin < 1, m = []; end % empty by default
    if nargin < 2, option = 'cividis'; end % 'cividis' by default
    warning('You are using a deprecated version! Call WITio.fun.lib.perceptually_uniform_colormap(option, m) instead.');
    map = WITio.fun.lib.perceptually_uniform_colormap(option, m);
end
