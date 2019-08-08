% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function delete_uipanels(Fig),
    if nargin < 1 || isempty(Fig), Fig = gcf; end % By default, update gcf
    h_sidebar = findobj(Fig, 'Type', 'uipanel', '-and', 'Tag', 'sidebar'); % Find sidebar uipanel
    h_mainbar = findobj(Fig, 'Type', 'uipanel', '-and', 'Tag', 'mainbar'); % Find mainbar uipanel
    
    % Adjust Figure width accordingly
%     if ishandle(h_sidebar),
%         % Temporarily change figure Units to Pixels
%         fig_Units = get(Fig, 'Units');
%         set(Fig, 'Units', 'Pixels');
%         % Set sidebar Units to Pixels
%         set(h_sidebar, 'Units', 'Pixels');
%         % Get sidebar Position
%         sidebar_Position = get(h_sidebar, 'Position');
%         % Change figure Position width
%         fig_Position = get(Fig, 'Position');
%         set(Fig, 'Position', [fig_Position(1:2) fig_Position(3)-sidebar_Position(3) fig_Position(4)]);
%         % Restore figure Units
%         set(Fig, 'Units', fig_Units);
%     end
    
    % Proper deletion of the uipanels (mainbar, sidebar)
    if isprop(Fig, 'SizeChangedFcn'), set(Fig, 'SizeChangedFcn', '');
    else, set(Fig, 'ResizeFcn', ''); end % Added for backward compability
    delete(allchild(h_sidebar));
    delete(h_sidebar);
    Ax = findobj(allchild(h_mainbar), 'flat', 'Type', 'Axes');
    set(Ax, 'Parent', Fig);
%     set(findobj(allchild(h_mainbar), 'flat', 'Type', 'uitable'), 'Parent', Fig); % Handle uitables
    delete(h_mainbar);
end
