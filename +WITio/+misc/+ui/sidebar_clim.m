% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [fun_refresh, h_edit_1, h_edit_2, h_button_1, h_button_2, h_button_3, h_button_4, h_label_1, h_label_2] = sidebar_clim(Fig),
    if nargin < 1 || isempty(Fig), Fig = gcf; end % By default, update gcf
    Parent = findobj(Fig, 'Type', 'uipanel', '-and', 'Tag', 'sidebar'); % Find sidebar uipanel
    if isempty(Parent), [~, Parent] = WITio.misc.ui.sidebar(Fig); end % Create one if it does not exist
    Ax = get(Fig, 'CurrentAxes');
    
    % Calculate Positions
    Units = get(Parent, 'Units'); % Store Units
    set(Parent, 'Units', 'pixels'); % Proceed in pixels
    Position = get(Parent, 'Position'); % Get Position in pixels
    Margin = get(Parent, 'UserData'); % Get margin in pixels
    BorderWidth = get(Parent, 'BorderWidth'); % Get BorderWidth in pixels
    
    View = [Margin Position(4)+Margin Position(3)-2.*(Margin+BorderWidth-1) 0]; % Margins included [left bottom width height]
    Height = [15 25 25 25 25];
%     cHeight = [cumsum(Height(2:end), 'reverse') 0];
    cHeight = [fliplr(cumsum(fliplr(Height(2:end)), 2)) 0]; % Added for backward compability
    Position_label_1 = [View(1) View(2)+cHeight(1) View(3) Height(1)];
    Position_edit_1 = [View(1) View(2)+cHeight(2) View(3) Height(2)];
    Position_edit_2 = [View(1) View(2)+cHeight(3) View(3) Height(3)];
    Position_button_1 = [View(1) View(2)+cHeight(4) View(3)/2 Height(4)];
    Position_button_2 = [View(1)+View(3)/2 View(2)+cHeight(4) View(3)/2 Height(4)];
%     Position_button_3 = [View(1) View(2)+cHeight(5) View(3)/2 Height(5)];
%     Position_button_4 = [View(1)+View(3)/2 View(2)+cHeight(5) View(3)/2 Height(5)];
    
    Position_label_2 = [View(1) View(2)+cHeight(5) View(3).*4/6 Height(5)];
    Position_button_3 = [View(1)+View(3).*4/6 View(2)+cHeight(5) View(3)/6 Height(5)];
    Position_button_4 = [View(1)+View(3).*5/6 View(2)+cHeight(5) View(3)/6 Height(5)];

    Position = [Position(1) Position(2)-sum(Height)-2.*(Margin+BorderWidth-1) Position(3) Position(4)+sum(Height)+2.*(Margin+BorderWidth-1)]; % Margins included [left bottom width height]
    set(Parent, 'Position', Position); % Set Position in pixels
    set(Parent, 'Units', Units); % Restore Units
    
    h_label_1 = uicontrol('Parent', Parent, 'Style', 'text', 'String', 'Visual over:', 'Units', 'pixels', 'Position', Position_label_1);
    
    h_edit_1 = uicontrol('Parent', Parent, 'Style', 'edit', 'String', '', 'Units', 'pixels', 'Position', Position_edit_1, 'Callback', @update);
    h_edit_2 = uicontrol('Parent', Parent, 'Style', 'edit', 'String', '', 'Units', 'pixels', 'Position', Position_edit_2, 'Callback', @update);
    h_button_1 = uicontrol('Parent', Parent, 'Style', 'pushbutton', 'String', 'Clever', 'Units', 'pixels', 'Position', Position_button_1, 'Callback', @update_clever, 'Tooltip', '<html><b>Clever min/max:</b><br>Find and use dataset min/max by clever statistics of 4-sigmas.</html>');
    h_button_2 = uicontrol('Parent', Parent, 'Style', 'pushbutton', 'String', 'Min/max', 'Units', 'pixels', 'Position', Position_button_2, 'Callback', @update_minmax, 'Tooltip', '<html><b>Min/max:</b><br>Use dataset mininum and maximum.</html>');
