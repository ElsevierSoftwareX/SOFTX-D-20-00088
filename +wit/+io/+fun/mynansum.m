% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Mimics nansum in order to remove dependency on Statistics and Machine Learning Toolbox.
function y = mynansum(x, varargin),
    x(isnan(x)) = 0; % Set NaNs to zero
    y = sum(x, varargin{:});
end
