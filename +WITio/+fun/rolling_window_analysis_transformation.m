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
% (2) W = all 0 (by default): Any non-negative scalar or array with length
% of ndims(X) or longer. It determines the distance in each dimension that
% how many pixels in the vicinity are included to the rolling window. For
% example, W of all 0, all 1 and all 2 generate window sizes of all 1, all
% 3 and all 5, respectively.
% (3) isCircular = all false (by default): Any boolean scalar or array with
% length of ndims(X) or longer. It determines whether the dimension is
% circular in nature or not, similar to the built-in padarray function. The
% NaN value padding is used when not circular.

% OUTPUTS:
% (1) X_RWA <double>: The rolling window analysis dataset with size of
% [size(X) prod(1+2.*W)]. Treat NaN values as outliers.
% (2) ind_RWA <uint32>: The rolling window analysis indices pointing back to
% X. Zeros are references to a NaN padding values and should be removed
% before using this on X.
%   EXAMPLE: X_RWA(ind_RWA>0) = X(ind_RWA(ind_RWA>0));
function [X_RWA, ind_RWA] = rolling_window_analysis_transformation(X, W, isCircular),
    % Get input X main properties
    D = ndims(X);
    S = size(X);
    
    % Test W input
    if nargin < 2, W = 0; end
    if numel(W) ~= 1 && numel(W) < ndims(X),
        error('Input W must have length of 1 or ndims(X) >= %d!', D);
    end
    if any(W(:) < 0),
        error('Input W elements must not be negative!');
    end
    if numel(W) == 1, W = repmat(W, size(S)); end % SPECIAL CASE: From scalar to array
    
    % Test isCircular input
    if nargin < 3, isCircular = false; end
    if numel(isCircular) ~= 1 && numel(isCircular) < ndims(X),
        error('Input isCircular must have length of 1 or ndims(X) >= %d!', D);
    end
    if numel(isCircular) == 1, isCircular = repmat(isCircular, size(W)); end % SPECIAL CASE: From scalar to array
    
    % Obey input W
    D = numel(W);
    S(end+1:D) = 1; % Pad with ones
    
    % Create (initially) NaN-padded array
    S_pad = S + 2.*W;
    D_pad = nan(S_pad); % Preallocate with NaNs
    
    % Generate indices to the original dataset in memory conservative way
    ind = uint32(1);
    B_nan = false;
    for ii = 1:D,
        subind_pad_ii = permute(reshape(1:S_pad(ii), [], 1), [2:ii 1 ii+1]);
        subind_ii = uint32(mod(subind_pad_ii-1-W(ii), S(ii))+1);
        dim_multiplier = uint32(prod(S(1:ii-1)));
        ind = bsxfun(@plus, ind, (subind_ii-1).*dim_multiplier);
        % Determine circularity
        B_nan_ii = ~isCircular(ii) & (subind_pad_ii < 1+W(ii) | subind_pad_ii > S(ii)+W(ii));
        B_nan = bsxfun(@or, B_nan, B_nan_ii);
    end
    ind(B_nan) = 0; % Set non-circular to NaNs
    
%     ind = WITio.fun.generic_sub2ind(S, subinds{:}, 'uint32', '-circulate', isCircular, '-isarray');
    
    % Generate either NaN-padded or circularly-padded array (depending on
    % isCircular values)
    D_pad(~B_nan) = X(ind(~B_nan));
    
    % Generate subindices to the window region
    C_subind_window = arrayfun(@(w) -w:w, W, 'UniformOutput', false);
    [C_subind_window{:}] = ndgrid(C_subind_window{:});
    
    % Generate indices to the padded array in memory conservative way
    ind_pad = uint32(1);
    for ii = 1:D,
        subind_pad_ii = permute(reshape(W(ii)+1:S_pad(ii)-W(ii), [], 1), [2:ii 1 ii+1]);
        subind_RW_ii = permute(C_subind_window{ii}(:), [2:D+1 1]);
        subind_pad_RW_ii = uint32(bsxfun(@plus, subind_RW_ii, subind_pad_ii));
        dim_multiplier = uint32(prod(S_pad(1:ii-1)));
        ind_pad = bsxfun(@plus, ind_pad, (subind_pad_RW_ii-1).*dim_multiplier);
    end
    
%     ind_pad = WITio.fun.generic_sub2ind(S_pad, subinds_pad{:}, 'uint32', '-isarray');
    
    % Create a rolling window analysis dataset
    X_RWA = D_pad(ind_pad); % Generate a 2-D matrix
    
    % Generate indices back to X if requested
    if nargout > 1,
        ind_RWA = ind(ind_pad);
    end
end
