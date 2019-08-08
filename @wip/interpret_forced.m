% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [ValueUnit, varargout] = interpret_forced(obj, I, Unit_new, Unit_old, varargin),
    ValueUnit = wip.ArbitraryUnit; % Default ValueUnit
    varargout = cellfun(@double, varargin, 'UniformOutput', false); % Default Value
    
    if nargin < 3, Unit_new = []; end % Default Unit_new
    if nargin < 4, Unit_old = []; end % Default Unit_old
    
    if ~isempty(Unit_old) && ischar(Unit_old), ValueUnit = Unit_old; end % If given Unit_old is ValueUnit_old
    
    if isempty(I), return; end % Do nothing if empty Interpretation
    if isa(I, 'wid'), Type = I.Type; % Get its Type
    elseif iscell(I) && numel(I) == 2, Type = I{1};
    elseif ischar(I), Type = I; end

    % Interpret input
    [ValueUnit, varargout{1:nargout-1}] = wip.interpret(I, Unit_new, Unit_old, varargout{:});
    % Override units
    if ~isempty(obj),
        ForceUnit = [];
        switch(Type),
            case 'TDZInterpretation', ForceUnit = obj.ForceDataUnit; % Using DataUnit
            case 'TDSpaceInterpretation', ForceUnit = obj.ForceSpaceUnit; % Using SpaceUnit
            case 'TDSpectralInterpretation', ForceUnit = obj.ForceSpectralUnit; % Using SpectralUnit
            case 'TDTimeInterpretation', ForceUnit = obj.ForceTimeUnit; % Using TimeUnit
        end
        if ~isempty(ForceUnit),
            [ValueUnit, varargout{1:nargout-1}] = wip.interpret(I, ForceUnit, ValueUnit, varargout{:});
        end
    end
end
