% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [h_popup, h_label] = sidebar_perceptually_uniform_colormaps(Fig),
    persistent currentValue; % Remember this always
    if isempty(currentValue), currentValue = 2; end % Default: inferno
    
    if nargin < 1 || isempty(Fig), Fig = gcf; end % By default, update gcf
    Parent = findobj(Fig, 'Type', 'uipanel', '-and', 'Tag', 'sidebar'); % Find sidebar uipanel
    if isempty(Parent), [~, Parent] = WITio.self.ui.sidebar(Fig); end % Create one if it does not exist
%     Ax = get(Fig, 'CurrentAxes');
    
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
    Position_label = [View(1) View(2)+cHeight(1) View(3) Height(1)];
    Position_popup = [View(1) View(2)+cHeight(2) View(3) Height(2)];

    Position = [Position(1) Position(2)-sum(Height)-2.*(Margin+BorderWidth-1) Position(3) Position(4)+sum(Height)+2.*(Margin+BorderWidth-1)]; % Margins included [left bottom width height]
    set(Parent, 'Position', Position); % Set Position in pixels
    set(Parent, 'Units', Units); % Restore Units
    
    h_label = uicontrol('Parent', Parent, ...
        'Style', 'text', ...
        'String', 'Colormap:', ...
        'Units', 'pixels', ...
        'Position', Position_label);
    
    C_options = {'magma', 'inferno', 'plasma', 'viridis', 'cividis', 'gray', 'graymagma', 'grayinferno', 'grayplasma', 'grayviridis', 'graycividis'};
    h_popup = uicontrol('Parent', Parent, ...
        'Style', 'popup', ...
        'String', C_options, ...
        'Value', currentValue, ...
        'Units', 'pixels', ...
        'Position', Position_popup, ...
        'Callback', @update, ...
        'Tooltip', '<html><b>Set default colormap:</b><br>These matplotlib colormaps are designed to be least misleading when<br>visually interpreted for scientific inferences. This risk is minimized by<br>perceptual linearity in both color and lightness spaces, and colorblind-<br>friendliness. See this informative video: https://youtu.be/xAoljeRJ3lU</html>'); % Tooltip feature added 8.11.2017
    
    % Update current colormap
    update();
    
    % Proper changing of the colormap
    function update(varargin),
        currentValue = get(h_popup, 'Value'); % Store as global option
        set(0, 'DefaultFigureColormap', WITio.fun.lib.perceptually_uniform_colormap(C_options{currentValue})); % Set new default! Backward compatible!
        set(Fig, 'Colormap', 'default'); % Reset to new default! Backward compatible!
%         set(Fig, 'Colormap', WITio.fun.lib.perceptually_uniform_colormap(C_options{currentValue}));
%         colormap(Ax, WITio.fun.lib.perceptually_uniform_colormap(C_options{currentValue}));
    end
end
