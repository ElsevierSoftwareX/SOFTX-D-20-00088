% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This shows Line positions on any specified axes handle. This helper
% function is utilized by wid-class plot_position.m. The output 'h_line'
% is a created graphical object handle. The first expected input 'Ax' is
% a figure axes handle. The second expected input 'positions' is a 2-by-3
% array, where the 1st and the 2nd dimensions represent the number of
% points and the number of point coordinate dimensions, respectively. The
% third expected input 'color' is a 1-by-3 RGB-channel array.
function h_line = plot_position_Line_helper(Ax, positions, color),
    % Truncate if the line looks like a point (looking from the xy-plane)
    if all(abs(positions(1,1:2)-positions(2,1:2)) <= 1),
        positions = (positions(1,:) + positions(2,:))./2;
    end

    if size(positions, 1) == 2,
        h_line = line(positions(:,1), positions(:,2), 'Parent', Ax, 'Color', color, 'LineWidth', 1); % Backward compatible with R2011a!
    elseif size(positions, 1) == 1,
        h_line = markPoint_default(Ax, positions, Color_ii);
    end
end
