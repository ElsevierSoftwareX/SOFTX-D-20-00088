% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function format = DataTree_format_TDLinearTransformation(Version_or_obj),
    if nargin == 0, Version_or_obj = []; end
    
    % Each row: wit-tag name, isVisible, {write-parser; read-parser}
    subformat_TDLinearTransformation = ... % Excluding the Version-tag
        { ...
        'Version' false {@int32; @int32}; ...
        'ModelOrigin_D' true {@double; @double}; ... % (NOT IN ALL LEGACY VERSIONS)
        'WorldOrigin_D' true {@double; @double}; ... % (NOT IN ALL LEGACY VERSIONS)
        'Scale_D' true {@double; @double}; ... % (NOT IN ALL LEGACY VERSIONS)
        'ModelOrigin' true {@single; @single}; ...
        'WorldOrigin' true {@single; @single}; ...
        'Scale' true {@single; @single} ...
        };
    
    % Each row: wit-tag name, isVisible, {subformat}
    format_TDLinearTransformation = ...
        [WITio.core.wid.DataTree_format_TData(Version_or_obj); ...
        WITio.core.wid.DataTree_format_TDTransformation(Version_or_obj); ...
        {'TDLinearTransformation' true subformat_TDLinearTransformation}];
    
    format = format_TDLinearTransformation;
end
