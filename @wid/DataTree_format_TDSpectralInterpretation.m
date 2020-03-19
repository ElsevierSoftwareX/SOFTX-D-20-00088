% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function format = DataTree_format_TDSpectralInterpretation(Version_or_obj),
    if nargin == 0, Version_or_obj = []; end
    
    % Each row: wit-tag name, isVisible, {write-parser; read-parser}
    subformat_TDSpectralInterpretation = ... % Excluding the Version-tag
        { ...
        'Version' false {@int32; @int32}; ...
        'ExcitationWaveLength' true {@double; @double} ...
        };
    
    % Each row: wit-tag name, isVisible, {subformat}
    format_TDSpectralInterpretation = ...
        [wid.DataTree_format_TData(Version_or_obj); ...
        wid.DataTree_format_TDInterpretation(Version_or_obj); ...
        {'TDSpectralInterpretation' true subformat_TDSpectralInterpretation}];
    
    format = format_TDSpectralInterpretation;
end
