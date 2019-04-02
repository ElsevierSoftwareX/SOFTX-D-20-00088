% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Used by tools\wip_hist.m
function Y = vector_quantile(x, P),
    % Simplified quantile function for backward compability that avoids
    % Statistics and Machine Learning Toolbox. Treats x as vector by
    % forcing it a column vector. Output will be same shape as P. Input can
    % be empty or contain NaN values. Invalid quantiles are treated as NaN
    % values. Input values are converted to a double type.
    % Updated 22.8.2016
    x = double(x(:)); % Force a column vector and a double type
    x = sort(x); % Sort (NaNs will end up last)
    n = sum(~isnan(x)); % Number of non-NaN values
    
    Y = nan(size(P)); % Return values if empty x or no valid data
    if isempty(x) || n == 0, return; end

    % Interpolate quantiles
    P = double(P); % Force a double type
    P(P < 0 | P > 1) = NaN; % Treat invalid quantiles as NaNs
    r = P(:).*n; % The indices (real)
    r_prev = floor(r + 0.5); % The previous index (integer)
    r_next = r_prev + 1; % The next index (integer)
    r = r - r_prev; % The ratio between the previous and the next

    % Truncate the indices to the given range
    r_prev = max(r_prev, 1); % Must be 1 or larger (and handles NaNs)
    r_next = min(r_next, n); % Must be n or smaller (and handles NaNs)

    % Linearly interpolate for the valid quantiles
    Y = (0.5-r).*x(r_prev) + (0.5+r).*x(r_next);

    % Ensure that exact values are copied rather than interpolated
    bw_exact = r == -0.5;
    Y(bw_exact) = x(r_prev(bw_exact));
    
    % Restore Y shape
    Y = reshape(Y, size(P));
end
