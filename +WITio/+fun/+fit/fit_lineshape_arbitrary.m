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

function [P, R2, SSres, Y_fit, R2_total, SSres_total] = fit_lineshape_arbitrary(fun, X, Y, P0, dim, varargin),
    %% DESCRIPTION
    % Fits arbitrary lineshape function using the Levenberg–Marquardt
    % algorithm (LMA) with the Gauss-Newton (GN) approximation, which
    % avoids expensive Hessian matrix evaluation. All lineshapes are fit
    % simultaneously by using the sparse matrix technique. This utilizes
    % numerical Jacobian (and Hessian) matrices.
    
    % NOTES:
    % LMA seems to be most robust to initial guess using GN approximation.
    % Apparently, GN approximation is more robust to noise than NR and less
    % likely to diverge due to noise anomalies affecting the initial guess
    % calculus. But, GN seems to diverge more likely when signal is absent.
    % GN is faster to evaluate, but requires more iterations to converge.
    
    % INPUT:
    % X = either a S(1)-length vector describing the spectrum dimension
    % X-range or a matrix of size S.
    % Y = an intensity matrix (size S).
    % P0 = a 2-D guess matrix, where size(P0) = [SP numel(Y)./size(Y,dim)].
    % dim = the lineshape dimension in the given dataset Y.
    % EXTRA INPUT (case insensitive):
    % '-silent' = chooses to avoid outputting to Command Window
    % '-avoidLMA' = chooses conventional NR or GN methods
    % '-evalHessian' = chooses NR iteration step and evaluates the time
    % consuming Hessian matrix
    % '-fitOne' = chooses to fit only a single lineshape to all datasets
    % '-Locks' = Whether any parameter should be locked during the fit.
    % '-Weights' = Residual weights. For example, use for chi-squared
    % fitting. Also, use for weighting with photon shot noise variances.
    % '-Lambdas' = A positive and non-zero factor used in LMA and, by
    % default, it is initially 0.1 everywhere. Try another values if LMA
    % tends to converge to local minimum.
    % '-LowOnMemory' = Uses loops (instead of repmats) to calculate Hr2!
    
    % OUTPUT:
    % P - a optimized parameter matrix (size SP x SD), where SP is the
    % parameter dimension. The number of parameters are determined by
    % size(P0, 1). Those pixels that fail the Lineshape(s) fitting will
    % contain NaN values.
    
    % IDEAS:
    % * Allow '-fitOne2Area', which asks for a SP x SD matrix to set which
    % spatial areas fit one parameter per area. Each area are marked with
    % an integer. Uses sparse-functionality to reduce Jr2 and Hr2 problem
    % spaces by summing. (23.8.2018)
    %
    % * Consider implementing '-groups', what would generalize '-locks'
    % feature to the specified labelled or indexed regions. This would be
    % particularly useful if dataset is known to have a single shared
    % parameter in such regions. (20.9.2018)
    %
    % * Consider implementing Semi-Implicit Root (SIR) solver, what is
    % claimed to possess superior global convergence properties over GN and
    % NR, or even LMA [1]. (3.4.2019)
    % [1] J. Scheffel and K. Lindvall (2018), 'SIR - An efficient solver
    % for systems of equation', https://doi.org/10.1016/j.softx.2018.01.003
    %
    % * Implement '-NLineshapes' (number of lineshapes) to allow simpler
    % fun-input. For instance, one could simply give a single lineshape
    % fun, which is then used for N lineshapes. (25.6.2019)
    %
    % * Implement robust least squares ROUT-method described in ref. [2]
    % that removes dataset outliers on the fly. (2.4.2020)
    % [2] H. J. Motulsky and R. E. Brown (2006), 'Detecting outliers when
    % fitting data with nonlinear regression – a new method based on robust
    % nonlinear regression and the false discovery rate',
    % https://doi.org/10.1186/1471-2105-7-123
    %
    % * Implement Simultaneous Multiple Robust Fitting (SMRF) described in
    % ref. [3] that allows multiple peak fitting with outliers. (8.6.2020)
    % [3] J.-P. Tarel and P. Charbonnier (2010), 'A Lagrangian Half-
    % Quadratic approach to robust estimation and its applications to road
    % scene analysis', https://doi.org/10.1016/j.patrec.2010.05.011
    %
    % * Implement Conjugate Gradient (CG) method described in
    % ref. [4] with PRECONDITIONING. (3.9.2020)
    % [4] J. R. Shewchuk (1994) 'An Introduction to the Conjugate
    % Gradient Method Without the Agonizing Pain', https://www.cs.cmu.edu/~quake-papers/painless-conjugate-gradient.pdf
    
    if nargin < 5, dim = 3; end % By default, operate 3rd or spectral dimension
    T_begin = now.*86400; % [s]
    SP = size(P0, 1); % Determine the number of fitting parameters
    
    % Parse extra arguments
    silent = WITio.misc.varargin_dashed_str.exists('silent', varargin); % By default, do not utilize the silent option
    lowOnMemory = WITio.misc.varargin_dashed_str.exists('lowOnMemory', varargin); % By default, do not utilize the low-on-memory option
    avoidLMA = WITio.misc.varargin_dashed_str.exists('avoidLMA', varargin); % By default, use the Levenberg–Marquardt algorithm or avoidLMA = false
    evalHessian = WITio.misc.varargin_dashed_str.exists('evalHessian', varargin); % By default, avoid Hessian or evalHessian = false
    fitMany = ~WITio.misc.varargin_dashed_str.exists('fitOne', varargin); % By default, fit many Lineshape(s) or fitMany = true
    % Consider implementing -minimizeChiSquared feature using photon shot noise estimate (21.8.2018)
    % Consider implementing -absTol, -relTol, -maxIterations features (1.3.2019)
    
    %% PREPARATION
    [Y, perm] = WITio.fun.dim_first_permute(Y, dim); % Permute dim to first
    S = size(Y); % Dimensions of permuted matrix Y
    SD = prod(S(2:end)); % Number of datasets
    Y = Y(:,:); % Operate on first dimension
    
    % Test input X
    X = permute(X, perm);
    SX = size(X);
    if numel(SX) == numel(S) && all(SX == S), % Proceed if size of X is equal to size of Y
        X = X(:,:); % Convert into a 2-D matrix
    elseif sum(SX ~= 1) == 1, % Proceed if X is a vector 
        X = repmat(X(:), [1 SD]); % Convert the vector into a 2-D matrix
    else,
        error('Input X must either be a vector or a same size matrix as Y!');
    end
    
    % Convert to double
    Y = double(Y);
    X = double(X);
    
    if ~fitMany, % Fit only one set of parameters to all datasets!
        P0 = repmat(mean(P0, 2), [1 SD]);
    end
    P = P0;
    
    % Check if CUSTOM lambdas was specified
    datas = WITio.misc.varargin_dashed_str.datas('lambdas', varargin, -1);
    lambdas = 1e-1.*ones(1, SD);
    if numel(datas) > 0, lambdas = datas{1}; end
    if numel(lambdas) == 1,
        lambdas = repmat(lambdas, [1 SD]);
    else,
        lambdas = permute(lambdas, perm);
        lambdas = lambdas(:,:);
    end
    
    % Check if CUSTOM weights was specified
    datas = WITio.misc.varargin_dashed_str.datas('weights', varargin, -1);
    weights = ones(S(1), SD);
    if numel(datas) > 0, weights = reshape(datas{1}, S(1), SD); end
    
    % Check if CUSTOM locks was specified
    datas = WITio.misc.varargin_dashed_str.datas('locks', varargin, -1);
    locks = false(SP, 1);
    if numel(datas) > 0, locks = logical(reshape(datas{1}, SP, 1)); end
    SP_unlocked = sum(~locks);
    
