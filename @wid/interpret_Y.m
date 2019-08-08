% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function Y = interpret_Y(obj, Unit_new, Y),
    if nargin < 2, Unit_new = []; end % Do not change unit
    Info = obj.Info; % Load only once
    if nargin < 3, Y = Info.Y; end % Instead of custom input, use Info.Y
    T = Info.YTransformation; % Should always exist
    I = Info.YInterpretation; % Might not exist
    if isempty(I) && ~isempty(T), % In case Interpretation does not exist
        I = strrep(T.Type, 'Transformation', 'Interpretation');
    end
    [~, Y] = wip.interpret(I, Unit_new, Info.YUnit, Y);
end
