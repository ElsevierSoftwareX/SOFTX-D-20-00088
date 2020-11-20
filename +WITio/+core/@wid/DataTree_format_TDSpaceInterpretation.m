% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function format = DataTree_format_TDSpaceInterpretation(Version_or_obj),
    if nargin == 0, Version_or_obj = []; end
    
    % Each row: wit-tag name, isVisible, {subformat}
    format_TDSpaceInterpretation = ...
        [WITio.core.wid.DataTree_format_TData(Version_or_obj); ...
        WITio.core.wid.DataTree_format_TDInterpretation(Version_or_obj)];
    
    format = format_TDSpaceInterpretation;
end
