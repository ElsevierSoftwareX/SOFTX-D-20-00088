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

function [J, H] = jacobian_helper(tol_abs, tol_rel, F, Y, usePrevCstd, varargin),
    % Evaluate numerical sparse Jacobian matrix, J for 2-D matrix function
    % F(Y, varargin{:}), where size(Y) = [# of variables, # of samples] and
    % size(F) = [# of dimensions, # of samples]. Also, Hessian matrix, H is
    % calculated if such output is requested. The varargin represent
    % constants, for which 2nd dim size = # of samples OR 1.
    % OUTPUT: In general, size(J) = [numel(F), size(Y, 1)] and
    % size(H) = [numel(F), size(Y, 1).^2] due to independency of samples.
    % NOTE: If the first evaluation, then automatically tries to
    % precalculate in order to speed-up the consequent iterations.
    
    % The numerical J and H have been compared to and verified with
    % MATLAB-GENERATED ANALYTICAL SOLUTIONS using helper function
    % 'WITio.fun.fit.generate_Jacobian_and_Hessian_funs' (14.8.2018)!
    
    Y = Y(:,:); % Force input a 2-D matrix
    S = size(Y); % [# of variables, # of samples]
    F_Y = F(Y, varargin{:});
    S_F = size(F_Y); % [# of dimensions, # of samples]
    f_Y = F_Y(:); % Force a column vector
    if isempty(tol_abs), tol_abs = 1e-6; end % Absolute tolerance for input y perturbation
    if isempty(tol_abs), tol_rel = 1e-6; end % Relative tolerance for input y perturbation
    
    % IMPLEMENTATION IDEA: Consider round-off errors like in numjac!
    
%     persistent F_prev S_Y S_J S_H varargin_prev varargin_J varargin_H K1 K2 cstd;
    persistent F_prev S_Y S_J S_H cstd;
    if isempty(F_prev) || ~isequal(F, F_prev) || ...
            any(S_Y ~= S) || any(S_J ~= [prod(S_F) S(1)]), % || ...
%             ~isequal(varargin, varargin_prev),
        % Reset the cycle IF the first time OR the relevant parameters are
        % changed from the previous round!
        F_prev = F; % Store the matrix function handle for comparison
        S_Y = S;
        S_J = [prod(S_F) S(1)];
        S_H = [prod(S_F) S(1).^2];
        
%         % Repmat the non-scalar varargin
%         varargin_prev = varargin;
%         bw = cellfun(@numel, varargin) > 1; % Find non-scalars
%         % For Jacobian evaluation
%         varargin_J = varargin;
%         varargin_J(bw) = cellfun(@(x) repmat(x, [1 S(1)]), varargin_J(bw), 'UniformOutput', false);
%         % For Hessian evaluation
%         varargin_H = varargin;
%         varargin_H(bw) = cellfun(@(x) repmat(x, [1 S(1).^2]), varargin_H(bw), 'UniformOutput', false);
%         
%         % Precalculated values and matrices
%         K1 = kron(speye(S(1)), ones(1, S(2)));
%         K2 = kron(speye(S(1)), ones(1, S(1).*S(2)));

        if isempty(cstd) || ~usePrevCstd,
            [~, ~, cvar] = WITio.fun.clever_statistics_and_outliers(Y, [], 4); % May become extremely costly in loops
            if isnan(cvar), cvar = 0; end
            cstd = sqrt(cvar);
        end
    end
    
    % Repmat-version (memory intensive!)
%     % Try balance between relative and absolute tolerances!
%     dy = tol_abs + tol_rel.*cstd;
%     % Create perturbed samples of Y
%     Y_perturbed = repmat(Y, [1 S(1)]) + dy.*K1; % repmat-bottleneck
%     % Calculate F for each perturbed sample
%     F_Y_perturbed = reshape(F(Y_perturbed, varargin_J{:}), S_J);
%     % Calculate Jacobian matrix
%     J = bsxfun(@minus, F_Y_perturbed, f_Y)./dy;
%     % Calculate Hessian matrix (if asked for)
%     if nargout > 1,
%         % Calculate twice perturbed samples of Y
%         Y_twice_perturbed = repmat(Y_perturbed, [1 S(1)]) + dy.*K2; % repmat-bottleneck
%         % Calculate F for each twice perturbed sample
%         F_Y_twice_perturbed = reshape(F(Y_twice_perturbed, varargin_H{:}), S_H);
%         % Calculate H (But avoid too small tol_abs and tol_rel!)
%         J_perturbed = (F_Y_twice_perturbed-repmat(F_Y_perturbed, 1, S(1)))./dy;
%         H = (J_perturbed-repelem(J, 1, S(1)))./dy;
%     end
    
%     % Simple loop-version (as fast as above but NOT MEMORY INTENSIVE!)
%     dy = tol_abs + tol_rel.*cstd; % Try balance between relative and absolute tolerances!
%     J = zeros(S_J);
%     if nargout > 1, H = zeros(S_H); end
%     for jj = 1:S(1),
%         Y_perturbed = Y; % Unperturbed
%         Y_perturbed(jj,:) = Y_perturbed(jj,:) + dy; % Perturb for each independent sample
%         f_Y_perturbed = F(Y_perturbed, varargin{:});
%         J(:,jj) = (f_Y_perturbed(:) - f_Y)./dy; % Row
%         if nargout > 1, % Calculate Hessian matrix (if asked for)
%             for ii = 1:S(1),
%                 Y_perturbed_2 = Y; % Unperturbed
%                 Y_perturbed_2(ii,:) = Y_perturbed_2(ii,:) + dy; % Perturb for each independent sample
%                 f_Y_perturbed_2 = F(Y_perturbed_2, varargin{:});
%                 Y_twice_perturbed = Y_perturbed; % Perturbed once
%                 Y_twice_perturbed(ii,:) = Y_twice_perturbed(ii,:) + dy; % Perturb twice for each independent sample
%                 f_Y_twice_perturbed = F(Y_twice_perturbed, varargin{:});
%                 J_ii_jj = (f_Y_twice_perturbed(:) - f_Y_perturbed_2(:))./dy; % Row
%                 H(:,sub2ind([S(1) S(1)], ii, jj)) = (J_ii_jj - J(:,jj))./dy;
%             end
%         end
%     end
    
    % Optimized loop-version (MUCH FASTER + LOW BURDEN ON MEMORY!)
    dy = tol_abs + tol_rel.*cstd; % Try balance between relative and absolute tolerances!
    J = zeros(S_J); % Preallocate for speed-up!
    if nargout > 1, H = zeros(S_H); end % Preallocate for speed-up!
    Y_perturbed = Y; % Preallocate for speed-up!
    Y_twice_perturbed = Y; % Preallocate for speed-up!
    f_Y_perturbed = zeros(S_J); % Preallocate for speed-up!
    for jj = 1:S(1),
        % Calculate Jacobian matrix
        Y_perturbed(jj,:) = Y(jj,:) + dy; % Perturb for each independent sample
        f_Y_perturbed(:,jj) = reshape(F(Y_perturbed, varargin{:}), prod(S_F), 1);
        J(:,jj) = (f_Y_perturbed(:,jj) - f_Y)./dy; % Row
        if nargout > 1, % Calculate Hessian matrix (if asked for)
            Y_twice_perturbed(jj,:) = Y_perturbed(jj,:); % Perturb for each independent sample
            for ii = 1:jj, % Discard the UPPER TRIANGULAR for speed-up!
                Y_twice_perturbed(ii,:) = Y_perturbed(ii,:) + dy; % Perturb twice for each independent sample
                f_Y_twice_perturbed = F(Y_twice_perturbed, varargin{:});
                J_ii_jj = (f_Y_twice_perturbed(:) - f_Y_perturbed(:,ii))./dy; % Row
                ind = ii + (jj-1).*S(1); % Wikipedia definition
                H(:,ind) = (J_ii_jj - J(:,jj))./dy;
                if ii ~= jj, % RELY ON SYMMETRY of second derivatives!
                    ind_symmetric = jj + (ii-1).*S(1);
                    H(:,ind_symmetric) = H(:,ind); % Copy from lower to upper triangle!
                    Y_twice_perturbed(ii,:) = Y_perturbed(ii,:); % Unperturb
                end
            end
            Y_twice_perturbed(jj,:) = Y(jj,:); % Unperturb
        end
        Y_perturbed(jj,:) = Y(jj,:); % Unperturb
    end
end
