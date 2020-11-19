% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [h_label, h_label_1, h_edit_1, h_label_2, h_edit_2, h_label_3, h_edit_3, h_label_4, h_edit_4] = sidebar_cursor(Fig, fun_down, fun_up, fun_image_transform),
    if nargin < 1 || isempty(Fig), Fig = gcf; end % By default, update gcf
    if nargin < 2, fun_down = []; end % By default, no function to call on down
    if nargin < 3, fun_up = []; end % By default, no function to call on up
    if nargin < 4, fun_image_transform = []; end % By default, no image transformation
    
    Parent = findobj(Fig, 'Type', 'uipanel', '-and', 'Tag', 'sidebar'); % Find sidebar uipanel
    if isempty(Parent), [~, Parent] = WITio.ui.sidebar(Fig); end % Create one if it does not exist
    Ax = get(Fig, 'CurrentAxes');
    
    % Calculate positions
    Units = get(Parent, 'Units'); % Store Units
    set(Parent, 'Units', 'pixels'); % Proceed in pixels
    Position = get(Parent, 'Position'); % Get Position in pixels
    Margin = get(Parent, 'UserData'); % Get margin in pixels
    BorderWidth = get(Parent, 'BorderWidth'); % Get BorderWidth in pixels
    
    View = [Margin Position(4)+Margin Position(3)-2.*(Margin+BorderWidth-1) 0]; % Margins included [left bottom width height]
    Height = [15 15 15 15 15];
%     cHeight = [cumsum(Height(2:end), 'reverse') 0];
    cHeight = [fliplr(cumsum(fliplr(Height(2:end)), 2)) 0]; % Added for backward compability
    Position_label = [View(1) View(2)+cHeight(1) View(3) Height(1)];
    Position_label_1 = [View(1) View(2)+cHeight(2) View(3)/3 Height(2)];
    Position_edit_1 = [View(1)+View(3)/3 View(2)+cHeight(2) 2*View(3)/3 Height(2)];
    Position_label_2 = [View(1) View(2)+cHeight(3) View(3)/3 Height(3)];
    Position_edit_2 = [View(1)+View(3)/3 View(2)+cHeight(3) 2*View(3)/3 Height(3)];
    Position_label_3 = [View(1) View(2)+cHeight(4) View(3)/3 Height(4)];
    Position_edit_3 = [View(1)+View(3)/3 View(2)+cHeight(4) 2*View(3)/3 Height(4)];
    Position_label_4 = [View(1) View(2)+cHeight(5) View(3)/3 Height(5)];
    Position_edit_4 = [View(1)+View(3)/3 View(2)+cHeight(5) 2*View(3)/3 Height(5)];
    
    Position = [Position(1) Position(2)-sum(Height)-2.*(Margin+BorderWidth-1) Position(3) Position(4)+sum(Height)+2.*(Margin+BorderWidth-1)]; % Margins included [left bottom width height]
    set(Parent, 'Position', Position); % Set Position in pixels
    set(Parent, 'Units', Units); % Restore Units
    
    h_label = uicontrol('Parent', Parent, 'Style', 'text', 'String', 'Cursor:', 'Units', 'pixels', 'Position', Position_label);
    h_label_1 = uicontrol('Parent', Parent, 'Style', 'text', 'String', 'X:', 'Units', 'pixels', 'Position', Position_label_1);
    h_edit_1 = uicontrol('Parent', Parent, 'Style', 'edit', 'String', '', 'Units', 'pixels', 'Position', Position_edit_1, 'Enable', 'inactive');
    h_label_2 = uicontrol('Parent', Parent, 'Style', 'text', 'String', 'Y:', 'Units', 'pixels', 'Position', Position_label_2);
    h_edit_2 = uicontrol('Parent', Parent, 'Style', 'edit', 'String', '', 'Units', 'pixels', 'Position', Position_edit_2, 'Enable', 'inactive');
    h_label_3 = uicontrol('Parent', Parent, 'Style', 'text', 'String', 'Z:', 'Units', 'pixels', 'Position', Position_label_3, 'Visible', 'off'); % Invisible by default
    h_edit_3 = uicontrol('Parent', Parent, 'Style', 'edit', 'String', '', 'Units', 'pixels', 'Position', Position_edit_3, 'Enable', 'inactive', 'Visible', 'off'); % Invisible by default
    h_label_4 = uicontrol('Parent', Parent, 'Style', 'text', 'String', 'Data:', 'Units', 'pixels', 'Position', Position_label_4, 'Visible', 'off'); % Invisible by default
    h_edit_4 = uicontrol('Parent', Parent, 'Style', 'edit', 'String', '', 'Units', 'pixels', 'Position', Position_edit_4, 'Enable', 'inactive', 'Visible', 'off'); % Invisible by default
    
    isWindowKeyReleased = true;
    
    set(Fig, 'WindowButtonDownFcn', @WindowButtonDownFcn, 'WindowButtonUpFcn', @WindowButtonUpFcn, ... % Enable mouse tracking when pressed down!
        'WindowKeyReleaseFcn', @WindowKeyReleaseFcn, 'WindowKeyPressFcn', @WindowKeyPressFcn);
    
    function refresh(fun, dCP),
        if ~ishandle(Parent), return; end % Abort if Parent does not exist! (For instance, due to deletion)
        if ~isempty(Ax),
            if nargin == 1, % Get mouse point if no difference, dCP given
                CP = get(Ax, 'CurrentPoint');
                CP = CP(1,:);
            else, % Get key point from given difference, dCP
                % Find the circle
                CircleObject = findobj(Ax, 'Tag', 'circle_by_ui_sidebar_cursor');
                if ~isempty(CircleObject),
                    CP = get(CircleObject, 'Position'); % Get previous position
                    CP = [CP(1)+1 CP(2)+1 1] + dCP(:).'; % Shift from previous circle center
                else, CP = [1 1 1]; end % Initial circle center
            end
            
            % Test point (Exit on failure)
            XLim = get(Ax, 'XLim');
            YLim = get(Ax, 'YLim');
            if CP(1) < XLim(1) || CP(1) > XLim(2) || CP(2) < YLim(1) || CP(2) > YLim(2), return; end % Required to avoid out-of-bounds errors!
            
            X = CP(1);
            Y = CP(2);
            Z = CP(3);
            CP = CP(1:2);
            
            % Set value
            ImageObject = findobj(Ax, 'Type', 'image');
            if ~isempty(ImageObject),
                CData = get(ImageObject, 'CData');
                round_X = round(X);
                round_Y = round(Y);
                if round_X < 1 || round_X > size(CData, 2) || round_Y < 1 || round_Y > size(CData, 1), return; end % Required to avoid out-of-bounds errors!
                if size(CData, 3) == 1, % Grayscale image
                    if round_Y < 1 || round_Y > size(CData, 1) || round_X < 1 || round_X > size(CData, 2), set(h_edit_4, 'String', sprintf('%.5g', NaN)); % RARE CASE: When the figure texts somehow causes illegal round-down/up outside the CData!
                    else, set(h_edit_4, 'String', sprintf('%.5g', CData(round_Y, round_X))); end % Set Data end
                elseif size(CData, 3) == 3, % RGB image
                    if round_Y < 1 || round_Y > size(CData, 1) || round_X < 1 || round_X > size(CData, 2), set(h_edit_4, 'String', sprintf('%.5g %.5g %.5g', nan(1,1,3))); % RARE CASE: When the figure texts somehow causes illegal round-down/up outside the CData!
                    else, set(h_edit_4, 'String', sprintf('%.5g %.5g %.5g', CData(round_Y, round_X, :))); end % Set RGB Data
                end
                if ~isempty(fun_image_transform), % Use space-transformation function if specified
                    CP_in_Space = fun_image_transform(CP);
                    X = CP_in_Space(1);
                    Y = CP_in_Space(2);
                    Z = CP_in_Space(3);
