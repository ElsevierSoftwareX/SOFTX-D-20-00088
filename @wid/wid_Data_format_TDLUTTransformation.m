% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function format = wid_Data_format_TDLUTTransformation(obj)
    % Each row: wit-tag name, {isVisible; write-parser; read-parser}
    subformat_TDLUTTransformation_v5 = ... % Excluding the Version-tag
        { ...
        'Version' {false; @int32; @int32}; ...
        'LUTSize', {true; @int32; @int32}; ...
        'LUT', {true; @double; @double}; ...
        'LUTIsIncreasing', {true; @logical; @logical} ...
        };
    
    % Each row: wit-tag name, {subformat}
    format_TDLUTTransformation_v5 = ...
        [obj.wid_Data_format_TData(); ...
        obj.wid_Data_format_TDTransformation(); ...
        {'TDLUTTransformation' subformat_TDLUTTransformation_v5}];
    
    format = format_TDLUTTransformation_v5;
end
