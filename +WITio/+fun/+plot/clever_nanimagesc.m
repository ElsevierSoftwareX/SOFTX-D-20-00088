% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function h = clever_nanimagesc(varargin),
    h = WITio.fun.plot.nanimagesc(varargin{:});
    data = get(h, 'CData');
    
    % Clever caxis
    [~, ~, ~, ~, ~, cmin, cmax] = WITio.fun.clever_statistics_and_outliers(data(~isinf(data)), [], 4);
    if ~isnan(cmin) && ~isnan(cmax) && cmin ~= cmax,
        caxis([cmin cmax]);
    end
end
