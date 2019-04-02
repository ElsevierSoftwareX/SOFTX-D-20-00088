% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function format = DataTree_format_TDLUTTransformation(Version_or_obj)
    if nargin == 0, Version_or_obj = []; end
    
    % Each row: wit-tag name, isVisible, {write-parser; read-parser}
    subformat_TDLUTTransformation_v5_v6_v7 = ... % Excluding the Version-tag
    	{ ...
        'Version' false {@int32; @int32}; ...
        'LUTSize' true {@int32; @int32}; ...
        'LUT' true {@double; @double}; ...
        'LUTIsIncreasing' true {@logical; @logical} ...
        };
    
    % Each row: wit-tag name, isVisible, {subformat}
    format_TDLUTTransformation_v5_v6_v7 = ...
        [wid.DataTree_format_TData(Version_or_obj); ...
        wid.DataTree_format_TDTransformation(Version_or_obj); ...
        {'TDLUTTransformation' true subformat_TDLUTTransformation_v5_v6_v7}];
    
    format = format_TDLUTTransformation_v5_v6_v7; % Up to v7
end
