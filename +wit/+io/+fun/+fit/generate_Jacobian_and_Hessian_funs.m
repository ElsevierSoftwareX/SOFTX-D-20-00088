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

% This can be used to validate the analytical solutions of the lineshape's
% Jacobian and Hessian matrices (if they exist). Although this requires
% Symbolic Math Toolbox, it is not programmatically used by wit_io.
function [fun_Jf, fun_Hf, exception] = generate_Jacobian_and_Hessian_funs(fun_f, N_constants, N_steps),
    % Generates Jacobian and Hessian (if possible).
    % If not possible, return empty Jf and Hf, and generate exception.
    
    % Default number of simplification steps
    if nargin < 3, N_steps = 1; end
    
    % Assume all parameters are variables
    if nargin < 2, N_constants = 0; end
    
    % If no given input, Lorentzian function is set as an example.
    if nargin < 1,
        fun_f = @(X, A, B, C, D) A ./ (1 + (2.*(X-B)./C).^2) + D;
        N_constants = 1; % Consider 'X' as a constant.
    end
    
    exception = []; % Return no exception by default
    try
        % Get function parameters
        str_fun_f = func2str(fun_f);
        str_fun_params = regexp(str_fun_f, '@\(([^\)]*)\)', 'tokens', 'once');
        str_fun_params_split = regexp(str_fun_params{1}, '\s*,\s*', 'split');
        str_fun_vars_split = str_fun_params_split((N_constants+1):end);
        N_variables = numel(str_fun_vars_split);
        
        % Generate symbolic variable matrix
        X = sym('v', [1 N_variables]);
        for ii = 1:N_variables,
            X(ii) = sym(str_fun_vars_split{ii});
        end
        
        % Convert function handle to symbolic function
        f = sym(fun_f);
        f = simplify(f, N_steps);

        % Generate symbolic Jacobian matrix
        Jf = sym('Jf', [1 N_variables]);
        for ii = 1:N_variables,
            Jf(ii) = diff(f, X(ii));
            Jf(ii) = simplify(Jf(ii), N_steps);
        end

        % Generate symbolic Hessian matrix
        Hf = sym('Hf', [N_variables N_variables]);
%         kk = 1;
        for ii = 1:N_variables,
            for jj = 1:N_variables,
                Hf(ii,jj) = diff(Jf(ii), X(jj)); % dJf_ii/dX_jj = d(df/dX_ii)/dX_jj = d^2f/dX_jjdX_ii
                Hf(ii,jj) = simplify(Hf(ii,jj), N_steps);
%                 Hf(ii,jj) = kk;
%                 kk = kk + 1;
            end
        end

        % Convert symbolic function matrices to function handle matrices
        fun_Jf = matlabFunction(Jf, 'Vars', str_fun_params_split); % Keep original parameters
        fun_Hf = matlabFunction(Hf, 'Vars', str_fun_params_split); % Keep original parameters
    catch exception
        [fun_Jf, fun_Hf] = deal([]); % Generation unsuccessful!
    end
end
