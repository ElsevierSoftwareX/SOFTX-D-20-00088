% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [h_edit_1, h_edit_2, h_label] = sidebar_sum_filter(Fig, varargin),
    persistent currentRange; % Remember this always
    if isempty(currentRange), currentRange = [-inf inf]; end % By default, sum over all data
    
    if isempty(Fig), Fig = gcf; end % By default, update gcf
    Parent = findobj(Fig, 'Type', 'uipanel', '-and', 'Tag', 'sidebar'); % Find sidebar uipanel
    if isempty(Parent), [~, Parent] = WITio.misc.ui.sidebar(Fig); end % Create one if it does not exist
    
    % Calculate Positions
    Units = get(Parent, 'Units'); % Store Units
    set(Parent, 'Units', 'pixels'); % Proceed in pixels
    Position = get(Parent, 'Position'); % Get Position in pixels
    Margin = get(Parent, 'UserData'); % Get margin in pixels
    BorderWidth = get(Parent, 'BorderWidth'); % Get BorderWidth in pixels
    
    View = [Margin Position(4)+Margin Position(3)-2.*(Margin+BorderWidth-1) 0]; % Margins included [left bottom width height]
    Height = [15 25 25];
%     cHeight = [cumsum(Height(2:end), 'reverse') 0];
    cHeight = [fliplr(cumsum(fliplr(Height(2:end)), 2)) 0]; % Added for backward compability
    Position_label = [View(1) View(2)+cHeight(1) View(3) Height(1)];
    Position_edit_1 = [View(1) View(2)+cHeight(2) View(3) Height(2)];
    Position_edit_2 = [View(1) View(2)+cHeight(3) View(3) Height(3)];

    Position = [Position(1) Position(2)-sum(Height)-2.*(Margin+BorderWidth-1) Position(3) Position(4)+sum(Height)+2.*(Margin+BorderWidth-1)]; % Margins included [left bottom width height]
    set(Parent, 'Position', Position); % Set Position in pixels
    set(Parent, 'Units', Units); % Restore Units
    
    h_label = uicontrol('Parent', Parent, 'Style', 'text', 'String', 'Sum over:', 'Units', 'pixels', 'Position', Position_label);
    h_edit_1 = uicontrol('Parent', Parent, 'Style', 'edit', 'String', currentRange(1), 'Units', 'pixels', 'Position', Position_edit_1, 'Callback', @update);
    h_edit_2 = uicontrol('Parent', Parent, 'Style', 'edit', 'String', currentRange(2), 'Units', 'pixels', 'Position', Position_edit_2, 'Callback', @update);
    
    funs = varargin;
    cellfun(@(f) f(currentRange), funs);
    
    % Allow lower and upper values to exceed each other (24.10.2017)
    function update(varargin),
        Value_1 = str2double(get(h_edit_1, 'String'));
        Value_2 = str2double(get(h_edit_2, 'String'));
        if ~isnan(Value_1) && ~isnan(Value_2) && ~imag(Value_1) && ~imag(Value_2),
            if Value_1 < Value_2, currentRange = [Value_1 Value_2];
            else, currentRange = [Value_2 Value_1]; end
        else,
            % Reset if either is illegal input
            set(h_edit_1, 'String', sprintf('%g', currentRange(1))); 
            set(h_edit_2, 'String', sprintf('%g', currentRange(2))); 
        end
        cellfun(@(f) f(currentRange), funs);
    end
    
    % Dont allow lower and upper values to exceed each other
%     function update(varargin),
%         Value_1 = sscanf(get(h_edit_1, 'String'), '%g');
%         Value_2 = sscanf(get(h_edit_2, 'String'), '%g');
%         if ~isempty(Value_1),
%             if currentRange(2) < Value_1, set(h_edit_1, 'String', sprintf('%g', currentRange(1))); % Reset if illegal input
%             else, currentRange(1) = Value_1; end
%         end
%         if ~isempty(Value_2),
%             if currentRange(1) > Value_2, set(h_edit_2, 'String', sprintf('%g', currentRange(2))); % Reset if illegal input
%             else, currentRange(2) = Value_2; end
%         end
%         cellfun(@(f) f(currentRange), funs);
%     end
end
