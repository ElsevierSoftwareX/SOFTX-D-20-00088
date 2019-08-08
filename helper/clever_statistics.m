% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% A wrapper function for backward compatibility purposes only. This was
% implemented only for the old users, who are still using this old version.
function [cmean, cvar, bwOut, cmin, cmax] = clever_statistics(X, delta, dim),
    if nargin < 2 || isempty(delta), delta = 2.5; end
    if nargin < 3, dim = []; end
    warning('You are using a deprecated version! Use clever_statistics_and_outliers.m instead.');
    [bwOut, cmean, cvar, ~, ~, cmin, cmax] = ...
        clever_statistics_and_outliers(X, dim, delta);
end
