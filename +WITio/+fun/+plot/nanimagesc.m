% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Used by @wid\plot.m and WITio.fun.plot.clever_nanimagesc
function h = nanimagesc(varargin),
    % Sets nan values as transparent. Otherwise equivalent to imagesc.
    h = imagesc(varargin{:});
    data = get(h, 'CData');
    set(h, 'AlphaData', ~isnan(data)); % NaN = transparent
end
