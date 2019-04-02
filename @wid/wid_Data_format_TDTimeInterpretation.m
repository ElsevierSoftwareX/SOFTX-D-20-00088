% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function format = wid_Data_format_TDTimeInterpretation(obj)
    % Each row: wit-tag name, {subformat}
    format_TDTimeInterpretation_v5 = ...
        [obj.wid_Data_format_TData(); ...
        obj.wid_Data_format_TDInterpretation()];
    
    format = format_TDTimeInterpretation_v5;
end
