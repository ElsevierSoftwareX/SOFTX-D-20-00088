% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Used by WITio.fun.image.apply_MDLCA
function Y = mynanmedian(X, dim),
    % Mimics built-in nanmedian, which requires Statistics and Machine
    % Learning Toolbox. Input values are converted to double-type.
    Y = WITio.fun.indep.myquantile(X, 0.5, dim);
end
