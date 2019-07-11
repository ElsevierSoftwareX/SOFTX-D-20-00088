% BSD 3-Clause License
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% * Redistributions of source code must retain the above copyright notice, this
%   list of conditions and the following disclaimer.
% 
% * Redistributions in binary form must reproduce the above copyright notice,
%   this list of conditions and the following disclaimer in the documentation
%   and/or other materials provided with the distribution.
% 
% * Neither the name of Aalto University nor the names of its
%   contributors may be used to endorse or promote products derived from
%   this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function [isOutlier, cmean, cvar, cstd, cmedian, cmin, cmax, sigmas] = ...
    clever_statistics_and_outliers(X, dim, delta)
    % An iterative and robust clever-variance-based outlier detection
    % scheme by G. Buzzi-Ferraris and F. Manenti (2011) [1] was implemented
    % in order to simultaneously evaluate mean, variance, minimum, maximum,
    % median, std and outliers.
    
    % INPUTS:
    % (1) X: Any N-D matrix of numeric or logical data. Any NaN or Inf
    % values are treated as outliers and ignored in the evaluations.
    % (2) dim = [] (by default): Determines which dimension of X is to be
    % treated as a single set of observations. If set to [], then all data
    % in X is treated as a single set of observations.
    % (3) delta = 2.5 (by default): Free threshold parameter. It determines
    % maximum allowed deviation (in sigmas) from the mean before treating a
    % data point as an outlier. The larger the threshold, the smaller the
    % chance to detect outliers. It is recommended to try values 2.5 - 4.
    
    % OUTPUTS:
    % (1) isOutlier: Boolean array with same dimensions as the input X.
    % (2-7) cmean, cvar, cmin, cmax, cmedian, cstd: These estimators are
    % (almost) always double and they are reshaped to resemble the input X.
    % In rare occasitions, cvar < 0 and is unreliable due to remaining
    % numerical errors, what makes cstd to become complex.
    % (8) sigmas: Distance-in-sigmas-from-cmean array with same dimensions
    % as the input X.
    
    % THE OUTLIER DETECTION IN A NUTSHELL (after sorting the observations):
    % The clever variance decreases monotonically for each removed outlier.
    % It is nearly constant or increases if a real observation is removed.
    
    % ASSUMPTIONS ABOUT THE OBSERVATIONS:
    % The clever statistics are robust estimators for a large number of
    % observations with a UNIMODAL SYMMETRICAL distribution of an unknown
    % expected value, mu and variance, sigma^2. Asymmetrically or multimodally
    % distributed observations cannot reliably undergo this analysis.
    
    % References:
    % [1] G. Buzzi-Ferraris and F. Manenti (2011), 'Outlier detection in
    % large data sets', http://dx.doi.org/10.1016/j.compchemeng.2010.11.004
    
    % EXAMPLE: For dataset below, indices 6, 11 and 2 are outliers.
    % X   = [31.1 31.6 31.2 31.2 31.3 311.1 31.3 31.1 31.4 31.3 32.1 31.0];
    % OUT = [0    1    0    0    0    1     0    0    0    0    1    0   ];
    
    % This was written, tested and optimized for MATLAB R2010b-R2018b using
    % the built-in functions and does not require any toolboxes to be used.
    
    % Updated 11.7.2019
    
    % ---------------------------------------------------------------------
    
    % PERFORMANCE: ~5x slower than mean/var/std/median/min/max -combo:
%     X = randn(5000, 5000);
%     dim = 1;
%     tic;
%     cmean0 = mean(X, dim);
%     cvar0 = var(X, [], dim);
%     cstd0 = sqrt(cvar0);
%     cmedian0 = median(X, dim);
%     cmin0 = min(X, [], dim);
%     cmax0 = max(X, [], dim);
%     t1 = toc;
%     tic;
%     [~, cmean, cvar, cstd, cmedian, cmin, cmax, ~] = ...
%         clever_statistics_and_outliers(X, dim, inf);
%     t2 = toc;
%     t2/t1
    
    % SOME NOTES ON OPTIMIZATIONS:
    % (*) Optimized version avoids extra numerical truncation errors by
    % calculating partial sums in advance by using highly optimized cumsum!
    % (*) Due to vectorization and extra features, this is twice slower
    % than older looped DEBUG version. Implement wrapper ONLY IF REQUESTED.
    
    % VERIFICATION:
