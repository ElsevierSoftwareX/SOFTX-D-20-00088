% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Mimics nanmean in order to remove dependency on Statistics and Machine Learning Toolbox.
function y = mynanmean(x, varargin),
    bw_nan = isnan(x);
    x(bw_nan) = 0; % Set NaNs to zero
    y = sum(x, varargin{:})./sum(~bw_nan, varargin{:});
end
