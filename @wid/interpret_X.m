% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function X = interpret_X(obj, Unit_new, X),
    if nargin < 2, Unit_new = []; end % Do not change unit
    Info = obj.Info; % Load only once
    if nargin < 3, X = Info.X; end % Instead of custom input, use Info.X
    T = Info.XTransformation; % Should always exist
    I = Info.XInterpretation; % Might not exist
    if isempty(I) && ~isempty(T), % In case Interpretation does not exist
        I = strrep(T.Type, 'Transformation', 'Interpretation');
    end
    [~, X] = wip.interpret(I, Unit_new, Info.XUnit, X);
end
