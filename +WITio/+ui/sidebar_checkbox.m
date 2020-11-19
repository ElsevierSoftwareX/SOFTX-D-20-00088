% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [fun_status, h_checkbox] = sidebar_checkbox(Fig, String, Value),
    if isempty(Fig), Fig = gcf; end % By default, update gcf
    
    Parent = findobj(Fig, 'Type', 'uipanel', '-and', 'Tag', 'sidebar'); % Find sidebar uipanel
    if isempty(Parent), [~, Parent] = WITio.ui.sidebar(Fig); end % Create one if it does not exist
    
    % Calculate positions
    Units = get(Parent, 'Units'); % Store Units
    set(Parent, 'Units', 'pixels'); % Proceed in pixels
    Position = get(Parent, 'Position'); % Get Position in pixels
    Margin = get(Parent, 'UserData'); % Get margin in pixels
    BorderWidth = get(Parent, 'BorderWidth'); % Get BorderWidth in pixels
    
    View = [Margin Position(4)+Margin Position(3)-2.*(Margin+BorderWidth-1) 0]; % Margins included [left bottom width height]
    Height = [20];
%     cHeight = [cumsum(Height(2:end), 'reverse') 0];
    cHeight = [fliplr(cumsum(fliplr(Height(2:end)), 2)) 0]; % Added for backward compability
    Position_checkbox = [View(1) View(2)+cHeight(1) View(3) Height(1)];
    
    Position = [Position(1) Position(2)-sum(Height)-2.*(Margin+BorderWidth-1) Position(3) Position(4)+sum(Height)+2.*(Margin+BorderWidth-1)]; % Margins included [left bottom width height]
    set(Parent, 'Position', Position); % Set Position in pixels
    set(Parent, 'Units', Units); % Restore Units
    
    h_checkbox = uicontrol('Parent', Parent, 'Style', 'checkbox', 'String', String, 'Value', Value, 'Units', 'pixels', 'Position', Position_checkbox);
    fun_status = @status;
    
    function Value = status(varargin),
        if ~ishandle(h_checkbox), Value = [];
        else, Value = get(h_checkbox, 'Value'); end
    end
end
