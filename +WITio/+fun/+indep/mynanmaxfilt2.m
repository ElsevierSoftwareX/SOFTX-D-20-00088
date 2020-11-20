% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Mimics 2-D maximum-filtering by ordfilt2 in order to remove dependency on
% Image Processing Toolbox. Additionally, the A edges are technically
% padded with NaNs in order to obtain the most self-consistent windowed
% filtering. Here window size W can be a scalar or a vector and must be
% odd-valued.

% Implementation may be improved by utilizing memory of the previous
% calculus on the matrix columns and rows.

% Used by WITio.fun.correct.apply_MDLCA, WITio.fun.correct.apply_CMDLCA and
% WITio.fun.image.data_true_and_nan_collective_hole_reduction
function B = mynanmaxfilt2(A, W),
    if numel(W) == 1, W = [W W]; end
    if any(mod(W, 2) ~= 1), error('FAIL: Only odd-valued window sizes are accepted!'); end 
    W = (W-1)./2;
    S = size(A);
    if islogical(A), B_cols = false(size(A)); % Make next line backward compatible with R2011a 
    else, B_cols = zeros(size(A), class(A)); end
    % Loop matrix columns
    for ii = 1:S(1),
        inds = max(ii-W(1), 1):1:min(ii+W(1), S(1));
        B_cols(ii,:) = max(A(inds,:), [], 1);
    end
    if islogical(A), B = false(size(A)); % Make next line backward compatible with R2011a 
    else, B = zeros(size(A), class(A)); end
    % Loop matrix rows
    for ii = 1:S(2),
        inds = max(ii-W(2), 1):1:min(ii+W(2), S(2));
        B(:,ii) = max(B_cols(:,inds), [], 2);
    end
end
