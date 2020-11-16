% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.

function varargout = dim_size_consistent_repmat(varargin),
    % Function repmats all inputs so that they all are equivalent in size.
    % First it tests if input sizes are consistent with each other.
    % For each input, each dimension is consistent if 1) it is singleton
    % OR 2) all nonsingleton input dimension sizes are equivalent.
    % If inconsistency is found, then function returns error.
    
    %% EXAMPLE 1: Equivalent case with meshgrid
    % Inputs with sizes [1 10], [70 1] produce outputs with size [70 10].
    % x = 1:10; % size(x) == [1 10]
    % y = 1:70; % size(y) == [1 70]
    % [X1, Y1] = meshgrid(x, y); % size(X1) == [10 70], size(Y1) == [10 70]
    % [X2, Y2] = wit.io.fun.dim_size_consistent_repmat(x, y'); % Notice the transpose!
    % Here X1, Y1 are equivalent to X2, Y2!
    
    %% EXAMPLE 2: Complex case
    % Inputs with sizes [500 10 1 4], [1 10], [1 1], [1 10 3], [1 10 1 4]
    % produce outputs with size [500 10 3 4].
    % a = randn([500 10 1 4]);
    % b = randn([1 10]);
    % c = randn([1 1]);
    % d = randn([1 10 3]);
    % e = randn([1 10 1 4]);
    % [A, B, C, D, E] = wit.io.fun.dim_size_consistent_repmat(a, b, c, d, e);
    % size(A) % [500 10 3 4]
    
    %% CODE
    if nargin > 0, % If inputs given
        % Get input dimension counts
        NDIMS_in = zeros(nargin, 1);
        for ii = 1:nargin, NDIMS_in(ii) = ndims(varargin{ii}); end
        ndims_max = max(NDIMS_in); % Find maximum dimension count

        % Get input sizes (with 1-padding)
        SIZE_in = ones(nargin, ndims_max);
        for ii = 1:nargin, SIZE_in(ii,1:NDIMS_in(ii)) = size(varargin{ii}); end

        % Find singletons for consistency test and repmat
        is_singleton = SIZE_in == 1;

        % Output size
        size_out = max(SIZE_in, [], 1);
        SIZE_out = repmat(size_out, [nargin 1]); % Repmat to simplify code

        % Test dimension size consistency
        is_out_consistent = SIZE_in == SIZE_out; % If consistent with output size
        is_consistent = (~is_singleton & is_out_consistent) | is_singleton;
        if any(~is_consistent(:)), error('Inconsistent dimension sizes!'); end

        % Repmat singleton dimensions to reach output size
        repmat_out = ones(nargin, ndims_max);
        repmat_out(is_singleton) = SIZE_out(is_singleton); % Replace singletons

        % Create dimension size consistent output
        for ii = nargin:-1:1, varargout{ii} = repmat(varargin{ii}, repmat_out(ii,:)); end
    end
end