%     % Check if CUSTOM groups was specified
%     % NOT IMPLEMENTED YET!!! (20.9.2018)
%     datas = WITio.misc.varargin_dashed_str.datas('groups', varargin, -1);
%     groups = false(SP, 1);
%     if numel(datas) > 0, groups = reshape(datas{1}, S(1), SD); end
    
    %% NEWTON-RAPHSON METHOD
    N_max_iterations = 100; % Maximum number of iterations
    tol_abs = 1e-12; % Absolute tolerance
    tol_rel = 1e-9; % Relative tolerance
    
%     N_max_iterations = 200; % WITec Project 2.10 and WITec Control 1.60
%     tol = 1e-4; % (Unsure if relTol or absTol) Default in WITec Project 2.10 and WITec Control 1.60
    
    df_tol_abs = 1e-6;
    df_tol_rel = 1e-6;

    % Initialize goodness of fit statistics
    bw_converged = false(1, SD); % If converged
    bw_diverged = false(1, SD); % If diverged
    N_iterations = zeros(1, SD); % Number of iterations
    SStot = sum(bsxfun(@minus, Y, mean(Y, 1)).^2, 1); % Total sum of squares
    SSres = nan(N_max_iterations+1, SD); % Sum of squared residuals
    R2 = nan(N_max_iterations+1, SD); % Coefficient of determination
    
    bw_dP_all_zero = false(1, SD);
    bw_dP_any_nan = all(isnan(Y), 1);
    bw_dP_any_inf = false(1, SD);
    
    bw = ~bw_converged & ~bw_diverged & ~bw_dP_any_nan; % Consider only non-converged and non-diverged (and initially non-nan) parameters.
    
    % DISABLE ALL WARNINGS (including the following two warnings):
    % 1) Warning: Matrix is singular to working precision.
    % 2) Warning: Matrix is close to singular or badly scaled. Results may be inaccurate. RCOND =  <value>
    % CAUSE: These occur when it is best solution to fit a horizontal line
    % (rather than a Lorentzian) to the dataset. The warnings are thrown by
    % the mldivide function (or \-operator). The main reason to this is
    % that the Jacobian Jf and Hessian Hf have become fully or partially
    % zero (or near zero). These zeros (or near zeros) further propagate in
    % to the Jr2 and Hr2 matrices, which are then used and updated during
    % each Newton-Raphson (or Gauss-Newton) iteration step.
    % CONCLUSION: These warnings merely indicate the Hr2\Jr2 results in NaN
    % or Inf values at certain points. Such results are expected because
    % evidently no Lorentzian could be fitted at that point. Such invalid
    % values are converted to NaNs and therefore the warnings are disabled.
    w_old_state = warning; % Get the old state
    warning('off'); % Disable all warnings
    
    % Initialize variables
    Y_fit = nan(size(Y));
    r = nan(size(Y));
    
    str_solver = 'Gauss-Newton';
    if evalHessian, str_solver = 'Newton-Raphson'; end
    if ~avoidLMA, str_solver = sprintf('Levenberg–Marquardt algorithm using %s', str_solver); end
    fprintf_if_permitted('@%s:\nMethod of iterations = %s\nTotal number of samples = %d\n', mfilename, str_solver, SD);
    
    % Main loop
    ii = 0; % Consider the guess as 0th iteration
    jj = 0; % Sub iterations of LMA
    h_Waitbar = waitbar(0, 'Please wait...', 'Name', 'Lineshape fitting');
    bw_diag = reshape(logical(eye(SP_unlocked)), [], 1);
    while true, % DO-WHILE STRUCTURE
        %% TEST CURRENT PARAMETERS
        % Evaluate the original function and the residual function