%     X = normrnd(777, 143, 5000, 4000);
%     ind_nan = randi(numel(X), round(0.10.*numel(X)), 1);
%     ind_salt = randi(numel(X), round(0.30.*numel(X)), 1);
%     X(ind_nan) = NaN;
%     X(ind_salt) = randn(size(ind_salt));
%     [isOutlier, cmean, cvar, cstd, cmedian, cmin, cmax, sigmas] = ...
%         clever_statistics_and_outliers(X, 1, 4);
%     [cmean_ref, cvar_ref, cstd_ref, cmedian_ref, cmin_ref, cmax_ref] = deal(nan(1, size(X, 2)));
%     for ii = 1:size(X, 2),
%         X_ii = X(:,ii);
%         X_ii = X_ii(~isOutlier(:,ii));
%         cmean_ref(ii) = mean(X_ii);
%         cvar_ref(ii) = var(X_ii);
%         cstd_ref(ii) = sqrt(cvar_ref(ii));
%         cmedian_ref(ii) = median(X_ii);
%         cmin_ref(ii) = min(X_ii);
%         cmax_ref(ii) = max(X_ii);
%     end
    
    % ---------------------------------------------------------------------
    
    % ADDED SUPPORT TO DIM (5.1.2016):
    % Useful when analyzing large data sets.
    % If dim == [], then the function forces the input to a column vector.
    
    % ADDED SUPPORT TO MIN/MAX (5.1.2016):
    % Performs outlier removal first, then outputs min/max.
    
    % ADDED MEMORY CLEANUPS (5.1.2016):
    % Frees memory to allow larger matrices.
    % Total memory consumption for DOUBLE input values:
    % ~7 times the input bytes (WITH freeing).
    % ~12 times the input bytes (without freeing).
    % Due to force double, the relative memory consumption will be higher
    % for the data types smaller than double.
    
    % ADDED SUPPORT TO NON-DOUBLE NUMERIC AND LOGICAL ARRAYS (7.1.2016):
    % Simply by force converting X_sorted to double (to force real maths).
    % ERRORs when input is non-numeric and non-logical.% ADDED THAT XMIN, XMAX DIMENSIONS WILL ALSO BE RESTORED! (7.4.2017)
    
    % FIXED "Error if NaN only input" BUG (25.7.2016)
    
    % FIXED "Always NaN output" BUG (13.10.2017)
    
    % ADDED SUPPORT TO MEDIAN (9.1.2019)
    % Performs outlier removal first, then outputs median.
    
    % FIXED "Error if only one observation among NaNs" BUG (9.1.2019)
    
    % ADDED SIGMAS-VARIABLE AS OUTPUT (9.1.2019):
    % The order of removal may be used as a measure of outlier relevance.
    
    % IMPROVED DOCUMENTING (9.1.2019)
    
    % PUBLISHED CODE UNDER BSD-LICENSE (28.3.2019)
    
    % FIXED "Error if first column is all NaN" BUG (11.7.2019)
    
    % IMRPOVED ITERATION USING FLAGS TO MARK IF DONE (11.7.2019)
    
    % FIXED "Single NaN output when all NaN input" BUG (11.7.2019)
    
    % ADDED SUPPORT TO MULTIPLE DIM (11.7.2019)
    
    % ---------------------------------------------------------------------
    
    % TODO (5.1.2016): If dim == [], then use more optimized loop-routine.
    
    % TODO (7.1.2016-24.1.2017): ADD SUPPORT TO INFINITE OUTLIERS.
    % If population of Inf is 50% or below, then treat them outliers.
    % Reasoning behind this is that if they were finite but very large
    % values, then clever mean and variance would prefer them.
    % -> NOW, for simplicity, all Inf values are treated as outliers.
    
    % TODO (4.8.2016): Add try-catch to use cumsum's 'reverse' feature when
    % possible. This would benefit from newer MATLAB version optimizations.
    
    % ---------------------------------------------------------------------
    
    % Default (used for standardized residual analysis to detect outliers)
    if nargin < 3 || isempty(delta), delta = 2.5; end % If set to 4, then gives approximately same variance as var would
    if nargin < 2, dim = []; end % If set to [], then force vectorizes the input.
    
    % Test the input value type OR error
    if ~isnumeric(X) && ~islogical(X),
        error('ERROR: Input must be either numeric or logical!');
    end
    
    % Rearrange dimensions of N-D array
    SX = size(X); % Original input dimensions
    if isempty(dim),
        X = X(:); % Force column vector (Nx1-vector)
    elseif numel(dim) == 1, % Permute desired dimension to first
        otherdims = setdiff(1:ndims(X), dim);
        order = [dim otherdims];
