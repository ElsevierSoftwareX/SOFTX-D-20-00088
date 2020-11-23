% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function format = DataTree_format_TDTransformation(Version_or_obj),
    if nargin == 0, Version_or_obj = []; end
    
    % Parse Project from input
    Project = WITio.obj.wip.empty;
    if isa(Version_or_obj, 'WITio.obj.wid'), Project = Version_or_obj.Project;
    elseif isa(Version_or_obj, 'WITio.obj.wip'), Project = Version_or_obj; end
    
    % Each row: wit-tag name, isVisible, {write-parser; read-parser}
    subformat_TDTransformation = ... % Excluding the Version-tag
        { ...
        'Version' false {@int32; @int32}; ...
        'StandardUnit' true {@char; @char}; ...
        'UnitKind' true {@int32; @int32}; ...
        'InterpretationID' true {@(x) int32(max([0 x.Id])); @(x) Project.find_Data(x)}; ... % (NOT IN ALL LEGACY VERSIONS) % Set Id (or 0 if does not exist)
        'IsCalibrated' true {@logical; @logical} ... % (NOT IN ALL LEGACY VERSIONS)
        };
    
    % Each row: wit-tag name, isVisible, {subformat}
    format = {'TDTransformation' true subformat_TDTransformation};
end
