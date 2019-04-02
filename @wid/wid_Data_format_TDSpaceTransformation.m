% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function format = wid_Data_format_TDSpaceTransformation(obj)
    % Each row: wit-tag name, {isVisible; write-parser; read-parser}
    subformat_TDSpaceTransformation_v5 = ... % Excluding the Version-tag
    	{ ...
        'Version' {false; @int32; @int32}; ...
        'ViewPort3D', ...
        { ... % Sub-format
        'ModelOrigin', {true; @double; @double}; ...
        'WorldOrigin', {true; @double; @double}; ...
        'Scale', {true; @double; @double}; ...
        'Rotation', {true; @double; @double} ...
        }; ...
        'LineInformationValid', {true; @logical; @logical}; ...
        'LineStart_D', {true; @double; @double}; ...
        'LineStart', {true; @single; @single}; ...
        'LineStop_D', {true; @double; @double}; ...
        'LineStop', {true; @single; @single}; ...
        'NumberOfLinePoints', {true; @int32; @int32} ...
        };
    
    % Each row: wit-tag name, {subformat}
    format_TDSpaceTransformation_v5 = ...
        [obj.wid_Data_format_TData(); ...
        obj.wid_Data_format_TDTransformation(); ...
        {'TDSpaceTransformation' subformat_TDSpaceTransformation_v5}];
    
    format = format_TDSpaceTransformation_v5;
end
