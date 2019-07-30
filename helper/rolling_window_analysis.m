% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% The rolling window analysis filters the given dataset by applying the
% specified function on each rolling window dataset.

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
% (3) fun(data, dim, ...) = clever_statistics_and_outliers (by default):
% Any anonymous function that takes data as 1st input and dim as 2nd input.
% It will be automatically called for the rolling window analysis dataset
% (with size of [prod(1+2.*W) numel(X)]) and the dim to be reduced (= 1).
% It must also discard NaN values as outliers.
% (4) varargin: Extra parameters to be given to the fun aside the first two
% parameters stated above.

% OUTPUTS:
% (1-Inf) varargout: The fun function outputs reshaped to the original
% input X shape only if they have sizes consistent with the given rolling
% window analysis dataset. The reshaped size will be either size(X) or
% [size(X) prod(1+2.*W)].
function varargout = rolling_window_analysis(X, W, fun, varargin),
    % Get input X main properties
    D = ndims(X);
    S = size(X);
    N = prod(S);
    
    % Parse input
    if nargin < 3, fun = @clever_statistics_and_outliers; end % Default fun
    if nargin < 2, W = 0; end
    if numel(W) ~= 1 && numel(W) ~= D, error('Input W must have length of 1 or ndims(X) = %d!', D); end
    if any(W(:) < 0), error('Input W elements must not be negative!'); end
    if numel(W) == 1, W = repmat(W, size(S)); end % SPECIAL CASE: Convert scalar W to array W
    
    % Get input W main properties
    S_W = 1 + 2.*W;
    N_W = prod(S_W);
    
    % Create NaN-padded array
    S_pad = S + 2.*W;
    C_subind = arrayfun(@(w, s_pad, n) permute(reshape(w+1:s_pad-w, [], 1), [2:n+1 1]), W, S_pad, 1:D, 'UniformOutput', false);
    D_pad = nan(S_pad); % Preallocate with NaNs
    D_pad(C_subind{:}) = X;
    
    % Generate subindices to the window region
    C_subind_window = arrayfun(@(w) -w:w, W, 'UniformOutput', false);
    [C_subind_window{:}] = ndgrid(C_subind_window{:});
    
    % Generate indices to the padded array in memory conservative way
    ind_pad = uint32(1);
    for ii = 1:D,
        subind_pad = uint32(bsxfun(@plus, C_subind_window{ii}(:), C_subind{ii}));
        dim_multiplier = uint32(prod(S_pad(1:ii-1)));
        ind_pad = bsxfun(@plus, ind_pad, (subind_pad-1).*dim_multiplier);
    end
    
    % Create a rolling window analysis dataset
    X_RWA = D_pad(ind_pad(:,:)); % Generate a 2-D matrix
    clear ind_pad; % Conserve memory
    
    % Call fun for the dataset
    [varargout{1:nargout}] = fun(X_RWA, 1, varargin{:}); % fun(data, dim, ...)
    
    % Try reshaping output to the original shapes only if result is one of
    % the two expected output sizes
    for ii = 1:nargout,
        S_ii = size(varargout{ii});
        if numel(S_ii) == 2, % Test dimensional consistency with the X_RWA input
            if all(S_ii == [1 N]), % If same size as X_RWA reduced
                varargout{ii} = reshape(varargout{ii}, S);
            elseif all(S_ii == [N_W N]), % If same size as X_RWA
                varargout{ii} = permute(reshape(varargout{ii}, [N_W S]), [2:D+1 1]);
            end
        end
    end
end
