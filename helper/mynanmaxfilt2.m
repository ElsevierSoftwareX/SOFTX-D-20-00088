% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Mimics 2-D maximum-filtering by ordfilt2 in order to remove dependency on
% Image Processing Toolbox. Additionally, the A edges are technically
% padded with NaNs in order to obtain the most self-consistent windowed
% filtering. Here window size W can be a scalar or a vector and must be
% odd-valued.

% Used by apply_MDLCA.m, apply_CMDLCA.m and
% data_true_and_nan_collective_hole_reduction.m
function B = mynanmaxfilt2(A, W),
    if numel(W) == 1, W = [W W]; end
    if any(mod(W, 2) ~= 1), error('FAIL: Only odd-valued window sizes are accepted!'); end 
    W = (W-1)./2;
    S = size(A);
    B_cols = zeros(size(A), 'like', A);
    % Loop matrix columns
    for ii = 1:S(1),
        inds = max(ii-W(1), 1):1:min(ii+W(1), S(1));
        B_cols(ii,:) = max(A(inds,:), [], 1);
    end
    B = zeros(size(A), 'like', A);
    % Loop matrix rows
    for ii = 1:S(2),
        inds = max(ii-W(2), 1):1:min(ii+W(2), S(2));
        B(:,ii) = max(B_cols(:,inds), [], 2);
    end
end