%         Y_fit(:,bw) = fun(P(:,bw), X(:,bw));
        Y_fit(:,bw) = fun_with_locks(P(~locks,bw), X(:,bw), P(locks,bw));
        r(:,bw) = weights(:,bw).*(Y(:,bw)-Y_fit(:,bw)); % With linear weight contribution

        % Bookkeeping
        SSres(ii+1,bw) = WITio.fun.mynansum(r(:,bw).^2, 1); % Sum squares of residuals
        R2(ii+1,bw) = 1-SSres(ii+1,bw)./SStot(:,bw);
        N_iterations(:,bw) = ii;
        
        % Convergence tests
        if ii > 0, % Do not test the zeroth iteration
            if ~avoidLMA, % The Levenberg-Marquardt algorithm
                if ~jj, bw_original = bw; end % Store the original
                
                % Accept the update partially (ONLY ONCE!)
                bw_accept = false(size(bw));
                bw_accept(bw) = SSres(ii+1,bw) <= SSres(ii,bw);
                lambdas(bw_accept) = lambdas(bw_accept).*0.1; % Tend towards NR (or GN)
                
                % Retract the update otherwise
                bw_retract = false(size(bw));
                bw_retract(bw) = ~bw_accept(bw);
                bw = bw_retract; % Update bw temporarily!
                
                P(~locks,bw) = P0(~locks,bw); % Restore original
                Hr2(1,bw(bw_original),bw_diag) = bsxfun(@times, 1+lambdas(1,bw).*(10-1), Hr2(1,bw(bw_original),bw_diag)); % Adjust diagonal values % Backward compatible with R2011a
                lambdas(bw) = lambdas(bw).*10; % Tend towards gradient descent
                
                dPsub = solve_step(Jr2(1,bw(bw_original),:), Hr2(1,bw(bw_original),:));

                bw_dP_all_zero(:,bw) = all(dPsub == 0, 1);
                bw_dP_any_nan(:,bw) = any(isnan(dPsub), 1);
                bw_dP_any_inf(:,bw) = any(isinf(dPsub), 1);
                dPsub(:,bw_dP_any_nan(:,bw)|bw_dP_any_inf(:,bw)) = NaN;
                
                % Update parameters
                P(~locks,bw) = P(~locks,bw) + dPsub; % P(n+1)-P(n) = dP(n) = - Hr2(n)\Jr2(n);
                
                if any(bw), % Repeat this subroutine if any retracted found
                    jj = jj + 1;
                    continue;
                end
                P0 = P; % Update previous values
                jj = 0; % Reset to zero
                bw = bw_original; % Reset bw to original
            end
            
            if ~fitMany, % Fit only one set of parameters to all datasets!
                % Update converged
                bw_converged(:,bw) = ...
                    bw_dP_all_zero(:,bw) | ... % Converged if all derivatives are zero
                    repmat(abs(WITio.fun.mynansum(SSres(ii+1,bw)-SSres(ii,bw),2)) <= max(tol_rel*abs(WITio.fun.mynansum(SSres(ii+1,bw),2)), tol_abs), [1 SD]); % Converged if within absolute/relative tolerances

                % Update diverged
                bw_diverged(:,bw) = ...
                    bw_dP_any_nan(:,bw) | bw_dP_any_inf(:,bw) | ... % Diverged if any derivates are NaN or Inf
                    repmat(WITio.fun.mynansum(SSres(ii+1,bw),2)./WITio.fun.mynansum(SSres(1,bw),2) >= 10, [1 SD]); % Diverged if an order of magnitude increase compared to the initial guess
            else,
                % Update converged
                bw_converged(:,bw) = ...
                    bw_dP_all_zero(:,bw) | ... % Converged if all derivatives are zero
                    abs(SSres(ii+1,bw)-SSres(ii,bw)) <= max(tol_rel*abs(SSres(ii+1,bw)), tol_abs); % Converged if within absolute/relative tolerances

                % Update diverged
                bw_diverged(:,bw) = ...
                    bw_dP_any_nan(:,bw) | bw_dP_any_inf(:,bw) | ... % Diverged if any derivates are NaN or Inf
                    SSres(ii+1,bw)./SSres(1,bw) >= 1000; % Diverged if an order of magnitude increase compared to the initial guess
            end
            
            bw(:,bw) = ~bw_converged(:,bw) & ~bw_diverged(:,bw); % Consider only non-converged and non-diverged parameters.
            
            Undone = sum(bw);
            Diverged = sum(bw_diverged);
            Converged = sum(bw_converged);
            Ns = sum(bw_dP_any_nan);
            Is = sum(bw_dP_any_inf);
            Zs = sum(bw_dP_all_zero);
            fprintf_if_permitted('ii = %d: U = %d, D = %d, C = %d, N = %d, I = %d, Z = %d -> TSSres = %.5g (DSSres = %.5g)\n', ii, Undone, Diverged, Converged, Ns, Is, Zs, WITio.fun.mynansum(SSres(ii+1,:)), WITio.fun.mynansum(SSres(ii+1,:)-SSres(ii,:)));
            
            % TEST IF TO EXIT THE MAIN LOOP
            if all(~bw) || ii >= N_max_iterations,
                break; % EXIT IF ALL ARE CONVERGED/DIVERGED OR MAX # OF ITERATIONS REACHED!
            end
            
            % TEST IF TO USER EXITED THE MAIN LOOP
            if ~ishandle(h_Waitbar),
                fprintf_if_permitted('Operation terminated by user during %s\n', mfilename);
                break;
            end
        else, fprintf_if_permitted('(U)ndone, (D)iverged, (C)onverged state\n(N)aN, (I)nfinite, (Z)ero step -> Total (and Delta) Sum of Squared Residuals:\n'); end
        SD_reduced = sum(bw);
        
        %% CALCULATE NEXT PARAMETERS
        % Update iterations
        ii = ii + 1;
        waitbar(ii / N_max_iterations);
        
        % Evaluate Jacobian (and Hessian if requested)
        if evalHessian, % Newton-Raphson iteration step
            [Jf, Hf] = WITio.fun.fit.jacobian_helper(df_tol_abs, df_tol_rel, @fun_with_locks, P(~locks,bw), ii > 1, X(:,bw), P(locks,bw));
            rHf = bsxfun(@times, r(:,bw), reshape(Hf, S(1), SD_reduced, SP_unlocked.^2)); % Product of r and Hf % Second term of Hr2
            rHf = bsxfun(@times, weights(:,bw), rHf); % Quadratic weight contribution
        else, % Gauss-Newton approximation (avoids Hf calculus).
            % Works only if rHf is an order of magnitude smaller than JfJf.
            Jf = WITio.fun.fit.jacobian_helper(df_tol_abs, df_tol_rel, @fun_with_locks, P(~locks,bw), ii > 1, X(:,bw), P(locks,bw));
            rHf = 0; % Second term of Hr2
        end

        % Evaluate Jacobian matrix of the weighted residual squared function
        Jf_reshaped = reshape(Jf, S(1), SD_reduced, SP_unlocked);
        Jr2 = -2.*WITio.fun.mynansum(bsxfun(@times, weights(:,bw).*r(:,bw), Jf_reshaped), 1);
        
        if ~lowOnMemory,
            % First term of Hr2 is outer product of Jf
            % Permute SP*SP combinations of Jf(:,:,j) .* Jf(:,:,k), j = k = 1...SP
            Jf_j = repmat(Jf, [SP_unlocked 1]);
            Jf_k = repmat(Jf, [1 SP_unlocked]);
            JfJf = reshape(Jf_j(:).*Jf_k(:), [S(1) SD_reduced SP_unlocked.^2]); % Produce permutation
            JfJf = bsxfun(@times, weights(:,bw).^2, JfJf); % Linear weight contribution

            % Evaluate Hessian of r2 (or Jacobian of Jr2)
            % Always symmetric if Hf is symmetric
            Hr2 = 2.*WITio.fun.mynansum(JfJf-rHf, 1); % Sums of Hessian matrices
        else, % LOW-ON-MEMORY LOOP ALTERNATIVE (VERIFIED 20.9.2018)
            % NOTE: NOT numerically equivalent DOWN TO MACHINE PRECISION.
            % Improve the loop by providing a Jacobian sparsity matrix.
            Hr2 = zeros(1, SD_reduced, SP_unlocked.^2);
            for ind = 1:SP_unlocked.^2,
                [kk, ll] = ind2sub([SP_unlocked SP_unlocked], ind);
                w_Jf_kk_ll = weights(:,bw).^2.*Jf_reshaped(:,:,kk).*Jf_reshaped(:,:,ll);
                if ~evalHessian, Hr2(1,:,ind) = 2.*WITio.fun.mynansum(w_Jf_kk_ll, 1);
                else, Hr2(1,:,ind) = 2.*WITio.fun.mynansum(w_Jf_kk_ll - rHf(:,:,ind), 1); end
            end
