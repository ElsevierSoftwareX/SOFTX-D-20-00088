% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% If varargin{1} is a cell, then it is treated as an input to the fitting algorithm!
function [new_obj, I, Pos, Fwhm, I0, R2, Residuals, Fit] = filter_gaussian(obj, varargin),
    % Test if the first varargin element is a cell, which would be an input
    % to the underlying 'fit_lineshape_arbitrary.m' fitting algorithm!
    opts = {};
    if numel(varargin) >= 1 && iscell(varargin{1}),
        opts = varargin{1};
        varargin = varargin(2:end);
    end
    
    str_fun = {'I<Gauss', 'Pos<Gauss', 'Fwhm<Gauss', 'I0<Gauss', 'R^2<Gauss', 'Residuals<Gauss', 'Fit<Gauss'};
    [new_obj, I, Pos, Fwhm, I0, R2, Residuals, Fit] = obj.filter_fun(@fun, str_fun, varargin{:});
    
    function [F, I_new] = fun(I, X, dim),
        P0 = wit.io.fun.fit.fit_lineshape_automatic_guess(X, I, dim);
        [P, R2, SSres, Y_fit] = wit.io.fun.fit.fit_lineshape_gaussian(X, I, P0, dim, opts{:});
        F = cat(dim, P, R2, SSres);
        I_new = Y_fit; % Tell filter_fun to create a new TDGraph for this
    end
end
