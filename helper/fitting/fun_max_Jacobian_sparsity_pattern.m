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

function J_pattern = fun_max_Jacobian_sparsity_pattern(F, Y, varargin),
    % Find the maximal Jacobian sparsity pattern by NaN-value probing. This
    % function accepts a 2-D matrix function F(Y, varargin{:}) with a
    % working 2-D input example, where size(F, 2) == size(Y, 2). Here
    % size(Y) = [# of variables per sample, # of samples] and size(F) =
    % [# of dimensions per sample, # of samples].
    % MOTIVATION: The 2-D matrix function can be used to obtain the maximal
    % Hessian (or transposed Jacobian of Jacobian) matrix sparsity pattern.
    % Implemented 19.7.2018
    S = size(Y); % Should be [# of variables per sample, # of samples]
    F_Y = F(Y, varargin{:});
    S_F = size(F_Y); % Should be [# of dimensions per sample, # of samples]
    % Test if output size ok
    if numel(S) > 2 || numel(S_F) > 2, error('FAIL: Function input Y and output F must be 2-D!'); end
    if S_F(2) ~= S(2), error('FAIL: Function output F is not consistent with input Y!'); end
    % Upon success, continue by determining the Jacobian matrix dimensions
    N_cols = S(1).*S(2); % Jacobian matrix columns
    N_rows = S_F(1).*S(2); % Jacobian matrix rows (from Wikipedia def.)
    % Test if F supports the NaN-value probing
    try
        F_Y2 = F(nan(size(Y)), varargin{:}); % Test if call ok
        assert(all(size(F_Y2) == S_F)); % Test if output size ok
        % K = kron(eye(S(2)), ones(S(1),S(1).*S_F(1)));
        % Probe the maximal Jacobian sparsity pattern using NaNs!
        if N_cols*N_rows > 5e8, J_pattern = logical(spalloc(N_rows, N_cols, N_rows)); % Begin with minimal N_row preallocations and then allocate memory dynamically (slower but avoids out-of-memory issues)
        else, J_pattern = false(N_rows, N_cols); end % Max 500 MBytes preallocation
        for jj = 1:numel(Y), % Loop through all variables
            Y_with_nan = Y;
            Y_with_nan(jj) = NaN; % Set one variable to NaN
            bwnan = isnan(F(Y_with_nan, varargin{:})); % Test for NaN effect
            J_pattern(:,jj) = bwnan(:); % Each column = each variable's NaN effects
            % Carefully assign the Jacobian matrix elements, which must be
            % changing as follows:
            % For rows: [dim, sample]. For cols: [var, sample].
            % This is done so in order to extract the pattern of Nth dim
            % easily by reshaping and accessing the first dimension:
            % J_pattern_reshaped = reshape(J_pattern, S_F(1), []);
            % J_pattern_1 = reshape(J_pattern_reshaped(1,:), [S(2) S(1)*S(2)]);
        end
    catch
        error('FAIL: Function cannot be NaN-value probed!');
    end
    J_pattern = sparse(J_pattern); % Sparsify if not sparse
%     figure; spy(J_pattern); % For debugging
end
