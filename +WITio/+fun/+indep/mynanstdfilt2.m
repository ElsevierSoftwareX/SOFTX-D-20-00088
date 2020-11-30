% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Mimics 2-D std-filtering by stdfilt in order to remove dependency on
% Image Processing Toolbox. Additionally, the A edges are technically
% padded with NaNs in order to obtain the most self-consistent windowed
% filtering. Here window size W can be a scalar or a vector and must be
% odd-valued.

% Implementation may be improved by utilizing memory of the previous
% calculus on the matrix columns and rows.

% Used by @wid/unpattern_video_stitching_helper.m
function B = mynanstdfilt2(A, W),
    if numel(W) == 1, W = [W W]; end
    if any(mod(W, 2) ~= 1), error('FAIL: Only odd-valued window sizes are accepted!'); end 
    W = (W-1)./2;
    S = size(A);
    SUM_cols = zeros(size(A));
    SUM2_cols = zeros(size(A));
    NUM_cols = zeros(size(A));
    % Loop matrix columns
    for ii = 1:S(1),
        inds = max(ii-W(1), 1):1:min(ii+W(1), S(1));
        A_ii = double(A(inds,:));
        B_isnan = isnan(A_ii);
        A_ii(B_isnan) = 0; % Ignore NaNs
        SUM_cols(ii,:) = sum(A_ii, 1);
        SUM2_cols(ii,:) = sum(A_ii.^2, 1);
        NUM_cols(ii,:) = sum(~B_isnan, 1);
    end
    SUM = zeros(size(A));
    SUM2 = zeros(size(A));
    NUM = zeros(size(A));
    % Loop matrix rows
    for ii = 1:S(2),
        inds = max(ii-W(2), 1):1:min(ii+W(2), S(2));
        SUM(:,ii) = sum(SUM_cols(:,inds), 2);
        SUM2(:,ii) = sum(SUM2_cols(:,inds), 2);
        NUM(:,ii) = sum(NUM_cols(:,inds), 2);
    end
    clear SUM_cols SUM2_cols NUM_cols;
    B = sqrt((SUM2-SUM.^2./NUM)./(NUM-1)); % Standard deviation
end
