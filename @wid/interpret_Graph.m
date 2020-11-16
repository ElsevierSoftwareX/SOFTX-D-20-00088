% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function Graph = interpret_Graph(obj, Unit_new, Graph),
    if nargin < 2, Unit_new = []; end % Do not change unit
    Info = obj.Info; % Load only once
    if nargin < 3, Graph = Info.Graph; end % Instead of custom input, use Info.Graph
    T = Info.GraphTransformation; % Should always exist
    I = Info.GraphInterpretation; % Might not exist
    if isempty(I) && ~isempty(T), % In case Interpretation does not exist
        I = strrep(T.Type, 'Transformation', 'Interpretation');
    end
    [~, Graph] = wit.io.wip.interpret(I, Unit_new, Info.GraphUnit, Graph);
end
