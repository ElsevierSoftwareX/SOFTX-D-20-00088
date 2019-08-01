% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [hcomponent, hcontainer, h_edit, h_label] = ui_sidebar_for_index_slider(Fig, Maximum, fun),
    if isempty(Fig), Fig = gcf; end % By default, update gcf
    Parent = findobj(Fig, 'Type', 'uipanel', '-and', 'Tag', 'sidebar'); % Find sidebar uipanel
    if isempty(Parent), [~, Parent] = ui_sidebar(Fig); end % Create one if it does not exist
    
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
    
    % Slider of uicontrol is too limited for real-time read-out. Use Java.
    [hcomponent, hcontainer] = javacomponent(javax.swing.JSlider(1, Maximum, 1), [], Parent);
    set(hcontainer, 'Units', 'pixels', 'Position', Position_slider);
    set(handle(hcomponent), 'StateChangedCallback', @update_slider); % Using handle to reduce memory leaks % http://undocumentedmatlab.com/blog/matlab-java-memory-leaks-performance
    
    set(gcf, 'DeleteFcn', 'delete(setdiff(findobj(gcbo), gcbo)); delete(gcbo);'); % Deletes all (including Java) and the figure % http://undocumentedmatlab.com/blog/couple-of-bugs-and-workarounds
    
    fun(1);
    
    function update_edit(varargin),
        currentValue = sscanf(get(h_edit, 'String'), '%d'); % Read integers
        if isempty(currentValue), % Reset value on sscanf failure
            set(h_edit, 'String', sprintf('%g', get(handle(hcomponent), 'Value')));
            return; % Exit
        end
        if currentValue < 1 || currentValue > Maximum, currentValue = max(1, min(Maximum, currentValue)); end % Limit the integer
        set(h_edit, 'String', sprintf('%g', currentValue)); % Update the edit string
        set(handle(hcomponent), 'Value', currentValue); % Call update_slider if the slider state is changed
    end
    
    function update_slider(varargin),
        currentValue = get(handle(hcomponent), 'Value');
        set(h_edit, 'String', sprintf('%g', currentValue)); % Update the edit string
        fun(currentValue);
    end
end
