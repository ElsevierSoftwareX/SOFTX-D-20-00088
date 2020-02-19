% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function format = DataTree_format_TDTransformation(Version_or_obj),
    if nargin == 0, Version_or_obj = []; end
    
    % Parse Project from input
    Project = wip.empty;
    if isa(Version_or_obj, 'wid'), Project = Version_or_obj.Project;
    elseif isa(Version_or_obj, 'wip'), Project = Version_or_obj; end
    
    if isempty(Version) || Version == 7 || Version == 6 || Version == 5,
        % Each row: wit-tag name, isVisible, {write-parser; read-parser}
        subformat_TDTransformation = ... % Excluding the Version-tag
            { ...
            'Version' false {@int32; @int32}; ...
            'StandardUnit' true {@char; @char}; ...
            'UnitKind' true {@int32; @int32}; ...
            'InterpretationID' true {@(x) int32(max([0 x.Id])); @(x) Project.find_Data(x)}; ... % Set Id (or 0 if does not exist)
            'IsCalibrated' true {@logical; @logical} ...
            };
    elseif Version >= 0 && Version < 5,
        % Each row: wit-tag name, isVisible, {write-parser; read-parser}
        subformat_TDTransformation = ... % Excluding the Version-tag
            { ...
            'Version' false {@int32; @int32}; ...
            'StandardUnit' true {@char; @char}; ...
            'UnitKind' true {@int32; @int32} ...
            };
    end
    
    % Each row: wit-tag name, isVisible, {subformat}
    format = {'TDTransformation' true subformat_TDTransformation};
end
