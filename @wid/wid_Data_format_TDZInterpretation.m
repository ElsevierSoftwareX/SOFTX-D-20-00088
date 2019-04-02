% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function format = wid_Data_format_TDZInterpretation(obj)
    % Each row: wit-tag name, {isVisible; write-parser; read-parser}
    subformat_TDZInterpretation_v5 = ... % Excluding the Version-tag
    	{ ...
        'Version' {false; @int32; @int32}; ...
        'UnitName', {true; @char; @char} ...
        };
    
    % Each row: wit-tag name, {subformat}
    format_TDZInterpretation_v5 = ...
        [obj.wid_Data_format_TData(); ...
        obj.wid_Data_format_TDInterpretation(); ...
        {'TDZInterpretation' subformat_TDZInterpretation_v5}];
    
    format = format_TDZInterpretation_v5;
end
