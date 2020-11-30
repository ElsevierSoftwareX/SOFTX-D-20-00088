% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [h_slider, h_edit, h_label] = sidebar_index_slider(Fig, Maximum, fun),
    if isempty(Fig), Fig = gcf; end % By default, update gcf
    Parent = findobj(Fig, 'Type', 'uipanel', '-and', 'Tag', 'sidebar'); % Find sidebar uipanel
    if isempty(Parent), [~, Parent] = WITio.tbx.ui.sidebar(Fig); end % Create one if it does not exist
    
    % Calculate positions
    Units = get(Parent, 'Units'); % Store Units
    set(Parent, 'Units', 'pixels'); % Proceed in pixels
    Position = get(Parent, 'Position'); % Get Position in pixels
    Margin = get(Parent, 'UserData'); % Get margin in pixels
    BorderWidth = get(Parent, 'BorderWidth'); % Get BorderWidth in pixels
    
    View = [Margin Position(4)+Margin Position(3)-2.*(Margin+BorderWidth-1) 0]; % Margins included [left bottom width height]
    Height = [15 25];
%     cHeight = [cumsum(Height(2:end), 'reverse') 0];
    cHeight = [fliplr(cumsum(fliplr(Height(2:end)), 2)) 0]; % Added for backward compability
    Position_label = [View(1) View(2)+cHeight(1) View(3)/2 Height(1)];
    Position_edit = [View(1)+View(3)/2 View(2)+cHeight(1) View(3)/2 Height(1)];
    Position_slider = [View(1) View(2)+cHeight(2) View(3) Height(2)];
    
    Position = [Position(1) Position(2)-sum(Height)-2.*(Margin+BorderWidth-1) Position(3) Position(4)+sum(Height)+2.*(Margin+BorderWidth-1)]; % Margins included [left bottom width height]
    set(Parent, 'Position', Position); % Set Position in pixels
    set(Parent, 'Units', Units); % Restore Units
    
    h_label = uicontrol('Parent', Parent, 'Style', 'text', 'String', 'Index:', 'Units', 'pixels', 'Position', Position_label);
    h_edit = uicontrol('Parent', Parent, 'Style', 'edit', 'String', 1, 'Units', 'pixels', 'Position', Position_edit, 'Callback', @update_edit);
    
    % Due to the upcoming removal of JAVACOMPONENT after R2019b (and
    % the related warning messages), JSlider is no longer used. Decided to
    % revert back to uicontrol's slider, what appears to be supported
    % beyond the removal of JAVACOMPONENT.
    h_slider = uicontrol('Parent', Parent, 'Style', 'slider', 'Min', 1, 'Max', Maximum, 'Value', 1, 'SliderStep', [1/(Maximum-1) 5/(Maximum-1)], 'Units', 'pixels', 'Position', Position_slider);
    addlistener(h_slider, 'Value', 'PostSet', @update_slider); % Allow real-time updates
    
    fun(1);
    
    function update_edit(varargin),
        currentValue = sscanf(get(h_edit, 'String'), '%d'); % Read integers
        if isempty(currentValue), % Reset value on sscanf failure
            set(h_edit, 'String', sprintf('%g', round(get(h_slider, 'Value'))));
            return; % Exit
        end
        if currentValue < 1 || currentValue > Maximum, currentValue = max(1, min(Maximum, currentValue)); end % Limit the integer
        set(h_edit, 'String', sprintf('%g', currentValue)); % Update the edit string
        set(h_slider, 'Value', currentValue); % Call update_slider if the slider state is changed
    end
    
    function update_slider(varargin),
        currentValue = round(get(h_slider, 'Value'));
        set(h_edit, 'String', sprintf('%g', currentValue)); % Update the edit string
        fun(currentValue);
    end
end
