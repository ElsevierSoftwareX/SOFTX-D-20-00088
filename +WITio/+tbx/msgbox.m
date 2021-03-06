% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% A simple wrapper for MATLAB's built-in msgbox functionality with fixed
% text wrapping. By default, opens a WITio's Dialog -window, which has
% WITio's main icon and TeX Interpreter enabled to more enriched text. See
% the msgbox documentation [1] for the possible TeX Markups.
% [1] https://www.mathworks.com/help/matlab/ref/msgbox.html
%
% OPTIONAL EXTRA ARGUMENTS (case-insensitive):
% '-Title': Provide a char array to manually set the dialog window title.
% If not given, then the dialog window is titled as 'WITio''s Dialog' when
% icon is set to 'none' or 'custom' and i.e. 'WITio''s Help Dialog' when
% icon is set 'help'.
% '-Icon': Can be used to provide one to three inputs to the underlying
% msgbox: icon, icondata, iconcmap (in this order). Read the msgbox
% documentation [1] for their specific definitions.
% '-WindowStyle': Can be either 'modal' (default) or 'normal'. 
% '-Interpreter': Can be either 'none', 'tex' (default) or 'latex'. This is
% used to enable/disable TeX or LaTex Markups in the dialog text.
% '-TextWrapping': Takes in one to two inputs. The first input can be
% either a logical value (to toggle the automatic text wrapping) or a
% numeric value (to manually set the maximum text width). The optional
% second input determines the units of the given maximum text width. By
% default, the automatic text wrapping is enabled. DUE TO SLOW PERFORMANCE
% of the automatic text wrapping in the older MATLAB versions like R2011a,
% a second output 'rewrapped_message' was introduced to enable
% precalculation the text wrapping only once.

