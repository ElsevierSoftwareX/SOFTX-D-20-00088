% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [h_popup, h_label] = ui_sidebar_for_popup(Fig, str_Label, str_Popup, fun, initialValue, isPersistent, isMargins)
    % Updated 8.1.2019 by Joonas T. Holmi
    if nargin < 6, isPersistent = true; end
    if nargin < 5, initialValue = 1; end
    if isPersistent,
        persistent currentValue; % Remember this always
        if ~isempty(currentValue), initialValue = currentValue; end
    end
    currentValue = initialValue;
    
    if isempty(Fig), Fig = gcf; end % By default, update gcf
    if nargin < 7, isMargins = [1 1 1 1]; end % By default, add [left bottom right top] margins
    Parent = findobj(Fig, 'Type', 'uipanel', '-and', 'Tag', 'sidebar'); % Find sidebar uipanel
    if isempty(Parent), [~, Parent] = ui_sidebar(Fig); end % Create one if it does not exist
    Ax = get(Fig, 'CurrentAxes');
    
    % Calculate positions
    Units = get(Parent, 'Units'); % Store Units
    set(Parent, 'Units', 'pixels'); % Proceed in pixels
    Position = get(Parent, 'Position'); % Get Position in pixels
    Margin = get(Parent, 'UserData'); % Get margin in pixels
    BorderWidth = get(Parent, 'BorderWidth'); % Get BorderWidth in pixels
    
    View = [Margin.*isMargins(1) Position(4)+Margin.*isMargins(2) Position(3)-2.*(BorderWidth-1)-sum(isMargins(1:2:3)).*Margin 0]; % Margins included [left bottom width height]
    Height = [15 25];
    if isempty(str_Label), Height(1) = 0; end % Disable Label
%     cHeight = [cumsum(Height(2:end), 'reverse') 0];
    cHeight = [fliplr(cumsum(fliplr(Height(2:end)), 2)) 0]; % Added for backward compability
    Position_label = [View(1) View(2)+cHeight(1) View(3) Height(1)];
    Position_popup = [View(1) View(2)+cHeight(2) View(3) Height(2)];

    Position = [Position(1) Position(2)-sum(Height)-2.*(BorderWidth-1)-sum(isMargins(2:2:4)).*Margin Position(3) Position(4)+sum(Height)+2.*(BorderWidth-1)+sum(isMargins(2:2:4)).*Margin]; % Margins included [left bottom width height]
    set(Parent, 'Position', Position); % Set Position in pixels
    set(Parent, 'Units', Units); % Restore Units
    
    if ~isempty(str_Label),
        h_label = uicontrol('Parent', Parent, ...
            'Style', 'text', ...
            'String', str_Label, ...
            'Units', 'pixels', ...
            'Position', Position_label);
    end
    
    h_popup = uicontrol('Parent', Parent, ...
        'Style', 'popup', ...
        'String', str_Popup, ...
        'Value', currentValue, ...
        'Units', 'pixels', ...
        'Position', Position_popup, ...
        'Callback', @update);
    
    fun(currentValue);
    
    function [] = update(varargin),
        currentValue = get(h_popup, 'Value');
        fun(currentValue);
    end
end
