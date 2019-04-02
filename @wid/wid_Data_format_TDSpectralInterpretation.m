% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function format = wid_Data_format_TDSpectralInterpretation(obj)
    % Each row: wit-tag name, {isVisible; write-parser; read-parser}
    subformat_TDSpectralInterpretation_v5 = ... % Excluding the Version-tag
    	{ ...
        'Version' {false; @int32; @int32}; ...
        'ExcitationWaveLength', {true; @double; @double} ...
        };
    
    % Each row: wit-tag name, {subformat}
    format_TDSpectralInterpretation_v5 = ...
        [obj.wid_Data_format_TData(); ...
        obj.wid_Data_format_TDInterpretation(); ...
        {'TDSpectralInterpretation' subformat_TDSpectralInterpretation_v5}];
    
    format = format_TDSpectralInterpretation_v5;
end
