% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [P, R2, SSres, Y_fit, R2_total, SSres_total] = fit_lineshape_lorentzian(x, Y, P0, dim, varargin),
    % Lorentzian lineshape fitting
    % P(1,:) = Intensity, P(2,:) = Pos, P(3,:) = Fwhm, P(4,:) = Offset
    [P, R2, SSres, Y_fit, R2_total, SSres_total] = WITio.fun.fit.fit_lineshape_arbitrary(@WITio.fun.fit.fun_lineshape_lorentzian, x, Y, P0, dim, varargin{:});
end
