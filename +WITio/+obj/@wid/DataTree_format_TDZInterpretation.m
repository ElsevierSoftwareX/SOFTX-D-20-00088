% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function format = DataTree_format_TDZInterpretation(Version_or_obj),
    if nargin == 0 || numel(Version_or_obj) ~= 1, Version_or_obj = []; end
    
    % Each row: wit-tag name, isVisible, {write-parser; read-parser}
    subformat_TDZInterpretation = ... % Excluding the Version-tag
        { ...
        'Version' false {@int32; @int32}; ...
        'UnitName' true {@char; @char} ...
        };
    
    % Each row: wit-tag name, isVisible, {subformat}
    format_TDZInterpretation = ...
        [WITio.obj.wid.DataTree_format_TData(Version_or_obj); ...
        WITio.obj.wid.DataTree_format_TDInterpretation(Version_or_obj); ...
        {'TDZInterpretation' true subformat_TDZInterpretation}];
    
    format = format_TDZInterpretation;
end