%         order = [dim:ndims(X) 1:dim-1];
        X = permute(X, order);
    else,
        dim = reshape(sort(dim), 1, []); % Force row vector and sort
        N_dims = ndims(X);
        dim = dim(dim <= N_dims); % Remove excess dim
        alldims = 1:N_dims; % All dims
        B_dim = any(bsxfun(@eq, dim(:), alldims),1);
        otherdims = alldims(~B_dim); % Get all but dim
        order = [otherdims dim];
        X = permute(X, order); % Permute all dim last
        SX_otherdims = SX(otherdims);
        if isempty(SX_otherdims), SX_otherdims = 1; end % Even if no other dims, then enforce dim at 2nd or later place
        N_otherdims = numel(SX_otherdims);
        X = reshape(X, [SX_otherdims prod(SX(dim))]); % Merge dim together (and have result at 2nd or later place)
        suborder = [N_otherdims+1 1:N_otherdims];
        X = permute(X, suborder); % Permute merged dim first
    end
    SX_perm = [size(X) 1]; % Permuted input dimensions
    X = X(:,:); % Force 2-dimensional array (NxM-matrix)
    
    if ~islogical(X), X(isinf(X)) = NaN; end % Treat -Inf and Inf as NaN!
    B_nan = isnan(X); % The NaN (or Inf) state of the X data
    
    % Precalculate the row-offset constant
    col = (1:size(X, 2));
    col_offset = (col-1).*size(X, 1);
    
    % SUPERIOR SPEED-UP: EXPLOIT CUMSUM without extra numerical truncation errors.
    % Minimize the numerical truncation errors by two cumsums around zero.
    % It is done by beginning the summing from the least significant bits.
    % Optimization relies on highly optimized built-in function, cumsum.
    
    % Sort data
    [X_sorted, IND] = sort(X, 1, 'ascend'); % SPEED-UP: Sort the X data only once
    clear X; % Free memory (usage drops from 3x INPUT to 2x)
    X_sorted(isnan(X_sorted)) = 0; % Essential for cumsum tricks!
    
    % PROPER IND: Convert double to uint32 (usually drops usage by 0.5x INPUT)
    isuint32 = numel(X_sorted) < 2^32; % Test if the indices fit in uint32
    if isuint32, IND = bsxfun(@plus, uint32(IND), uint32(col_offset));
    else, IND = bsxfun(@plus, IND, col_offset); end
    
    % Prepare data
    X_sorted = double(X_sorted); % Force double (ensures that math works)
    
    % Separate sorted squared data around zero
    X_sorted_2 = X_sorted.^2; % Square only once
    
    % Note that Inf*0 = Inf*false = NaN!
    CS2_neg = flipud(cumsum(flipud(X_sorted_2.*(X_sorted<0)), 1)); % Reverse cumsum negative side (backward compatible)
    CS2_pos = cumsum(X_sorted_2.*(X_sorted>0), 1); % Forward cumsum positive side (backward compatible)
    
    clear X_sorted_2; % Free memory (usage drops from 5x INPUT to 4x)
    
    % Repeat the procedure for sorted regular data
    CS_neg = flipud(cumsum(flipud(X_sorted.*(X_sorted<0)), 1)); % Reverse cumsum negative side (backward compatible)
    CS_pos = cumsum(X_sorted.*(X_sorted>0), 1); % Forward cumsum positive side (backward compatible)
    
    % Case j == 0: (If no outliers == regular mean and variance)
    S = CS_neg(1, :) + CS_pos(end, :); % S = nansum(X_sorted, 1);
    S2 = CS2_neg(1, :) + CS2_pos(end, :); % S2 = nansum(X_sorted_2, 1);
    N0 = sum(~B_nan, 1); % Initial number of elements per column
    cmean = S./N0; % Regular mean
    cvar = (S2-2.*S.*cmean+N0.*cmean.^2)./(N0-1); % Regular variance
    
    % Preallocate results
    [cmedian, cmin, cmax] = deal(nan(size(N0)));
    
    % Store boolean maps
    B_not_empty = N0 ~= 0; % Ability to ignore empty datasets
    B_loop = N0 > 1; % Ability to reduce workload when heavy on outliers
    [B_min_temp, B_max_temp] = deal(false(size(N0))); % Preallocate only once
    
    % Case j > 0: (Possible outliers == clever mean and variance)
    isOutlier = false(size(X_sorted)); % The initial outlier state of the X data
    sub_max = N0; % Index to current maximum
    sub_min = ones(size(sub_max)); % Index to current minimum
    sub_median_min = floor((N0-1)./2)+1; % Index to current min-side median
    sub_median_max = ceil((N0-1)./2)+1; % Index to current max-side median
    for jj = 1:size(X_sorted, 1)-1, % ONE-LINERS speed-up a HUGE loop
        % Current sample count AND indices of the min/max of each row
        N = sub_max(B_loop) - sub_min(B_loop); ind_min = sub_min(B_loop) + col_offset(B_loop); ind_max = sub_max(B_loop) + col_offset(B_loop);
        
        % A new outlier is either the minimum or the maximum or neither
        x_min = X_sorted(ind_min); x_max = X_sorted(ind_max);
        
        % SUPERIOR SPEED-UP: EXPLOIT CUMSUM
        S = CS_neg(ind_min+1) - CS_neg(ind_max) + CS_pos(max(ind_max-1, 1)) - CS_pos(ind_min); % max needed to account for ind_max-1 being zero
        S2 = CS2_neg(ind_min+1) - CS2_neg(ind_max) + CS2_pos(max(ind_max-1, 1)) - CS2_pos(ind_min); % max needed to account for ind_max-1 being zero

        % Update variables
        S_min = S+x_max; S_max = S+x_min; S2_min = S2+x_max.^2; S2_max = S2+x_min.^2;

        % Try the minimum removed
        cmean_min = S_min./N; cvar_min = (S2_min-2.*S_min.*cmean_min+N.*cmean_min.^2)./(N-1);

        % Try the maximum removed
        cmean_max = S_max./N; cvar_max = (S2_max-2.*S_max.*cmean_max+N.*cmean_max.^2)./(N-1);

        % Compare which removal results in smaller sample variance
        B_min = cvar_min < cvar_max & cvar_min <= cvar(B_loop) & (cmean_min-x_min).^2 > delta.^2.*cvar_min; % Test if the minimum is an outlier
        B_max = cvar_min >= cvar_max & cvar_max <= cvar(B_loop) & (cmean_max-x_max).^2 > delta.^2.*cvar_max; % Test if the maximum is an outlier
        
        % Set temporary boolean maps
        B_min_temp(B_loop) = B_min;
        B_max_temp(B_loop) = B_max;
        
        % The minimum is an outlier
        cmean(B_min_temp) = cmean_min(B_min);
        cvar(B_min_temp) = cvar_min(B_min);
        sub_min(B_min_temp) = sub_min(B_min)+1;
        isOutlier(IND(ind_min(B_min))) = true; % Better for matrices
        B_move_max_all = sub_median_min == sub_median_max;
        sub_median_min(B_min_temp & ~B_move_max_all) = sub_median_min(B_min_temp & ~B_move_max_all)+1;
        sub_median_max(B_min_temp & B_move_max_all) = sub_median_max(B_min_temp & B_move_max_all)+1;
        
        % The maximum is an outlier
        cmean(B_max_temp) = cmean_max(B_max);
        cvar(B_max_temp) = cvar_max(B_max);
        sub_max(B_max_temp) = sub_max(B_max)-1;
        isOutlier(IND(ind_max(B_max))) = true; % Better for matrices
        B_move_min_all = sub_median_min == sub_median_max;
        sub_median_min(B_max_temp & B_move_min_all) = sub_median_min(B_max_temp & B_move_min_all)-1;
        sub_median_max(B_max_temp & ~B_move_min_all) = sub_median_max(B_max_temp & ~B_move_min_all)-1;
        
        % Store 'neither' state before restoring B_min_temp and B_max_temp
        B_neither = ~B_min_temp & ~B_max_temp;
        
        % Restore temporary boolean maps to false
        B_min_temp(B_loop) = false;
        B_max_temp(B_loop) = false;
        
        % If no outliers, then mark as done
        B_loop(B_neither) = false;
        
        % Break if no more outliers detected
        if ~any(B_min) && ~any(B_max), break; end
    end
    
    % Clever min/max using latest indices of the min/max of each row
    ind_min = sub_min(B_not_empty) + col_offset(B_not_empty);
    ind_max = sub_max(B_not_empty) + col_offset(B_not_empty);
    cmin(B_not_empty) = X_sorted(ind_min);
    cmax(B_not_empty) = X_sorted(ind_max);
    
    % Clever median using latest indices of the median(s) of each row
    ind_median_min = sub_median_min(B_not_empty) + col_offset(B_not_empty);
    ind_median_max = sub_median_max(B_not_empty) + col_offset(B_not_empty);
    cmedian(B_not_empty) = (X_sorted(ind_median_min) + X_sorted(ind_median_max))./2;
    
    % Clever std
    cstd = sqrt(cvar);
    
    % Distance (in sigmas) from cmean for each data point (if requested)
    if nargout >= 8,
        X_sorted(IND) = X_sorted; % Unsort
        X_sorted(B_nan) = NaN; % Restore NaN's (or Inf's) as outliers
        sigmas = bsxfun(@rdivide, abs(bsxfun(@minus, cmean, X_sorted)), cstd);
    end
    
    isOutlier(B_nan) = true; % Restore NaN's (or Inf's) as outliers
    
    % Restore array dimensions
    if ~isempty(dim),
        if numel(dim) == 1,
            isOutlier = ipermute(reshape(isOutlier, SX_perm), order);
            cmean = ipermute(reshape(cmean, [1 SX_perm(2:end)]), order);
            cvar = ipermute(reshape(cvar, [1 SX_perm(2:end)]), order);
            cstd = ipermute(reshape(cstd, [1 SX_perm(2:end)]), order);
            cmedian = ipermute(reshape(cmedian, [1 SX_perm(2:end)]), order);
            cmin = ipermute(reshape(cmin, [1 SX_perm(2:end)]), order);
            cmax = ipermute(reshape(cmax, [1 SX_perm(2:end)]), order);
            if nargout >= 8, % Only if requested
                sigmas = ipermute(reshape(sigmas, SX_perm), order);
            end
        else,
            isOutlier = ipermute(reshape(ipermute(reshape(isOutlier, SX_perm), suborder), [SX(otherdims) SX(dim)]), order);
            cmean = ipermute(reshape(cmean, SX_perm(2:end)), order);
            cvar = ipermute(reshape(cvar, SX_perm(2:end)), order);
            cstd = ipermute(reshape(cstd, SX_perm(2:end)), order);
            cmedian = ipermute(reshape(cmedian, SX_perm(2:end)), order);
            cmin = ipermute(reshape(cmin, SX_perm(2:end)), order);
            cmax = ipermute(reshape(cmax, SX_perm(2:end)), order);
            if nargout >= 8, % Only if requested
                sigmas = ipermute(reshape(ipermute(reshape(sigmas, SX_perm), suborder), [SX(otherdims) SX(dim)]), order);
            end
        end
    else,
        isOutlier = reshape(isOutlier, SX);
        if nargout >= 8, % Only if requested
            sigmas = reshape(sigmas, SX);
        end
    end
end

%% TODO (5.1.2016): If dim == [], then use more optimized loop-routine.
%     % Compare which removal results in smaller sample variance
%     if cvj_min < cvj_max,
%         % Test if the minimum is an outlier
%         if cvj_min <= cvj && (cmj_min-xj_min)^2 > delta^2*cvj_min,
%             cmj = cmj_min; cvj = cvj_min; isOutlier2(I2_min) = true; sub_min = sub_min+1;
%         else
%             break; % No more outliers detected.
%         end
%     else
%         % Test if the maximum is an outlier
%         if cvj_max <= cvj && (cmj_max-xj_max)^2 > delta^2*cvj_max,
%             cmj = cmj_max; cvj = cvj_max; isOutlier2(I2_max) = true; sub_max = sub_max-1;
%         else
%             break; % No more outliers detected.
%         end
%     end
