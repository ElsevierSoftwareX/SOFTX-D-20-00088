% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function format = DataTree_format_TDInterpretation(Version_or_obj),
    if nargin == 0, Version_or_obj = []; end
    
    % Each row: wit-tag name, isVisible, {write-parser; read-parser}
    subformat_TDInterpretation = ... % Excluding the Version-tag
        { ...
        'Version' false {@int32; @int32}; ...
        'UnitIndex' true {@int32; @int32} ...
        };
    
    % Each row: wit-tag name, {subformat}
    format = {'TDInterpretation' true subformat_TDInterpretation};
end
