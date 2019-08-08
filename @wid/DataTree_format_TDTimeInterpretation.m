% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function format = DataTree_format_TDTimeInterpretation(Version_or_obj),
    if nargin == 0, Version_or_obj = []; end
    
    % Each row: wit-tag name, isVisible, {subformat}
    format_TDTimeInterpretation_v5_v6_v7 = ...
        [wid.DataTree_format_TData(Version_or_obj); ...
        wid.DataTree_format_TDInterpretation(Version_or_obj)];
    
    format = format_TDTimeInterpretation_v5_v6_v7;
end