%              max(abs(Hr2(:)-Hr2(:))) % Should be (nearly) ZERO!
%              sum(abs(Hr2(:)-Hr2(:)) > eps) % Should be (nearly) ZERO!
            
%             R2 = zeros(m, m);
%             TX = X';
%             for jj = 1:m,
%                 R2(:,jj) = TX*(X(:,jj).*Y);
%             end
        end

        if ~fitMany, % Fit only one set of parameters to all datasets!
            Jr2 = WITio.fun.mynansum(Jr2, 2);
            Hr2 = WITio.fun.mynansum(Hr2, 2);
        end
        
        if ~avoidLMA, % Fit using the Levenberg-Marquardt algorithm
            Hr2(1,:,bw_diag) = bsxfun(@times, 1+lambdas(1,bw), Hr2(1,:,bw_diag)); % Adjust diagonal values
        end
        
%         % Debugging: Simple reference
%         Hr2_ref = zeros(1, SD_reduced, SP.^2); % Verification test (CONFIRMED)
%         Jf = reshape(Jf, S(1), SD_reduced, SP);
%         Hf = reshape(Hf, S(1), SD_reduced, SP.^2);
%         for k = 1:SP,
%             for l = 1:SP,
%                 Hr2_ref(1,:,sub2ind([SP SP], k,l)) = sum(2.*Jf(:,:,k).*Jf(:,:,l) - 2.*r(:,bw).*Hf(:,:,sub2ind([SP SP], k,l)), 1);
%             end
%         end
%         sum(abs(Hr2(:)-Hr2_ref(:)) > eps) % Should be ZERO!
        
        % First order Taylor expansion iteration step
        dP = solve_step(Jr2, Hr2);
        
        if ~fitMany, % Fit only one set of parameters to all datasets!
            dP = repmat(dP, [1 SD]);
        end
        
        bw_dP_all_zero(:,bw) = all(dP == 0, 1);
        bw_dP_any_nan(:,bw) = any(isnan(dP), 1);
        bw_dP_any_inf(:,bw) = any(isinf(dP), 1);
        dP(:,bw_dP_any_nan(:,bw)|bw_dP_any_inf(:,bw)) = NaN;
        % Handle these differently in LMA!
        
        % Update (unlocked) parameters
        P(~locks,bw) = P(~locks,bw) + dP; % P(n+1)-P(n) = dP(n) = - Hr2(n)\Jr2(n);
    end
    waitbar(1);
    delete(findobj(allchild(0), 'flat', 'Tag', 'TMWWaitbar')); % Solves the closing issues with close(h_Waitbar);
    
    % Restore the warning state
    warning(w_old_state);
    
    % Force all diverged to NaNs
    P(:,bw_diverged) = NaN;
    
    % Keep latest R2 and SSE
    ind_latest = sub2ind([N_max_iterations+1 SD], N_iterations+1, 1:SD);
    SSres = reshape(SSres(ind_latest), 1, []); % Keep latest SSres's
    R2 = reshape(R2(ind_latest), 1, []); % Keep latest R2's
    
    % Calculate total R2 and SSE
    SSres_total = sum(SSres(:)); % Sum over the latest SSres's
    SStot_total = sum(SStot(:)); % Sum over the latest SStot's (constant with respect to iterations)
    R2_total = 1-SSres_total./SStot_total;
    
    % Reshape and ipermute the output for consistency
    SSres_total = ipermute(SSres_total, perm);
    R2_total = ipermute(R2_total, perm);
    
    R2 = ipermute(reshape(R2, [1 S(2:end)]), perm);
    SSres = ipermute(reshape(SSres, [1 S(2:end)]), perm);
    Y_fit = ipermute(reshape(Y_fit, S), perm);
    
