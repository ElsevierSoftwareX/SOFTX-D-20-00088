% BSD 3-Clause License
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% * Redistributions of source code must retain the above copyright notice, this
%   list of conditions and the following disclaimer.
% 
% * Redistributions in binary form must reproduce the above copyright notice,
%   this list of conditions and the following disclaimer in the documentation
%   and/or other materials provided with the distribution.
% 
% * Neither the name of Aalto University nor the names of its
%   contributors may be used to endorse or promote products derived from
%   this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function [h_mainbar, h_sidebar, h_button, h_button_2, h_button_3] = sidebar(Fig, sidebar_Width),
    if nargin < 1 || isempty(Fig), Fig = gcf; end % By default, update gcf
    if nargin < 2 || isempty(sidebar_Width), sidebar_Width = 100; end % By default, 100 pixels width
    
    Visible = get(Fig, 'Visible'); % Store visibility
    set(Fig, 'Visible', 'off'); % Set invisible
    Margin = 3; % Margin in pixels
    BorderWidth = 3; % BorderWidth in pixels
    h_mainbar = uipanel('BackgroundColor', 'white', 'BorderType', 'none', 'Tag', 'mainbar');
    h_sidebar = uipanel('BorderType', 'line', 'BorderWidth', BorderWidth, 'HighlightColor', 'black', 'Units', 'pixels', 'Position', [0 0 sidebar_Width 25+2.*(Margin+BorderWidth-1)], 'Tag', 'sidebar');
    set(h_sidebar, 'UserData', Margin); % Set margin as UserData
    
    if isprop(Fig, 'SizeChangedFcn'), set(Fig, 'SizeChangedFcn', @update);
    else, set(Fig, 'ResizeFcn', @update); end % Added for backward compability
    
    Ax = findobj(Fig, 'Type', 'Axes'); % Find all Axes
    if isempty(Ax) Ax = axes('Parent', Fig); end % Create default axes if needed
    set(Ax, 'Parent', h_mainbar);
%     set(findobj(Fig, 'Type', 'uitable'), 'Parent', h_mainbar); % Handle uitables
    
    ViewWidth = sidebar_Width-2.*(Margin+BorderWidth-1);
    h_button = uicontrol('Parent', h_sidebar, 'Style', 'pushbutton', 'String', 'Close', 'Units', 'pixels', 'Position', [Margin Margin 5/12.*ViewWidth 25], 'Callback', @callback_1);
    h_button_2 = uicontrol('Parent', h_sidebar, 'Style', 'pushbutton', 'String', '&', 'Units', 'pixels', 'Position', [Margin+5/12.*ViewWidth Margin ViewWidth/6 25], 'Callback', @callback_2);
    h_button_3 = uicontrol('Parent', h_sidebar, 'Style', 'pushbutton', 'String', 'Export', 'Units', 'pixels', 'Position', [Margin+7/12.*ViewWidth Margin 5/12.*ViewWidth 25], 'Callback', @callback_3);
    
    update(); % Update Position of bars
    set(Fig, 'Visible', Visible); % Restore visibility
    
    % Close callback
    function callback_1(varargin), WITio.misc.ui.sidebar_delete(Fig); end
    
    % Close + Export callback
    function callback_2(varargin),
        callback_1(varargin{:});
        callback_3(varargin{:});
    end
    
    % Export callback
    function callback_3(varargin), WITio.misc.ui.sidebar_export(Fig); end
    
    % Proper resizing of the uipanels (mainbar, sidebar)
    function update(varargin),
        % Store previous Units
        fig_Units = get(Fig, 'Units');
        mainbar_Units = get(h_mainbar, 'Units');
        sidebar_Units = get(h_sidebar, 'Units');
        
        % Change Units to pixels
        set(Fig, 'Units', 'pixels');
        set(h_mainbar, 'Units', 'pixels');
        set(h_sidebar, 'Units', 'pixels');
        
        % Calculate and set new Positions
        drawnow; % Update Figure first (added for backward compability)
        fig_Position = get(Fig, 'Position');
        sidebar_Position = get(h_sidebar, 'Position'); % Get previous sidebar Position
        mainbar_Position = [0 0 fig_Position(3)-sidebar_Position(3) fig_Position(4)];
        sidebar_Position = [fig_Position(3)-sidebar_Position(3) fig_Position(4)-sidebar_Position(4) sidebar_Position(3) sidebar_Position(4)];
        set(h_mainbar, 'Position', mainbar_Position);
        set(h_sidebar, 'Position', sidebar_Position);
        
        % Restore previous Units
        set(h_mainbar, 'Units', mainbar_Units);
        set(h_sidebar, 'Units', sidebar_Units);
        set(Fig, 'Units', fig_Units);
    end
end
