% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function format = wid_Data_format_TDTransformation(obj)
    % Each row: wit-tag name, {write-parser; read-parser}
    subformat_TDTransformation_v5 = ... % Excluding the Version-tag
        { ...
        'Version' {false; @int32; @int32}; ...
        'StandardUnit' {true; @char; @char}; ...
        'UnitKind' {true; @int32; @int32}; ...
        'InterpretationID' {true; @(x) int32(max([0 x.Id])); @(x) obj.Project.find_Data(x)}; ... % Set Id (or 0 if does not exist)
        'IsCalibrated' {true; @logical; @logical} ...
        };
    
    % Each row: wit-tag name, {subformat}
    format = {'TDTransformation' subformat_TDTransformation_v5};
end
