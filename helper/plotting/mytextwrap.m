% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function can be used to wrap the contents of a text object according
% to the specified target width (in the text object Units). This works for
% Tex enriched text unlike MATLAB's built-in textwrap. If the target width
% is not specified, then the first line width will be used as the target
% width. The wrapping is ONLY done from the space ' ' characters and in the
% current version the splitting spaces are KEPT at the end of the line to
% keep the algorithm simple.

% Used by wit_io_msgbox.m
function mytextwrap(h_text, target_width),
    % Test if h_text is a single text object or error
    type = get(h_text, 'Type'); % Errors if 'Type' does not exist
    if numel(h_text) ~= 1 || ~strcmpi(type, 'text'),
        error('FAIL: Only accepting a scalar text object!'); % Do nothing if not a text object
    end
    % Get the text object lines
    lines = get(h_text, 'String');
    if numel(lines) == 0, return; end % Do nothing if no text lines
    % Hide the text object and initialize
    final_lines = {};
    Visible = get(h_text, 'Visible'); % Get user preference
    set(h_text, 'Visible', 'off');
    % Test if target_width was given
    ind_begin = 1; % If given, then start next loop from the first line
    if nargin < 2, % If not given, then set target_width to the first line width
        set(h_text, 'String', lines{1}); % Prepare the first line
        extent = get(h_text, 'Extent'); % Calculate the first line width
        target_width = extent(3); % Set to the first line width
        final_lines{end+1} = lines{1}; % Accept the first line as it is
        ind_begin = 2; % Skip the first line in the next loop
    end
    % Loop through the lines
    for ii = ind_begin:numel(lines),
        line = lines{ii};
        jj = 1;
        while true,
            subline = line;
            % Test if subline's text is empty
            if isempty(subline),
                final_lines{end+1} = subline; % If text is empty, then accept the line as it is
                break;
            end
            % Try if subline's text width is ok already
            if jj == 1, % Calculate if first time
                set(h_text, 'String', subline);
                extent_normalized = get(h_text, 'Extent') ./ target_width; % Secondary performance bottleneck
            end
            if (jj == 1 && extent_normalized(3) <= 1) || ...
                    (jj > 1 && ratios_end(end) <= 1),
                final_lines{end+1} = subline; % If text width is ok, then accept the line as it is
                break;
            end
            % Otherwise attempt to wrap the current line from its spaces
            if jj == 1, % Initialize only first time
                inds_end = [find(line(1:end-1) == ' ') numel(line)]; % Do not ignore subsequent spaces
                ratios_end = nan(size(inds_end));
                ratios_end(end) = extent_normalized(3); % Store the first calculation
            end
            if numel(inds_end) == 1,
                final_lines{end+1} = subline; % If no splitting characters were found, then accept the line as it is
                break;
            end
            % Find the optimal splitting by bisection method
            B_nan = isnan(ratios_end);
            B_too_wide = ratios_end > 1;
            subind_lower = find(~B_too_wide & ~B_nan, 1, 'last'); % May still be too narrow
            if isempty(subind_lower), subind_lower = 1; end
            subind_upper = find(B_too_wide & ~B_nan, 1, 'first'); % Definitely too wide
            while subind_upper-subind_lower > 1,
                pause(0.5);
                subind = floor((subind_upper+subind_lower)./2); % Check midway
                if isnan(ratios_end(subind)), % Check if already calculated
                    set(h_text, 'String', subline(1:inds_end(subind))); % Keep the splitting character
                    extent_normalized = get(h_text, 'Extent') ./ target_width; % Primary performance bottleneck
                    ratios_end(subind) = extent_normalized(3); % Store calculation
                end
                if ratios_end(subind) > 1, subind_upper = subind; % Definitely too wide
                else, subind_lower = subind; end % May still be too narrow
            end
            % Use the optimal splitting
            ind_lower = inds_end(subind_lower);
            final_lines{end+1} = subline(1:ind_lower); % Keep the splitting character
            line = line(ind_lower+1:end);
            inds_end = inds_end(subind_lower+1:end)-ind_lower; % Update indices
            ratios_end = ratios_end(subind_lower+1:end)-ratios_end(subind_lower); % Update calculations
            jj = jj + 1;
        end
    end
    % Finalize the text object and show (if preferred by user)
    set(h_text, 'String', final_lines);
    set(h_text, 'Visible', Visible);
end