% EXAMPLE:
% h = WITio.tbx.msgbox('\bullet This is an{\bf example \color{magenta}dialog} box with max. {\fontname{Courier}200 px} wide text wrapping.', '-Icon', 'help', '-TextWrapping', 200, 'pixels');
function [h, rewrapped_message] = msgbox(message, varargin),
    % Load the default WITio icon only once
    persistent default_icondata default_iconcmap;
    if isempty(default_icondata) || isempty(default_iconcmap),
        [default_icondata, default_iconcmap] = imread(fullfile(WITio.tbx.path, 'WITio.png'));
    end
    
    % Check if Icon was specified
    datas = WITio.fun.varargin_dashed_str.datas('Icon', varargin, -3);
    icon = {'custom', default_icondata, default_iconcmap}; % Default
    if numel(datas) > 0, icon(1:numel(datas)) = datas; end
    
    % Check if WindowStyle was specified
    datas = WITio.fun.varargin_dashed_str.datas('WindowStyle', varargin, -1);
    WindowStyle = 'modal'; % Default
    if numel(datas) > 0, WindowStyle = datas{1}; end
    
    % Check if Interpreter was specified
    datas = WITio.fun.varargin_dashed_str.datas('Interpreter', varargin, -1);
    Interpreter = 'tex'; % Default
    if numel(datas) > 0, Interpreter = datas{1}; end
    
    % Check if Title was specified
    datas = WITio.fun.varargin_dashed_str.datas('Title', varargin, -1);
    title = 'WITio''s Dialog'; % Default
    if ~strcmp(icon{1}, 'none') && ~strcmp(icon{1}, 'custom'),
        title = sprintf('WITio''s %s Dialog', [upper(icon{1}(1)) icon{1}(2:end)]);
    end
    if numel(datas) > 0, title = datas{1}; end
    
    % Check if TextWrapping was specified
    datas = WITio.fun.varargin_dashed_str.datas('TextWrapping', varargin, -2);
    TextWrapping = {true}; % Default
    if numel(datas) > 0, TextWrapping = datas; end
    
    % Get maximum height needed to get out of screen in pixels
    Units = get(0, 'Units');
    set(0, 'Units', 'pixels');
    MonitorPositions = get(0, 'MonitorPositions');
    set(0, 'Units', Units);
    HeightOffset = sum(MonitorPositions(:,4)); % Quaranteed to get out of screen(s)
    
    % Determine whether or not to show dialog
    isDesktop = usejava('desktop'); % The dialog is possible only if MATLAB is running in Desktop-mode
    if ~isDesktop,
        h = [];
        return;
    end
    
    % Create the customized dialog for msgbox
    h = dialog('Name', title, 'Pointer', 'arrow', 'Units', 'points', ...
        'Visible', 'off', 'KeyPressFcn', @KeyPressFcn, ...
        'Toolbar', 'none', 'HandleVisibility', 'on', ...
        'Tag', ['Msgbox_' title]);
    
    % Modify dialog using MATLAB's built-in msgbox
    msgbox(message, title, icon{:}, struct('WindowStyle', 'replace', 'Interpreter', Interpreter)); % Always sets 'WindowStyle' to 'normal' according to the documentation and the code.
    set(h, 'Visible', 'on'); % To circumvent the AbortSet property
    set(h, 'Visible', 'off');
    set(h, 'WindowStyle', WindowStyle); % Enforce the user preferred window modality
    
    % Remove the forced 75 characer text wrapping (enforced by msgbox). By
    % default, redo it manually. This is necessary to show i.e. Tex-
    % enriched text correctly! The text object and its surroundings are
    % resized if necessary. (Units of each object are set same in msgbox.)
    % Get relevant objects
    h_MessageBox = findall(h, 'Tag', 'MessageBox');
    h_IconAxes = findall(h, 'Tag', 'IconAxes');
    h_OKButton = findall(h, 'Tag', 'OKButton');
    % Store old positions
    Position_dialog = get(h, 'Position');
    Position_text = get(h_MessageBox, 'Position');
    Position_icon = get(h_IconAxes, 'Position');
    Position_ok = get(h_OKButton, 'Position');
    % Calculate the key lengths
    min_y = min(Position_icon(2), Position_text(2)); % Like in msgbox
    margins = [Position_icon(1) Position_ok(2)]; % Like in msgbox
    text_width = Position_dialog(3) - Position_text(1) - margins(1) - get(h_MessageBox, 'Margin')./2; % Recalculate a more reliable width than that of the direct get(h_MessageBox, 'Extent'); due to the possible use of Interpreter
    % Replace text wrapped with unwrapped (or rewrapped) text
    set(h_MessageBox, 'String', message); % Restore the original line breaks
    if ~islogical(TextWrapping{1}) || TextWrapping{1} == true, % Rewrapping
        max_width = text_width; % Auto width
        if ~islogical(TextWrapping{1}), max_width = TextWrapping{1}; end % Manual width
        if numel(TextWrapping) > 1 && ~islogical(TextWrapping{1}), % Manual units
            Units = get(h_MessageBox, 'Units');
            set(h_MessageBox, 'Units', TextWrapping{2});
        end
        WITio.fun.visual.mytextwrap(h_MessageBox, max_width); % Rewrap the text
        if numel(TextWrapping) > 1 && ~islogical(TextWrapping{1}),
            set(h_MessageBox, 'Units', Units);
        end
    end
    rewrapped_message = get(h_MessageBox, 'String'); % Get the text object lines
    if ~iscell(rewrapped_message), rewrapped_message = {rewrapped_message}; end % Force a cell array
    Extent_text = get(h_MessageBox, 'Extent'); % Calculate the extent
    % Center the icon position OR the text position like in msgbox
    Width_dialog = Position_text(1) + Extent_text(3) + margins(1);
    delta = (Extent_text(4) - Position_icon(4))./2;
    if delta < 0, % Center the vertically smaller text
        Position_icon(2) = min_y;
        Position_text(2) = min_y - delta;
        Height_dialog = Position_icon(2) + Position_icon(4) + margins(2);
    else, % Center the vertically smaller icon
        Position_icon(2) = min_y + delta;
        Position_text(2) = min_y;
        Height_dialog = Position_text(2) + Extent_text(4) + margins(2);
    end
    % Shift the dialog box position so that its center does not move
    Position_dialog(1:2) = Position_dialog(1:2) + (Position_dialog(3:4) - [Width_dialog Height_dialog])./2;
    Position_dialog(3:4) = [Width_dialog Height_dialog];
    % Center the OK button horizontally
    Position_ok(1) = Position_dialog(3)./2 - Position_ok(3)./2;
    % Update positions
    set(h, 'Position', Position_dialog);
    set(h_MessageBox, 'Position', Position_text);
    set(h_IconAxes, 'Position', Position_icon);
    set(h_OKButton, 'Position', Position_ok);
    % Make figure visible
    set(h, 'Visible', 'on');
    drawnow;
    
    AutoCloseInSeconds = WITio.tbx.pref.get('AutoCloseInSeconds', Inf);
    if ~isinf(AutoCloseInSeconds) && AutoCloseInSeconds >= 0,
        start(timer('ExecutionMode', 'singleShot', 'StartDelay', AutoCloseInSeconds, 'TimerFcn', @(~,~) delete(h), 'StopFcn', @(s,~) delete(s)));
    end
    
    function KeyPressFcn(src, event), % Same buttons as in msgbox
        if any(strcmp({'return', 'space', 'escape'}, event.Key)), delete(h); end
    end
end
