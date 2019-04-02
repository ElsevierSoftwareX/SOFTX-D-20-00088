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
% This is CLEVER-statistics version of MRLCM-algorithm, described below.
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% MRLCM-algorithm (or its data-transformed MDLCA-algorithm) tries to fix
% horizontal scanline errors. MRLCM (or MDLCA) corrects scanline errors,
% which are MULTIPLICATIVE (or ADDITIVE) in its physical nature like in
% Raman peak intensity data (or Raman peak position or AFM height data)!
%-------------------------------------------------------------------------%

% First version of MRLCM-algorithm was presented in Master Thesis
% (pp. 27–28, 35), J. T. Holmi (2016) "Determining the number of graphene
% layers by Raman-based Si-peak analysis", freely available to download at:
% http://urn.fi/URN:NBN:fi:aalto-201605122027
% The automated mask generation in this algorithm (and its data-transformed
% version) heavily rely on the code in clever_statistics_and_outliers.m.
function [out_2D, correction_2D, mask_2D] = apply_CMRLCM(in_2D, dim, mask_2D)
    % CLEVER Median Ratio Line Correction by Multiplication. This
    % MULTIPLICATIVE method preserves RATIOS (but does NOT preserve
    % DIFFERENCES)! In order to preserve DIFFERENCES, use ADDITIVE method
    % (CMDLCA) instead!
    
    % Median is used because it is one of the most outlier resistant
    % statistic with breakdown point of 50% dataset contamination. Also,
    % it sees true median behind multiplicative and additive constants,
    % because median(B) = median(c*A+d) = c*median(A)+d.
    
    % Updated 12.3.2019 by Joonas T. Holmi
    
    % Use the fact that CMRLCM = CMDLCA for log-transformed data!
    % log(rX) = log(Xa./Xb) = log(Xa)-log(Xb) = Ya-Yb = dY
    % log(rX) = dY OR rX = exp(dY) AND log(X) = Y OR X = exp(Y)
    in_2D = double(in_2D); % Required for boolean and integer input
    in_2D = log(in_2D); % Complex input are excluded by apply_MDLCA!
    if nargin < 3, [out_2D, correction_2D, mask_2D] = apply_CMDLCA(in_2D, dim);
    else, [out_2D, correction_2D, mask_2D] = apply_CMDLCA(in_2D, dim, mask_2D); end
    % Then restore linear-transformed data!
    out_2D = real(exp(out_2D)); % And ensure that imaginary-part is removed!
    correction_2D = real(exp(correction_2D)); % And ensure that imaginary-part is removed!
end