%     figure; WITio.fun.plot.clever_nanimagesc(R2.'); daspect([1 1 1]); title('R2');
%     figure; WITio.fun.plot.clever_nanimagesc(SSres.'); daspect([1 1 1]); title('SSres');
%     
%     N_iterations = reshape(N_iterations, S(2:end));
%     bw_diverged = reshape(bw_diverged, S(2:end));
%     bw_converged = reshape(bw_converged, S(2:end));
%     bw = reshape(bw, S(2:end));
%     
%     figure; WITio.fun.plot.nanimagesc(bw.'); daspect([1 1 1]); title('If undone');
%     figure; WITio.fun.plot.nanimagesc(bw_diverged.'); daspect([1 1 1]); title('If diverged');
%     figure; WITio.fun.plot.nanimagesc(bw_converged.'); daspect([1 1 1]); title('If converged');
%     figure; WITio.fun.plot.nanimagesc(N_iterations.'); daspect([1 1 1]); title('Iterations');
    
    P = reshape(P, [SP S(2:end)]);
    P = ipermute(P, perm);
    
    T_end = now.*86400; % [s]
    T_elapsed = T_end-T_begin; % [s]
    fprintf_if_permitted('Total elapsed time = %g seconds\n', T_elapsed);
    
    % A function handle, where some of the parameters are locked
    function F = fun_with_locks(P_unlocked, X, P_locked),
        P_fun = zeros(SP, size(X, 2));
        P_fun(~locks,:) = P_unlocked;
        P_fun(locks,:) = P_locked;
        F = fun(P_fun, X);
    end
    
    % First order Taylor expansion iteration step
    function dP = solve_step(Jr2, Hr2),
        Jr2 = permute(Jr2, [2 3 1]);
        Hr2 = permute(Hr2, [2 3 1]);
        [Jr2_sparse, Hr2_sparse] = WITio.fun.fit.jacobian_and_hessian_to_1D_and_2D([], Jr2, Hr2);
        
        % Avoids NaNs from "Matrix is singular to working precision."
        bw_zdiag = diag(diag(Hr2_sparse) == 0); % Spot zero diagonals!
        Hr2_sparse(bw_zdiag) = 1e-6; % Set them non-zero but tiny
        N_zdiag = full(sum(bw_zdiag(:)));
        if N_zdiag > 0, fprintf_if_permitted('Singular Hessian matrix suspected! Resolved by artificially non-zeroing %d zero diagonal elements.\n', N_zdiag); end;
        
%         % FAST: Sparse LU factorization: (to solve A*x = B OR x = A\B)
%         % A = R*inv(P)*L*U*inv(Q) % [L,U,P,Q,R] = lu(A);
%         % A*x = R*inv(P)*L*U*inv(Q)*x = B
%         % x = Q*inv(U)*inv(L)*P*inv(R)*B = Q*(U\(L\(P*(R\B))))
%         [LL,UU,PP,QQ,RR] = lu(Hr2, [1 1]); % Sparse allows lower memory consumption and quicker inversion
%         dP = -QQ*(UU\(LL\(PP*(RR\Jr2)))); % Equivalent to dP = -Hr2\Jr2;
%         
%         % SLOW Debugging: 1st alternative (to catch warning sources)
%         dP_invRR = RR\Jr2; % inv(RR)
%         dP_PP = PP*dP_invRR; % PP
%         dP_invLL = LL\dP_PP; % inv(LL)
%         dP_invUU = UU\dP_invLL; % inv(UU)
%         dP = -QQ*dP_invUU; % QQ % Equivalent to dP = -Hr2\Jr2;
% 
%         % SLOW Debugging: 2nd alternative (to catch warning sources)
%         EYE = speye(size(Hr2)); % Identity matrix
%         inv_RR = RR\EYE; % Inverse of diagonal matrix: WARNING source
%         inv_LL = LL\EYE; % Inverse of lower triangle matrix
%         inv_UU = UU\EYE; % Inverse of upper triangle matrix: WARNING source
%         dP = -QQ*inv_UU*inv_LL*PP*inv_RR*Jr2; % Equivalent to dP = -Hr2\Jr2;
%         
%         % FASTER: Sparse LDL factorization: (to solve A*x = B OR x = A\B)
%         % Benefits from matrix A symmetry and is twice as efficient as LU.
%         % A = inv(S)*inv(P')*L*D*L'*inv(P)*inv(S); % [L,D,P,S] = ldl(A);
%         % A*x = inv(S)*inv(P')*L*D*L'*inv(P)*inv(S)*x = B
%         % x = S*P*inv(L')*inv(D)*inv(L)*P'*S*B = S*P*((L')\(D\(L\(P'*S*B))))
%         [LL,DD,PP,SS] = ldl(Hr2, 0.5); % Sparse allows lower memory consumption and sometimes quicker inversion
%         dP = -SS*PP*((LL')\(DD\(LL\(PP'*SS*Jr2)))); % Equivalent to dP = -Hr2\Jr2;
        
        % FASTEST (AND SIMPLEST)
        dP = -Hr2_sparse\Jr2_sparse;
        
        % Reshape to original
        dP = reshape(dP, SP_unlocked, []);
    end
    
    % Needed for '-silent' option
    function fprintf_if_permitted(varargin),
        if ~silent, % Test whether or not to print to Command Window
            fprintf(varargin{:});
        end
    end
end
