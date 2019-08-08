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
% (2) W = all 0 (by default): Any non-negative scalar or array with length
% of ndims(X) or longer. It determines the distance in each dimension that
% how many pixels in the vicinity are included to the rolling window. For
% example, W of all 0, all 1 and all 2 generate window sizes of all 1, all
% 3 and all 5, respectively.
% (3) isCircular = all false (by default): Any boolean scalar or array with
% length of ndims(X) or longer. It determines whether the dimension is
% circular in nature or not, similar to the built-in padarray function. The
% NaN value padding is used when not circular.
% (4) fun(data, dim, ...) = clever_statistics_and_outliers (by default):
% Any anonymous function that takes data as 1st input and dim as 2nd input.
% It will be automatically called for the rolling window analysis dataset
% (with size of [size(X) prod(1+2.*W)]) and the rolling window analysis
% dimension to be reduced (= ndims(X)+1).
% It must also discard NaN values as outliers.
% (5) varargin: Extra parameters to be given to the fun aside the first two
% parameters stated above.

% OUTPUTS:
% (1-Inf) varargout: The fun function outputs.
function varargout = rolling_window_analysis(X, W, isCircular, fun, varargin),
    % Parse input
    if nargin < 4, fun = @clever_statistics_and_outliers; end % Default fun
    if nargin < 3, isCircular = false; end
    if nargin < 2, W = 0; end
    
    % Create a rolling window analysis dataset
    X_RWA = rolling_window_analysis_transformation(X, W, isCircular); % Also tests the input W and isCircular
    
    % Call fun for the dataset
    [varargout{1:nargout}] = fun(X_RWA, ndims(X_RWA), varargin{:}); % fun(data, dim, ...)
end
