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

%-------------------------------------------------------------------------%
% This is CLEVER-statistics version of MDLCA-algorithm, described below.
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% MDLCA-algorithm (or its data-transformed MRLCM-algorithm) tries to fix
% horizontal scanline errors. MDLCA (or MRLCM) corrects scanline errors,
% which are ADDITIVE (or MULTIPLICATIVE) in its physical nature like in
% Raman peak position or AFM height data (or Raman peak intensity data)!
%-------------------------------------------------------------------------%

% First version of MRLCM-algorithm was presented in Master Thesis
% (pp. 27–28, 35), J. T. Holmi (2016) "Determining the number of graphene
% layers by Raman-based Si-peak analysis", freely available to download at:
% http://urn.fi/URN:NBN:fi:aalto-201605122027
% The automated mask generation in this algorithm (and its data-transformed
% version) heavily rely on the code in clever_statistics_and_outliers.m.

function [out_2D, correction_2D, mask_2D] = WITio.fun.correct.apply_CMDLCA(in_2D, dim, mask_2D),
    % CLEVER Median Difference Line Correction by Addition. This ADDITIVE
    % method preserves DIFFERENCES (but does NOT preserve RATIOS)! In order
    % to preserve RATIOS, use MULTIPLICATIVE method (CMRLCM) instead!
    
    % Median is used because it is one of the most outlier resistant
    % statistic with breakdown point of 50% dataset contamination. Also,
    % it sees true median behind multiplicative and additive constants,
    % because median(B) = median(c*A+d) = c*median(A)+d.
    
    % Updated 6.11.2020 by Joonas T. Holmi
    
    in_2D = double(in_2D); % Required for boolean and integer input
    if nargin < 3 || isempty(mask_2D),
        mask_2D = true(size(in_2D)); % By default use all data
    end
    
    % Permute scanline dimension (= dim) to 1st
    [in_2D, perm] = WITio.fun.dim_first_permute(in_2D, dim); % Permute dim to first
    mask_2D = permute(mask_2D, perm); % Permute dim to first
    % Consider implementing PRIMARY and SECONDARY dim (to identify 2-D scan
    % dimensions) and assume that the content of the remaining dimensions
    % (like Spectral dimension in 3rd dim) is instantaneous in nature. It
    % may unlock superiour correction algorithm vs. the current version.
    
    % NOTE: Masking mode is INCLUSION!
    bw_imag = imag(in_2D) ~= 0; % Handle MRLCM-case (log-transformed input)
    bw_imag = bw_remove_pixel_noise(bw_imag, false); % Safely remove the one-pixel false-noise
    mask_2D(bw_imag) = false; % Exclude complex log-transformed input (or negative values in MRLCM-side) to avoid undetermined behaviour.
    in_2D = real(in_2D); % Keep only the real part
    
    % AUTOMATICALLY DETECT NON-UNIFORM AREAS AND EXCLUDE
    % Exploit the fact that PRIMARY scan direction is most likely not
    % glitching (although is known to glitch as well). Evaluate mean of two
    % neighbouring differences along PRIMARY scan direction, because it
    % often contains more information than single-pixel difference due to
    % pixel-to-pixel correlations.
    d2_unpadded = (in_2D(:,3:end)-in_2D(:,1:end-2))./2;
    d2 = nan(size(d2_unpadded, 1), size(d2_unpadded, 2)+2);
    d2(:,2:end-1) = d2_unpadded; % d2 = padarray(d2_unpadded, [0 1], NaN, 'both');
    d2(~mask_2D) = NaN; % Honor original mask
    
    mask_2D = WITio.fun.clever_statistics_and_outliers(d2, [], 2); % 2-sigma clever mean and variance (outlier detection included)
    mask_2D = bw_remove_pixel_noise(~mask_2D, false); % Invert mask and safely remove the one-pixel false-noise
    mask_2D = bw_remove_pixel_noise(mask_2D, true); % Safely remove the one-pixel true-noise
    mask_2D(isnan(d2)) = false; % Honor original mask
    
    %% Input matrix
    out_2D = in_2D; % Store original data
    in_2D(~mask_2D) = NaN; % Ignore all non-flat areas
    
    % In principle, sets median differences along SECONDARY scan direction to zero.
    d = in_2D(2:end,:)-in_2D(1:end-1,:); % Difference matrix (between neighbouring pixels along SECONDARY scan direction)
    [~, ~, ~, ~, m] = WITio.fun.clever_statistics_and_outliers(d, 2, 2); % Clever median
    m(isnan(m)) = 0; % Preserve differences between fully unused rows
    correction_2D = [0; cumsum(m)]; % Calculate correction vector
    
    %% Output matrix
    correction_2D = repmat(correction_2D, [1 size(out_2D, 2)]);
    
    % Use ADDITIVE correction factor (PRESERVES DIFFERENCES)
    out_2D = out_2D-correction_2D;
    out_2D(bw_imag) = out_2D(bw_imag) + 1i.*pi; % Handle MRLCM-case (log-transformed input)
    
    % Permute matrices back to original
    out_2D = ipermute(out_2D, perm);
    correction_2D = ipermute(correction_2D, perm);
    mask_2D = ipermute(mask_2D, perm);
    
    %% MEMBER FUNCTIONS
    function bw = bw_remove_pixel_noise(bw, bw_noise_type),
        % Safely remove the one-pixel (either true or false) noise
        D = WITio.lib.bwdistsc2d.bwdistsc2d(xor(bw, bw_noise_type)); % Get the Euclidean distance
        D_nearby = WITio.fun.mynanmaxfilt2(D, 3); % Get maximum of 4-conn neighbours
        bw(D_nearby <= 1) = ~bw_noise_type; % Remove the one-pixel noise (that are surrounded by one-pixel noise)
    end
end
