% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% KEY ASSUMPTIONS FOR EACH SPECIFIED DATASET:
% (1) There is only one lineshape.
% (2) The lineshape tails disappear to the background noise.
% (3) The background slope has been removed.
% (4) The dark count offset may be present.
% (5) There are no random cosmic ray peaks or other anomalous data points.

% Returns a 2-D matrix P0, where P0(1,:), P0(2,:), P0(3,:) and P0(4,:)
% represent rough estimates of I (= Intensity), Pos (= Position), Fwhm
% (= Full width at half maximum) and I0 (= Offset), respectively. Resulting
% size(P0, 2) == numel(Y)/size(Y, dim), because the dim'th dimension was
% truncated.

% IDEAS:
% * Add N for number of lineshapes, related to a needed automated feature
% to iteratively guess MULTIPLE PEAKS by some method. It may be possible
% to implement such a feature by the residual procedure or the second
% derivative procedure (in combination of reliable smoothening algorithm).
% If it uses a simplified lineshape (i.e. Lorentzian), then it should warn
% the user. If it does not, then it should take function as input fun.
% The peaks are then guessed gradually based on the lineshape. (25.6.2019)
function P0 = fit_lineshape_automatic_guess(x, Y, dim),
    if nargin < 3, dim = 3; end % By default, operate 3rd or spectral dimension
    
    %% INITIAL GUESS
    [Y, perm] = dim_first_permute(Y, dim); % Permute dim to first
    S_orig = size(Y); % Dimensions of permuted matrix Y
    
    Y = Y(:,:); % Operate on the 1st dimension and merge the rest
    x = x(:); % Force column vector
    
    % Convert to double
    Y = double(Y);
    x = double(x);
    
    % Discard all-NaN datasets (to be restored later in the end)
    B_allnan = all(isnan(Y), 1);
    Y = Y(:,~B_allnan);
    S = size(Y);

    %% ESTIMATE INITIAL PARAMETERS
    % Estimate lineshape dark count offset
    I0 = min(Y, [], 1); % Noise sensitive parameter
    
    % Remove the dark count offset
    Y = bsxfun(@minus, Y, I0);
    
    % Estimate lineshape intensity
    I = max(Y, [], 1); % Noise sensitive parameter
    
    % Estimate lineshape integrated intensity
    A = mtrapz(x, Y, 1); % Robust parameter but overestimates, especially when the lineshape is fully within range.
    % IDEA: Readjust area estimator based on the found Fwhm
    % For Lorentzian function:
    % A = I.*Fwhm.*(atan(2.*A./Fwhm) + atan(2.*B./Fwhm))./2; % Integrated from Pos-A to Pos+B
    % A = I.*Fwhm.*atan(2); % Integrated from Pos-Fwhm to Pos+Fwhm
    % A = I.*Fwhm.*pi./2; % Integrated from -inf to inf
    
    % Estimate lineshape position using center of mass
    Pos = mtrapz(x, bsxfun(@times, x, Y), 1) ./ A; % Robust parameter
    
    % IDEA: Consider iterating cosmic rays away using antilines until none
    % is found anymore (17.12.2019)
    
    % Consider using the fact that for a Lorentzian function A_Fwhm = I.*Fwhm.*atan(2);
    
    % Find all possible peak regions using the Fwhm definition
    B_peaks = bsxfun(@ge, Y, 0.5.*I).'; % Transpose needed
    
    % First: FIND and FILL-IN short-length antilines (or holes)
    % Determine B lengths per spectrum or 2nd dimension
    antiline_length = bw2lines(~B_peaks); % Convert B to lines
    B_peaks(antiline_length >= 1 & antiline_length <= 2) = true; % Fill in (reduce effect of noise)
    
    % Second: FIND and KEEP best-length lines
    % Determine B lengths per spectrum or 2nd dimension
    line_length = bw2lines(B_peaks); % Convert B to lines
    line_length = line_length.'; % Transpose only once
    best_line_length = max(line_length, [], 1); % Best lengths per spectrum
    B_widest_peak = bsxfun(@eq, line_length, best_line_length); % Highlight best
    B_widest_peak = line_length >= 3 & B_widest_peak; % Require minimum of 3
    
    % Third: FIND Fwhm indices
    cumsum_B = cumsum(B_widest_peak, 1);
    cumsum_B(~B_widest_peak) = NaN;
    [~, idx_min] = min(cumsum_B, [], 1);
    [~, idx_max] = max(cumsum_B, [], 1);
    B_peak_found = any(B_widest_peak, 1); % Pixels to be changed
    idx_min = idx_min(B_peak_found);
    idx_max = idx_max(B_peak_found);
    x_min = x(idx_min);
    x_max = x(idx_max);
    
    % IMPROVE BY IMPLEMENTING INTERPOLATION!
