% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function h = clever_nanimagesc(varargin),
    h = wit.io.fun.plot.nanimagesc(varargin{:});
    data = get(h, 'CData');
    
    % Clever caxis
    [~, ~, ~, ~, ~, cmin, cmax] = wit.io.fun.clever_statistics_and_outliers(data(~isinf(data)), [], 4);
    if ~isnan(cmin) && ~isnan(cmax) && cmin ~= cmax,
        caxis([cmin cmax]);
    end
end
