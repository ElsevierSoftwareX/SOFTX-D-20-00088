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

% Used by wit.io.fun.fit.fit_lineshape_automatic_guess
function [line_length, line_label] = bw2lines(bw_lines),
    % Function converts the 2nd dimension of a boolean map to lines.
    % Returns maps for length and label of lines.
    
    % Simulate that of bw_lines_cumsum_padded = padarray(bw_lines_cumsum, [0 1], 0, 'pre'):
    bw_lines_cumsum = cumsum(bw_lines, 2);
    bw_lines_cumsum_padded = zeros(size(bw_lines_cumsum, 1), size(bw_lines_cumsum, 2)+1);
    bw_lines_cumsum_padded(:,2:end) = bw_lines_cumsum;
    
    % Simulate that of bw_lines_padded = padarray(bw_lines, [0 1], 0, 'both'):
    bw_lines_padded = zeros(size(bw_lines, 1), size(bw_lines, 2)+2);
    bw_lines_padded(:,2:end-1) = bw_lines;
    
    % Preparation
    line_cumsum = bw_lines_cumsum_padded'; % Cumsum when on line
    line_ends = diff(bw_lines_padded, [], 2)'; % Locate lines
    is_line_right_end = line_ends < 0; % -1 for right end
    is_line_left_end = line_ends > 0; % +1 for left end
    
    % Line lengths
    line_with_cumsum_reset = zeros(size(line_cumsum)); % Add line length to left side and its negative to outside right side
    line_with_cumsum_reset(is_line_right_end) = line_cumsum(is_line_right_end)-line_cumsum(is_line_left_end);
    line_with_cumsum_reset(is_line_left_end) = line_cumsum(is_line_left_end)-line_cumsum(is_line_right_end);
%     line_length = cumsum(line_with_cumsum_reset, 1, 'reverse')'; % Cumsum with 'reverse' does not work in 2012b! % Transpose 
    line_length = flipud(cumsum(flipud(line_with_cumsum_reset), 1))'; % Operate cumsum like 'reverse' % Transpose
    
    % Restore the original shape
    line_length = line_length(:,2:end);
    
    if nargout > 1,
        % Line labels
        label_with_cumsum_reset = zeros(size(line_cumsum));
        label_number = reshape(cumsum(is_line_right_end(:)), size(line_cumsum));
        label_number(~is_line_right_end) = 0;
        label_with_cumsum_reset(is_line_right_end) = label_number(is_line_right_end);
        label_with_cumsum_reset(is_line_left_end) = -label_number(is_line_right_end);
%         line_label = cumsum(label_with_cumsum_reset, 1, 'reverse')'; % Cumsum with 'reverse' does not work in 2012b! % Transpose 
        line_label = flipud(cumsum(flipud(label_with_cumsum_reset), 1))'; % Operate cumsum like 'reverse' % Transpose

        % Restore the original shape
        line_label = line_label(:,2:end);
    end
end
