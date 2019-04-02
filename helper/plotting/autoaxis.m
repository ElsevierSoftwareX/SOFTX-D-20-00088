% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Used by @wid\plot.m
function [] = autoaxis(hax, X, Y, limit_x, limit_y)
    % Automatically adjust the axis to the inputs X and Y and leave a tiny
    % margin around the data points.
    %ASSUMING INPUT IS VALID!

    %By default do not limit Y-axis values
    if nargin < 5,
        limit_y = [-inf inf];
    end
    
    %By default do not limit X-axis values
    if nargin < 4,
        limit_x = [-inf inf];
    end

    %Get min/max
    minmax_X = double([min(X(:)) max(X(:))]);
    minmax_Y = double([min(Y(:)) max(Y(:))]);

    %Set margin
    margin = 0.025; %percent

    %Update min/max
    minmax_X = minmax_X + [-1 1].*margin.*(minmax_X(2)-minmax_X(1));
    minmax_Y = minmax_Y + [-1 1].*margin.*(minmax_Y(2)-minmax_Y(1));
    
    %Limit min/max
    minmax_X(1) = max(minmax_X(1), limit_x(1)); %Choose larger
    minmax_X(2) = min(minmax_X(2), limit_x(2)); %Choose smaller
    
    minmax_Y(1) = max(minmax_Y(1), limit_y(1)); %Choose larger
    minmax_Y(2) = min(minmax_Y(2), limit_y(2)); %Choose smaller
    
    if minmax_X(1) == minmax_X(2), minmax_X = get(hax, 'XLim'); end
    if minmax_Y(1) == minmax_Y(2), minmax_Y = get(hax, 'YLim'); end
    
    set(hax, ...
        'XLimMode', 'manual', ... %Ensure manual x-axis
        'XLim', minmax_X, ...
        'YLimMode', 'manual', ... %Ensure manual y-axis
        'YLim', minmax_Y);
end
