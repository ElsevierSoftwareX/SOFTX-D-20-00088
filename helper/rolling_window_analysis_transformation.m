% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% The rolling window analysis transformation of the given dataset via
% linear indexing using the specified window size.

% NOTE: There are significant performance and memory bottlenecks due to the
% use of linear indexing. This may cause either out of memory or slow
% processing times.

% INPUTS:
% (1) X: Any N-D matrix.
% (2) W = all 0 (by default): Any non-negative array with length of
% 1 or ndims(X). It determines the distance in each dimension that how many
% pixels in the vicinity are included to the rolling window. For example,
% W of all 0, all 1 and all 2 generate window sizes of all 1, all 3 and all
% 5, respectively.

% OUTPUTS:
% (1) X_RWA <double>: The rolling window analysis dataset with size of
% [size(X) prod(1+2.*W)]. Treat NaN values as outliers.
% (2) ind_RWA <uint32>: The rolling window analysis indices pointing back to
% X. Zeros are references to a NaN padding values and should be removed
% before using this on X.
%   EXAMPLE: X_RWA(ind_RWA>0) = X(ind_RWA(ind_RWA>0));
function [X_RWA, ind_RWA] = rolling_window_analysis_transformation(X, W),
    % Get input X main properties
    N = numel(X);
    D = ndims(X);
    S = size(X);
    
    % Test input
    if nargin < 2, W = 0; end
    if numel(W) ~= 1 && numel(W) < ndims(X),
        error('Input W must have length of 1 or ndims(X) >= %d!', D);
    end
    if any(W(:) < 0),
        error('Input W elements must not be negative!');
    end
    if numel(W) == 1, W = repmat(W, size(S)); end % SPECIAL CASE: From scalar to array
    
    % Obey input W
    D = numel(W);
    S(end+1:D) = 1; % Pad with ones
    
    % Create NaN-padded array
    S_pad = S + 2.*W;
    C_subind = arrayfun(@(w, s_pad, n) permute(reshape(w+1:s_pad-w, [], 1), [2:n 1 n+1]), W, S_pad, 1:D, 'UniformOutput', false);
    D_pad = nan(S_pad); % Preallocate with NaNs
    D_pad(C_subind{:}) = X;
    
    % Generate subindices to the window region
    C_subind_window = arrayfun(@(w) -w:w, W, 'UniformOutput', false);
    [C_subind_window{:}] = ndgrid(C_subind_window{:});
    
    % Generate indices to the padded array in memory conservative way
    ind_pad = uint32(1);
    for ii = 1:D,
        subind_pad = uint32(bsxfun(@plus, permute(C_subind_window{ii}(:), [2:D+1 1]), C_subind{ii}));
        dim_multiplier = uint32(prod(S_pad(1:ii-1)));
        ind_pad = bsxfun(@plus, ind_pad, (subind_pad-1).*dim_multiplier);
    end
    
    % Create a rolling window analysis dataset
    X_RWA = D_pad(ind_pad); % Generate a 2-D matrix
    
    % Generate indices back to X if requested
    if nargout > 1,
        I_pad = zeros(S_pad, 'uint32');
        I_pad(C_subind{:}) = reshape(uint32(1:N), S);
        ind_RWA = I_pad(ind_pad);
    end
end
