% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function can be used to wrap the contents of a text object according
% to the given maximum width (in the text object Units). This also works
% for TeX or LaTeX enriched text unlike MATLAB's built-in textwrap. If the
% maximum width is not given, then it is set to the first line width. Also,
% the maximum width is updated if the maximum word width exceeds it. The
% word wrapping is ONLY done from the space ' ' characters and in the
% current version the splitting spaces are KEPT at the end of the line to
% keep the algorithm simple.

% Used by WITio.core.msgbox.m
function mytextwrap(h_text, max_width),
    % Test if h_text is a single text object or error
    type = get(h_text, 'Type'); % Errors if 'Type' does not exist
    if numel(h_text) ~= 1 || ~strcmpi(type, 'text'),
        error('FAIL: Only accepting a scalar text object!'); % Error if not a text object
    end
    
    % Get the text object lines
    lines = get(h_text, 'String');
    if ~iscell(lines), lines = {lines}; end % Force a cell array
    if numel(lines) == 0, return; end % Do nothing if no text lines
    
    % Hide the text object
    Visible = get(h_text, 'Visible'); % Get user preference
    set(h_text, 'Visible', 'off');
    
    % In order to handle possible LaTeX Markup or TeX Markup enhancements, 
    % the lines are split into multiple lines from their space characters.
    % For simplicity, the space characters are kept in the end of the words
    % if present.
    split_indices = [];
    split_lines = {};
    for ii = 1:numel(lines),
        line = lines{ii};
        % Do not split the first line if no maximum width was given
        if ii == 1 && nargin == 1,
            split_lines{end+1} = line;
            split_indices(end+1) = ii;
        else, % Otherwise always split the line
            inds_end = [find(line(1:end-1) == ' ') numel(line)];
            ind_begin = 1;
            for jj = 1:numel(inds_end),
                split_lines{end+1} = line(ind_begin:inds_end(jj));
                split_indices(end+1) = ii;
                ind_begin = inds_end(jj)+1;
            end
        end
    end
    
    % Calculate the maximum word length
    set(h_text, 'String', split_lines);
    extent = get(h_text, 'Extent');
    max_word_width = extent(3);
    
    % Update the maximum width if it was not given or smaller
    if nargin == 1 || max_word_width > max_width,
        max_width = max_word_width;
    end
    
    % Minimum number of words that can be merged together without exceeding
    % the maximum width limit
    N_min_words = floor(max_width ./ max_word_width);
    
    % Restore the original lines (honoring the maximum width limit)
    final_lines = {};
    ii = 1; % Current line index
    N_lines = numel(lines); % Number of lines (to be updated)
    % Loop through the line
    while ii <= N_lines,
        B_split_ii = split_indices == ii;
        ind_begin = find(B_split_ii, 1, 'first');
        ind_end = find(B_split_ii, 1, 'last');
        % Find the optimal line splitting by bisection method
        ind_end_upper = ind_end; % May be too wide
        ind_end_lower = min(ind_begin + N_min_words - 1, ind_end); % May be too narrow
        ind_end_test = ind_end_upper; % Test the maximum first
        while true,
            % Calculate the line width
            set(h_text, 'String', [final_lines {[split_lines{ind_begin:ind_end_test}]} split_lines(ind_end_test+1:end)]);
            extent = get(h_text, 'Extent'); % This calculation is the primary performance bottleneck
            % Update the upper or the lower end limit
            if extent(3) > max_width, ind_end_upper = ind_end_test; % Definitely too wide
            else, ind_end_lower = ind_end_test; end % May still be too narrow
            % Stop the loop if the optimal solution was found
            if ind_end_upper - ind_end_lower <= 1, break; end
            % Go to midway of the lower and upper end limits
            ind_end_test = floor((ind_end_upper+ind_end_lower)./2);
        end
        % Use the optimal line splitting
        final_lines{ii} = [split_lines{ind_begin:ind_end_lower}];
        ii = ii+1;
        % Update the number of lines if the current line still remains
        if ind_end_lower ~= ind_end,
            N_lines = N_lines+1;
            split_indices(ind_end_lower+1:end) = split_indices(ind_end_lower+1:end)+1;
        end
    end
    
    % Finalize the text object and show (if preferred by user)
    set(h_text, 'String', final_lines);
    set(h_text, 'Visible', Visible);
end
