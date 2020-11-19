% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function Z = interpret_Z(obj, Unit_new, Z),
    if nargin < 2, Unit_new = []; end % Do not change unit
    Info = obj.Info; % Load only once
    if nargin < 3, Z = Info.Z; end % Instead of custom input, use Info.Z
    T = Info.ZTransformation; % Should always exist
    I = Info.ZInterpretation; % Might not exist
    if isempty(I) && ~isempty(T), % In case Interpretation does not exist
        I = strrep(T.Type, 'Transformation', 'Interpretation');
    end
    [~, Z] = WITio.wip.interpret(I, Unit_new, Info.ZUnit, Z);
end
