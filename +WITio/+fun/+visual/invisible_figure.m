% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Used by @wid\plot.m and @wip\manager.m
function h = invisible_figure(varargin),
    % Equivalent to figure-method but creates it as invisible!
    DefaultFigureVisible = get(0, 'DefaultFigureVisible'); % Store visibility
    set(0, 'DefaultFigureVisible', 'off'); % Set invisibility
    h = figure(varargin{:});
    set(0, 'DefaultFigureVisible', DefaultFigureVisible); % Restore visibility
end
