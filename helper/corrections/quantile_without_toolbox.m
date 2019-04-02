% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Used by helper\nanmedian_without_toolbox.m
function Y = quantile_without_toolbox(X, p, dim),
    % Mimics built-in quantile, which requires Statistics and Machine
    % Learning Toolbox. Input values are converted to double-type.
    % Updated 12.3.2019
    if ~isscalar(p) || p < 0 || p > 1,
        error('Cumulative probability value, p must be a scalar [0, 1]!');
    end
    X = dim_first_permute(double(X), dim); % Minor bottleneck
    S = size(X);
    X = sort(X(:,:), 1); % Sort first dimension (NaNs will end up last) % Major bottleneck
    S2 = size(X);
    n = sum(~isnan(X), 1); % Number of non-NaN values % Minor bottleneck
    bw_zero = n == 0;
    
    Y = nan(size(n)); % Return values if empty x or no valid data
    if isempty(X) || all(bw_zero), return; end
    
    % Interpolate quantiles
    ind = 1:numel(n);
    r = p.*n; % The indices (real)
    r_prev = floor(r + 0.5); % The previous index (integer)
    r_next = r_prev + 1; % The next index (integer)
    r = r - r_prev; % The ratio between the previous and the next
    
    % Truncate the indices to the given range
    r_prev = max(r_prev, 1); % Must be 1 or larger
    r_next = min(r_next, n); % Must be n or smaller
    
    % From subindices to indices
    r_prev = r_prev + S2(1).*(ind-1);
    r_next = r_next + S2(1).*(ind-1);
    
    % Ensure that indexing is performed only for non-empty datasets
    bw_nz = n ~= 0;
    r = r(bw_nz);
    r_prev = r_prev(bw_nz);
    r_next = r_next(bw_nz);
    
    % Calculate either an exact median or an interpolated median
    Y(bw_nz) = (0.5-r).*X(r_prev) + (0.5+r).*X(r_next); % Best speed performance
%     Y(bw_nz) = X(r_prev) + (0.5+r).*(X(r_next)-X(r_prev)); % Alternative
    
    % Restore y shape
    Y = dim_first_ipermute(reshape(Y, [1 S(2:end)]), dim);
end
