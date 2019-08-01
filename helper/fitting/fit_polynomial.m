% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [P, R2, SSres, Y_fit, R2_total, SSres_total] = fit_polynomial(x, Y, order, dim, fitMany),
    % Fitting of the N'th order polynomial(s) to the data in Y, for which
    % the dim'th dimension is interpreted as the data dimension. Other
    % dimensions are interpreted as datasets. By default, dim == 1. Outputs
    % have the same dimensionality as Y (except in the dim'th dimension).
    % NOTE: Calculation is faster if only the P is specified as an output.
    % NOTE 2: Treats NaNs as missing data in x and Y.
    % *Concerning fitMany:
    % true: Many polynomials are fitted (one per dataset in Y). (DEFAULT)
    % false: One polynomial is fitted (using all datasets in Y).
    % Updated 11.8.2016 by Joonas T. Holmi
    if nargin < 4, dim = 1; end % By default, operate first dimension
    if nargin < 5, fitMany = true; end % By default, fit many polynomials.
    
    [Y, perm] = dim_first_permute(Y, dim); % Permute dim to first
    S = size(Y); % Dimensions of permuted matrix Y
    Y = Y(:,:); % Operate on first dimension
    
    % Convert to double
    Y = double(Y);
    x = double(x);
    
    SD = prod(S(2:end)); % Number of datasets
    SP = order+1; % Number of parameters
    x = x(:); % Force column vector
    
    % Discard unused data region for speed (only if necessary)
    bw_nan_x = isnan(x);
    discard = any(bw_nan_x);
    if discard,
        x = x(~bw_nan_x);
        Y = Y(~bw_nan_x,:);
    end
    
    % Set remaining NaNs to zero
    bw_nan_Y = isnan(Y);
    Y(bw_nan_Y) = 0;
    
    if fitMany, % Fit many polynomials (one per dataset in Y)
        % Indices required for sparse matrix construction (converts problem
        % with SD datasets and SP unknowns to 1 dataset and SD*SP unknowns).
        % if SP = 4, then indices I, J become:
        % SUB1 = 1234 1234 1234 1234 5678 5678 5678 5678 ....
        % SUB2 = 1111 2222 3333 4444 5555 6666 7777 8888 ....
        kk = 1:SD*SP*SP;
        SUB1 = mod(kk-1, SP)+1+floor((kk-1)/(SP*SP))*SP;
        SUB2 = floor((kk-1)/SP)+1;
        
        % GENERAL CASE: any order
        b = zeros(SP, SD);
        A2 = zeros(SP*SP, SD);
        % Optimal (# of multiplications minimized). Time complexity linear.
        [loop_begin, loop_end] = deal(SP); % Anti-diagonal element indices, starting from the bottom-right
        X_pow = ~bw_nan_Y; % Account for the remaining missing values in Y
        for ind = 1:2*SP-1, % Process all anti-diagonals, from bottom-right to top-left
            if ind <= SP, b(SP-ind+1,:) = sum(X_pow.*Y, 1); end % Construct result vector
            sum_x_pow_repmat = repmat(sum(X_pow, 1), [loop_end-loop_begin+1 1]); % Anti-diagonal values
            ind_anti_diag = sub2ind([SP SP], loop_begin:loop_end, loop_end:-1:loop_begin); % Anti-diagonal indices
            A2(ind_anti_diag,:) = sum_x_pow_repmat; % Construct an anti-diagonal
            X_pow = bsxfun(@times, X_pow, x); % Multiplication
            if ind < SP, loop_begin = loop_begin - 1; % Adjust beginning of anti-diagonal indices
            else, loop_end = loop_end - 1; end % Adjust ending of anti-diagonal indices
        end
        
        % Unoptimal but simple code. Time complexity quadratic.
%         for ii = 1:SP,
%             X_pow = bsxfun(@times, ~bw_nan_Y, x.^(SP-ii));
%             b(ii,:) = sum(X_pow.*Y, 1);
%             for jj = SP:-1:1,
%                 A2(sub2ind([SP SP], ii, jj),:) = sum(X_pow, 1);
%                 X_pow = bsxfun(@times, X_pow, x);
%             end
%         end
        
        % Construct sparse matrix before solving the polynomial problem
        A = sparse(SUB1, SUB2, A2(:));
    else, % OTHERWISE: Fit only one polynomial (using all datasets in Y)
        % GENERAL CASE: any order
        b = zeros(SP, 1);
        A = zeros(SP, SP);
        % Optimal (# of multiplications minimized). Time complexity linear.
        [loop_begin, loop_end] = deal(SP); % Anti-diagonal element indices, starting from the bottom-right
        X_pow = ~bw_nan_Y; % Account for the remaining missing values in Y
        y = Y(:); % Force column vector
        for ind = 1:2*SP-1, % Process all anti-diagonals, from bottom-right to top-left
            x_pow = X_pow(:); % Force column vector
            if ind <= SP, b(SP-ind+1) = sum(x_pow.*y); end % Construct result vector
            ind_anti_diag = sub2ind([SP SP], loop_begin:loop_end, loop_end:-1:loop_begin); % Anti-diagonal indices
            A(ind_anti_diag) = sum(x_pow); % Construct an anti-diagonal with anti-diagonal values
            X_pow = bsxfun(@times, X_pow, x); % Multiplication
            if ind < SP, loop_begin = loop_begin - 1; % Adjust beginning of anti-diagonal indices
            else, loop_end = loop_end - 1; end % Adjust ending of anti-diagonal indices
        end
    end
    
    % TEMPORARILY DISABLE ALL WARNINGS (including the following two warnings):
    % 1) Warning: Matrix is singular to working precision.
    % 2) Warning: Matrix is close to singular or badly scaled. Results may be inaccurate. RCOND =  <value>
    w_old_state = warning; % Get the old warning state
    warning('off'); % Disable all warnings
    
    % Solve the polynomial fitting parameters using LU-factorization
    if ~issparse(A),
        [LL,UU,PP] = lu(A);
        P = UU\(LL\(PP*b(:))); % Equivalent to P = A\b; (A\B = (A^-1)*B && B/A = B*(A^-1))
    else, % For sparse matrix
        [LL,UU,PP,QQ,RR] = lu(A, [1 1]); % Sparse allows lower memory consumption and quicker inversion
        P = QQ*(UU\(LL\(PP*(RR\b(:))))); % Equivalent to P = A\b; (A\B = (A^-1)*B && B/A = B*(A^-1))
    end
    
    % Restore the old warning state
    warning(w_old_state);
    
    if fitMany, P = reshape(P, [], SD); end % Reshape to more useful format
    
    if nargout > 1, % Proceed only if needed
        % Construct the fitting result
        Y_fit = zeros(size(Y));
        x_pow = ones(size(x));
        for ii = SP:-1:1,
            Y_fit = bsxfun(@plus, Y_fit, bsxfun(@times, x_pow, P(ii,:))); % Handles both cases of fitMany (false and true)
            x_pow = x.*x_pow;
        end
        
        % Calculate the fitting performance
        residual = Y-Y_fit;
        Y_nanmean_1 = sum(Y, 1)./sum(~bw_nan_Y, 1); % Avoid nanmean for backward compability
        SSres = sum(residual.^2, 1); % Sum of squared residuals
        SStot = sum((bsxfun(@minus, Y, Y_nanmean_1)).^2, 1); % Total sum of squares
        R2 = 1-SSres./SStot; % Coefficient of determination
        if nargout > 4,
            SSres_total = sum(SSres(:));
            SStot_total = sum(SStot(:));
            R2_total = 1-SSres_total./SStot_total;
            
            % Reshape and ipermute the output for consistency
            SSres_total = ipermute(SSres_total, perm);
            R2_total = ipermute(R2_total, perm);
        end
        
        % Debug by plotting
%         Y(bw_nan_Y) = NaN; % Restore NaNs
%         figure; plot(x, Y, '.', x, Y_fit, '-');
        
        % Restore the discarded data region (only if necessary)
        if discard,
            Y_fit_temp = Y_fit;
            Y_fit = nan(S(1), SD);
            Y_fit(~bw_nan_x, :) = Y_fit_temp;
        end
        
        % Reshape and ipermute the output for consistency
        R2 = ipermute(reshape(R2, [1 S(2:end)]), perm);
        SSres = ipermute(reshape(SSres, [1 S(2:end)]), perm);
        Y_fit = ipermute(reshape(Y_fit, S), perm);
    end
    
    % Reshape and ipermute the output for consistency
    if fitMany, P = reshape(P, [SP S(2:end)]); end
    P = ipermute(P, perm);
end