%                     if X < XLim(1) || X >= XLim(2) || Y < YLim(1) || Y >= YLim(2), return; end % Required to avoid out-of-bounds errors!
                end
                set(h_edit_3, 'String', sprintf('%.5g', Z)); % Set Z
                set([h_label_3 h_label_4 h_edit_3 h_edit_4], 'Visible', 'on');
                
                % Also, add a circle as position marker on top of the view
                CircleObject = findobj(Ax, 'Tag', 'circle_by_ui_sidebar_cursor');
                if isempty(CircleObject), % Create new if needed
                    CircleObject = rectangle('Parent', Ax, 'Position', [round_X-1 round_Y-1 2 2], 'Curvature', [1 1], 'EdgeColor', 'white', 'LineWidth', 1);
                    set(CircleObject, 'Tag', 'circle_by_ui_sidebar_cursor');
                else, set(CircleObject, 'Position', [round_X-1 round_Y-1 2 2]); end
            else, set([h_label_3 h_label_4 h_edit_3 h_edit_4], 'Visible', 'off'); end
            
            set(h_edit_2, 'String', sprintf('%.5g', Y)); % Set Y
            set(h_edit_1, 'String', sprintf('%.5g', X)); % Set X
            
            % Call function
            if ~isempty(fun) fun(CP); end
        end
    end
    
    % Mouse tracking callbacks
    function WindowButtonUpFcn(varargin),
        set(Fig, 'WindowButtonMotionFcn', ''); % Disable mouse tracking
        refresh(fun_up);
    end
    function WindowButtonDownFcn(varargin),
        set(Fig, 'WindowButtonMotionFcn', @WindowButtonMotionFcn); % Enable mouse tracking
        refresh(fun_down);
    end
    function WindowButtonMotionFcn(varargin),
        refresh(fun_down);
    end
    
    % Key tracking callbacks
    function WindowKeyReleaseFcn(varargin),
        ImageObject = findobj(Ax, 'Type', 'image');
        if ~isempty(ImageObject), % Proceed only if an image
%             isWindowKeyReleased = true;
            refresh(fun_up, [0 0 0]);
        end
    end
    function WindowKeyPressFcn(src, event),
        ImageObject = findobj(Ax, 'Type', 'image');
        if ~isempty(ImageObject), % Proceed only if an image
            if isWindowKeyReleased,
%                 isWindowKeyReleased = false;
                switch(event.Key),
                    case 'leftarrow',
                        refresh(fun_down, [-1 0 0]); % Move circle to left
                    case 'uparrow',
                        refresh(fun_down, [0 -1 0]); % Move circle to up
                    case 'rightarrow',
                        refresh(fun_down, [1 0 0]); % Move circle to right
                    case 'downarrow',
                        refresh(fun_down, [0 1 0]); % Move circle to down
                end
            end
        end
    end
end
