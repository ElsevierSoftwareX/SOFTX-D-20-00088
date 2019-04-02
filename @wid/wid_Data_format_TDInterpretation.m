% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function format = wid_Data_format_TDInterpretation(obj)
    % Each row: wit-tag name, {write-parser; read-parser}
    subformat_TDInterpretation_v5 = ... % Excluding the Version-tag
        { ...
        'Version' {false; @int32; @int32}; ...
        'UnitIndex' {true; @int32; @int32} ...
        };
    
    % Each row: wit-tag name, {subformat}
    format = {'TDInterpretation' subformat_TDInterpretation_v5};
end
