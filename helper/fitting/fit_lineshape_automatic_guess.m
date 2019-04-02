% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Returns a 2-D matrix P0, where P0(1,:), P0(2,:), P0(3,:) and P0(4,:)
% represent rough estimates of I (= Intensity), Pos (= Position), Fwhm
% (= Full width at half maximum) and I0 (= Offset), respectively. Resulting
% size(P0, 2) == numel(Y)/size(Y, dim), because the dim'th dimension was
% truncated.
function [P0] = fit_lineshape_automatic_guess(x, Y, dim)
    % Written by Joonas T. Holmi
    if nargin < 3, dim = 3; end % By default, operate 3rd or spectral dimension
    
    %% INITIAL GUESS
    [Y, perm] = dim_first_permute(Y, dim); % Permute dim to first
    S = size(Y); % Dimensions of permuted matrix Y
    Y = Y(:,:); % Operate on first dimension

    % Convert to double
    Y = double(Y);
    x = double(x);

    SD = prod(S(2:end)); % Number of datasets
    x = x(:); % Force column vector

    X = repmat(x, [1 SD]);

    %% GUESS INITIAL PARAMETERS
    % Robust way (less sensitive to noise)
    [Y_sort_ascend, ~] = sort(Y, 1, 'ascend'); % Sort once
    N_samples = 2; % How many samples to estimate min and max
    if S(1) < N_samples, N_samples = S(1); end % Reduce sample # if needed
    [idx_Y_sort_ascend_max, ~] = bw2lines(~isnan(Y_sort_ascend)'); % Handle NaNs
    idx_Y_sort_ascend_max = idx_Y_sort_ascend_max(:,1);
    Y_max = median(Y_sort_ascend(1+idx_Y_sort_ascend_max-N_samples:idx_Y_sort_ascend_max,:), 1);
    Y_min = median(Y_sort_ascend(1:N_samples,:), 1);
    clear Y_sort_ascend;

    [X_min, ~] = min(X, [], 1);
    [X_max, ~] = max(X, [], 1);

    % Determine FWHM
    bw_peak = bsxfun(@ge, Y, 0.5.*(Y_max-Y_min))'; % Transpose needed

    % First: FIND and FILL-IN short-length antilines (or holes)
    % Determine bw lengths per spectrum or 2nd dimension
    [antiline_length, ~] = bw2lines(~bw_peak); % Convert bw to lines
    bw_peak(antiline_length >= 1 & antiline_length <= 2) = true; % Fill in (reduce effect of noise)

    % Second: FIND and KEEP best-length lines
    % Determine bw lengths per spectrum or 2nd dimension
    [line_length, ~] = bw2lines(bw_peak); % Convert bw to lines
    clear bw_peak;
    best_line_length = max(line_length', [], 1); % Best lengths per spectrum
    bw_best_peak = bsxfun(@eq, line_length', best_line_length); % Highlight best
    bw_best_peak = line_length' >= 2 & bw_best_peak; % Require minimum of 3

    % Third: ESTIMATE FWHM 
    cumsum_bw = cumsum(bw_best_peak, 1);
    cumsum_bw(~bw_best_peak) = NaN;
    [~, idx_min] = min(cumsum_bw, [], 1);
    [~, idx_max] = max(cumsum_bw, [], 1);
    bw_FWHM = any(bw_best_peak, 1); % Pixels to be changed

    Fwhm = (X_max-X_min)./10; % FWHM
    Fwhm(bw_FWHM) = x(idx_max(bw_FWHM))-x(idx_min(bw_FWHM));  % Better estimate for those with FWHM

    % Determine Center
    Pos = x(idx_Y_sort_ascend_max)'; % Center
    Pos(bw_FWHM) = (x(idx_max(bw_FWHM))+x(idx_min(bw_FWHM)))./2; % Center of mass in middle of FWHM

    % Determine Amplitude
    I = Y_max-Y_min; % Amplitude
    I(bw_FWHM) = (Y_max(bw_FWHM)-Y_min(bw_FWHM)).*(1+1./(2.*(X_min(bw_FWHM)-Pos(bw_FWHM))./Fwhm(bw_FWHM)).^2); % Ensure that function amplitude fits well

    % Determine Offset
    I0 = Y_min; % Offset
    I0(bw_FWHM) = Y_max(bw_FWHM) - I(bw_FWHM); % Ensure that at graph boundaries function fits well

    P0 = cat(1, I, Pos, Fwhm, I0);
    
%     P0 = reshape(P0, [SP S(2:end)]);
%     P0 = ipermute(P0, perm);
end