%     h_button_3 = uicontrol('Parent', Parent, 'Style', 'pushbutton', 'String', 'MRLCM', 'Units', 'pixels', 'Position', Position_button_3, 'Callback', @update_MRLCM, 'Tooltip', 'Preserve ratios and correct multiplicative scanline distortions by MRLCM-algorithm.');
%     h_button_4 = uicontrol('Parent', Parent, 'Style', 'pushbutton', 'String', 'MDLCA', 'Units', 'pixels', 'Position', Position_button_4, 'Callback', @update_MDLCA, 'Tooltip', 'Preserve differences and correct additive scanline distortions by MDLCA-algorithm.');
    
    h_label_2 = uicontrol('Parent', Parent, 'Style', 'text', 'String', 'Restore scanlines:', 'Units', 'pixels', 'Position', Position_label_2);
    h_button_3 = uicontrol('Parent', Parent, 'Style', 'pushbutton', 'String', 'R', 'Units', 'pixels', 'Position', Position_button_3, 'Callback', @update_MRLCM, 'Tooltip', '<html><b>Preserve ratios:</b><br>Correct multiplicative scanline distortions by MRLCM-algorithm.</html>');
    h_button_4 = uicontrol('Parent', Parent, 'Style', 'pushbutton', 'String', 'D', 'Units', 'pixels', 'Position', Position_button_4, 'Callback', @update_MDLCA, 'Tooltip', '<html><b>Preserve differences:</b><br>Correct additive scanline distortions by MDLCA-algorithm.</html>');
    % Implement later R+ and D+ using clever statistics instead of median?
    
    update_clever();
    fun_refresh = @refresh;
    
    function update_MRLCM(varargin),
        h_image = findobj(Ax, 'Type', 'image');
        CData = get(h_image, 'CData');
        if ~isempty(CData),
            set(h_image, 'CData', WITio.fun.correct.apply_MRLCM(CData, 1)); % Preserve ratios (i.e. A, I, Sum)
        end
    end
    
    function update_MDLCA(varargin),
        h_image = findobj(Ax, 'Type', 'image');
        CData = get(h_image, 'CData');
        if ~isempty(CData),
            set(h_image, 'CData', WITio.fun.correct.apply_MDLCA(CData, 1)); % Preserve differences (i.e. Fwhm, Pos)
        end
    end
    
    function update_clever(varargin),
        % Get smart 4-sigmas range for best visibility using clever statistics
        CData = get(findobj(Ax, 'Type', 'image'), 'CData');
        if ~isempty(CData),
            [~, ~, ~, ~, ~, cmin, cmax] = WITio.fun.clever_statistics_and_outliers(CData, [], 4);
            if cmin == cmax || isnan(cmin) || isnan(cmax), return; end % Must not be equivalent or NaN!
            set(h_edit_1, 'String', sprintf('%g', cmin));
            set(h_edit_2, 'String', sprintf('%g', cmax));
            caxis(Ax, double([cmin cmax]));
        end
    end
    
    function update_minmax(varargin),
        CData = get(findobj(Ax, 'Type', 'image'), 'CData');
        if ~isempty(CData),
            cmin = min(CData(:));
            cmax = max(CData(:));
            if cmin == cmax, return; end % Must not be equivalent!
            set(h_edit_1, 'String', sprintf('%g', cmin));
            set(h_edit_2, 'String', sprintf('%g', cmax));
            caxis(Ax, double([cmin cmax]));
        end
    end
    
    function update(varargin),
        CLim = get(Ax, 'CLim');
        if ~isempty(CLim),
            String_1 = sscanf(get(h_edit_1, 'String'), '%g');
            String_2 = sscanf(get(h_edit_2, 'String'), '%g');
            if isempty(String_1) || isinf(String_1) || isnan(String_1) || String_1 >= String_2, String_1 = CLim(1); end
            if isempty(String_2) || isinf(String_2) || isnan(String_2) || String_2 <= String_1, String_2 = CLim(2); end
            set(h_edit_1, 'String', sprintf('%g', String_1));
            set(h_edit_2, 'String', sprintf('%g', String_2));
            caxis(Ax, [String_1 String_2]);
        end
    end

    function refresh(varargin),
        CLim = get(Ax, 'CLim');
        if ~isempty(CLim),
            set(h_edit_1, 'String', sprintf('%g', CLim(1)));
            set(h_edit_2, 'String', sprintf('%g', CLim(2)));
        end
    end
end
