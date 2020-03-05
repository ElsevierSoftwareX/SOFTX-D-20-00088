% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% A simple wrapper for MATLAB's built-in msgbox functionality but without
% text wrapping. By default, opens a wit_io's Dialog -window, which has
% wit_io's main icon and TeX Interpreter enabled to more enriched text. See
% the msgbox documentation [1] for the possible TeX Markups.
% [1] https://www.mathworks.com/help/matlab/ref/msgbox.html
function h = wit_io_msgbox(message, title, icon, icondata, iconcmap, WindowStyle, Interpreter),
    % Load the default wit_io icon only once
    persistent default_icondata default_iconcmap;
    if isempty(default_icondata) || isempty(default_iconcmap),
        [default_icondata, default_iconcmap] = imread('wit_io.png');
    end
    % Parse the icon, icondata and iconcmap
    if nargin < 3 || isempty(icon), icon = 'custom'; end
    if nargin < 4 || isempty(icondata), icondata = default_icondata; end
    if nargin < 5 || isempty(icondata), iconcmap = default_iconcmap; end % By isempty(icondata) test if to use the toolbox icon
    % Parse the title
    if nargin < 2 || isempty(title),
        title = 'wit_io''s Dialog';
        if ~strcmp(icon, 'none') && ~strcmp(icon, 'custom'),
            title = sprintf('wit_io''s %s Dialog', [upper(icon(1)) icon(2:end)]);
        end
    end
    % Parse the createmode struct field values
    if nargin < 6 || isempty(WindowStyle), WindowStyle = 'modal'; end
    if nargin < 7 || isempty(Interpreter), Interpreter = 'tex'; end
    
    % Get maximum height needed to get out of screen in pixels
    Units = get(0, 'Units');
    set(0, 'Units', 'pixels');
    MonitorPositions = get(0, 'MonitorPositions');
    set(0, 'Units', Units);
    HeightOffset = sum(MonitorPositions(:,4)); % Quaranteed to get out of screen(s)
    
    % Create the customized dialog for msgbox
    h = dialog('Name', title, 'Pointer', 'arrow', ...
        'Units', 'points', 'Visible', 'off', ...
        'KeyPressFcn', @KeyPressFcn, 'WindowStyle', WindowStyle, ...
        'Toolbar', 'none', 'HandleVisibility', 'on', ...
        'Tag', ['Msgbox_' title]);
    
    % Modify dialog using MATLAB's built-in msgbox
    h_event = addlistener(h, {'Visible', 'WindowStyle'}, 'PostSet', @force_visible_off_and_out_of_screen); % Prepare to interrupt msgbox from setting h's 'Visible' to 'on'!
    msgbox(message, title, icon, icondata, iconcmap, struct('WindowStyle', 'replace', 'Interpreter', Interpreter));
    delete(h_event); % Delete listener
    
    % Shift figure's Position back to screen vertically
    Units = get(h, 'Units');
    set(h, 'Units', 'pixels');
    Position = get(h, 'Position');
    Position(2) = Position(2)-HeightOffset;
    set(h, 'Position', Position);
    set(h, 'Units', Units);
    
    % Disable the forced 75 characer text wrapping (enforced by msgbox).
    % This is necessary to show i.e. Tex-enriched text correctly! In
    % effect, resize the text object and its surroundings. Units of each
    % object are set same in msgbox.
    % Get relevant objects
    h_MessageBox = findall(h, 'Tag', 'MessageBox');
    h_IconAxes = findall(h, 'Tag', 'IconAxes');
    h_OKButton = findall(h, 'Tag', 'OKButton');
    % Replace text wrapped with unwrapped text and find the extent delta
    Extent_before = get(h_MessageBox, 'Extent');
    set(h_MessageBox, 'String', message); % Restore the original line breaks
    Extent_after = get(h_MessageBox, 'Extent');
    delta_Extent = Extent_after - Extent_before;
    % Update figure position
    Position = get(h, 'Position');
    Position(1) = Position(1) - delta_Extent(3)./2;
    Position(2) = Position(2) - delta_Extent(4);
    Position(3) = Position(3) + delta_Extent(3);
    Position(4) = Position(4) + delta_Extent(4);
    set(h, 'Position', Position);
    % Recenter the icon position
    Position = get(h_IconAxes, 'Position');
    Position(2) = Position(2) + delta_Extent(4)./2; % Icon vertical centering
    set(h_IconAxes, 'Position', Position);
    % Recenter the OK button position
    Units = get(h_OKButton, 'Units');
    set(h_OKButton, 'Units', 'normalized');
    Position = get(h_OKButton, 'Position');
    Position(1) = 0.5 - Position(3)./2; % OK button horizontal centering
    set(h_OKButton, 'Position', Position);
    set(h_OKButton, 'Units', Units);
    % Make figure visible
    set(h, 'Visible', 'on');
    drawnow;
    
    function KeyPressFcn(src, event), % Same buttons as in msgbox
        if any(strcmp({'return', 'space', 'escape'}, event.Key)), delete(h); end
    end
    
    function force_visible_off_and_out_of_screen(varargin),
        set(h, 'Visible', 'on'); % To circumvent the AbortSet property
        set(h, 'Visible', 'off');
        % Then shift Position out of screen vertically (if not yet)
        Units = get(h, 'Units');
        set(h, 'Units', 'pixels');
        Position = get(h, 'Position');
        if Position(2) < HeightOffset,
            Position(2) = Position(2)+HeightOffset;
        end
        set(h, 'Position', Position);
        set(h, 'Units', Units);
    end
end
