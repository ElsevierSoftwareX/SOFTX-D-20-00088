% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Used by @wid\plot.m
function add_ticks_to_image(SizeX, SizeY, LengthX, LengthY, LengthUnit, N_ticks),
        if nargin < 6, N_ticks = 3; end
        
        XTick = linspace(0.5, double(SizeX)+0.5, N_ticks);
        YTick = linspace(0.5, double(SizeY)+0.5, N_ticks);
        XTickLabel = arrayfun(@(x) sprintf('%.3g', x), linspace(0, double(LengthX), N_ticks), 'UniformOutput', false);
        YTickLabel = arrayfun(@(y) sprintf('%.3g', y), linspace(0, double(LengthY), N_ticks), 'UniformOutput', false);
        set(gca, 'XTick', XTick, 'XTickLabel', XTickLabel);
        set(gca, 'YTick', YTick, 'YTickLabel', YTickLabel);
        xlabel(LengthUnit);
        ylabel(LengthUnit);
end
