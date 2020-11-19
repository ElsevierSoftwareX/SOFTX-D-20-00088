% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Used by WITio.fun.correct.apply_MDLCA
function Y = nanmedian_without_toolbox(X, dim),
    % Mimics built-in nanmedian, which requires Statistics and Machine
    % Learning Toolbox. Input values are converted to double-type.
    Y = WITio.fun.correct.quantile_without_toolbox(X, 0.5, dim);
end
