% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Used by wit.io.fun.correct.apply_MDLCA
function Y = nanmedian_without_toolbox(X, dim),
    % Mimics built-in nanmedian, which requires Statistics and Machine
    % Learning Toolbox. Input values are converted to double-type.
    Y = wit.io.fun.correct.quantile_without_toolbox(X, 0.5, dim);
end
