% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This shows Image positions on any specified axes handle. This helper
% function is utilized by wid-class plot_position.m. The output 'h_image'
% is a created graphical object handle. The first expected input 'Ax' is
% a figure axes handle. The second expected input 'positions' is a 4-by-3
% array, where the 1st and the 2nd dimensions represent the number of
% points and the number of point coordinate dimensions, respectively. The
% third expected input 'color' is a 1-by-3 RGB-channel array.
function h_image = plot_position_Image_helper(Ax, positions, color),
    % Truncate if the image looks like a line (looking from the xy-plane)
    if all(abs(positions(1,1:2)-positions(4,1:2)) <= 1) && all(abs(positions(2,1:2)-positions(3,1:2)) <= 1),
        positions = (positions([1 2],:) + positions([4 3],:))./2;
    elseif all(abs(positions(1,1:2)-positions(4,1:2)) <= 1) && all(abs(positions(4,1:2)-positions(3,1:2)) <= 1),
        positions = (positions([1 4],:) + positions([2 3],:))./2;
    end

    if size(positions, 1) == 4,
        f = [1 2 3 4]; % How vertices are connected to each other
        v_ii = positions(:,1:2); % Discard the Z-axis indices and reshape for patch
        h_image = patch(Ax, 'Faces', f, 'Vertices', v_ii, 'EdgeColor', color, 'FaceColor', 'none', 'LineWidth', 1);
    elseif size(positions, 1) == 2,
        h_image = markLine_default(Ax, positions, Color_ii);
    end
end