%     % Fourth: INTERPOLATE Fwhm positions
%     Y_min_upper = Y(idx_min,:);
%     x_min_upper = x(idx_min);
%     Y_max_lower = Y(idx_max,:);
%     x_max_lower = x(idx_max);
%     
%     B_min_nocut = idx_min > 1;
%     Y_min_nocut_lower = Y(idx_min(B_min_nocut)-1,:);
%     x_min_nocut_lower = x(idx_min(B_min_nocut)-1);
%     Y_min_nocut_upper = Y_min_upper(B_min_nocut,:);
%     x_min_nocut_upper = x_min_upper(B_min_nocut);
%     
%     B_max_nocut = idx_max < S(1);
%     Y_max_nocut_upper = Y(idx_max(B_max_nocut)+1,:);
%     x_max_nocut_upper = x(idx_max(B_max_nocut)+1);
%     Y_max_nocut_lower = Y_max_lower(B_max_nocut,:);
%     x_max_nocut_lower = x_max_lower(B_max_nocut);
%     
%     % Linear interpolation
%     % y = y0 + (x-x0).*(y1-y0)./(x1-x0);
%     % x = x0 + (x1-x0).*(y-y0)./(y1-y0);
%     X_min_nocut = bsxfun(@plus, x_min_nocut_lower, bsxfun(@times, x_min_nocut_upper-x_min_nocut_lower, bsxfun(@minus, 0.5.*I, Y_min_nocut_lower))./(Y_min_nocut_upper-Y_min_nocut_lower));
%     X_max_nocut = bsxfun(@plus, x_max_nocut_lower, bsxfun(@times, x_max_nocut_upper-x_max_nocut_lower, bsxfun(@minus, 0.5.*I, Y_max_nocut_lower))./(Y_max_nocut_upper-Y_max_nocut_lower));
%     
%     % Assume symmetry and fill-in the missing parts
%     X_min_cut = bsxfun(@minus, 2.*Pos, X_max_nocut(~B_min_nocut(B_max_nocut),:));
%     X_max_cut = bsxfun(@minus, 2.*Pos, X_min_nocut(~B_max_nocut(B_min_nocut),:));
    
    % Estimate lineshape full width at half maximum (= 2./pi.*A./I; for a Lorentzian function)
%     Fwhm2 = 2./pi.*A./I; % True for a common Lorentzian function
    Fwhm = ones(1, S(2)); % If no peak found: try a midpoint Fwhm of range 0-2
    Fwhm(B_peak_found) = x_max-x_min;  % Better estimate for those with Fwhm

    % Combine estimates (and handle all nan datasets)
    P0 = nan(4, prod(S_orig(2:end)));
    P0(1,~B_allnan) = I;
    P0(2,~B_allnan) = Pos;
    P0(3,~B_allnan) = Fwhm;
    P0(4,~B_allnan) = I0;
    
%     P0 = reshape(P0, S_orig);
%     P0 = ipermute(P0, perm);
end
