% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This shows Point positions on any specified axes handle. This helper
% function is utilized by wid-class plot_position.m. The output 'h_point'
% is a created graphical object handle. The first expected input 'Ax' is
% a figure axes handle. The second expected input 'positions' is a 1-by-3
% array, where the 1st and the 2nd dimensions represent the number of
% points and the number of point coordinate dimensions, respectively. The
% third expected input 'color' is a 1-by-3 RGB-channel array.
function h_point = plot_position_Point_helper(Ax, positions, color),
    if size(positions, 1) == 1,
        h_point = line(Ax, positions(1), positions(2), 'Color', color, 'LineWidth', 1, 'Marker', 'o'); % Add marker which is same size regardless of the zoom level
    end
end
