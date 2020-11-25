% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% THIS DOES NOT SUPPORT WIP PROJECT OBJECT ARRAYS!
function [ValueUnit, varargout] = transform_forced(obj, T, varargin),
    ValueUnit = WITio.obj.wip.ArbitraryUnit; % Default ValueUnit
    varargout = cellfun(@double, varargin, 'UniformOutput', false); % Default Value
    
    if isempty(T), return; end % Do nothing if empty Transformation

    % Interpret input
    [ValueUnit, varargout{1:nargout-1}] = WITio.obj.wip.transform(T, varargout{:});
    % Override units
    if ~isempty(obj),
        Interpretation = T.Data.TDTransformation.InterpretationID; % Prefer the found interpretation
        if isempty(Interpretation), % But if it is not found, then use the known type
            switch(T.Type),
                case 'TDLinearTransformation', % Do nothing
                case 'TDSpaceTransformation', Interpretation = 'TDSpaceInterpretation';
                case 'TDSpectralTransformation', Interpretation = 'TDSpectralInterpretation';
            end
        end
        [ValueUnit, varargout{1:nargout-1}] = obj.interpret_forced(Interpretation, ValueUnit, ValueUnit, varargout{:});
    end
end
