% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function format = DataTree_format_TDSpectralTransformation(Version_or_obj),
    if nargin == 0 || numel(Version_or_obj) ~= 1, Version_or_obj = []; end
    
    % Each row: wit-tag name, isVisible, {write-parser; read-parser}
    subformat_TDSpectralTransformation = ... % Excluding the Version-tag
        { ...
        'Version' false {@int32; @int32}; ...
        'SpectralTransformationType' true {@int32; @int32}; ...
        'Polynom' true {@double; @double}; ... % Quadratic polynomial with 3 coefficients.
        'nC' true {@double; @double}; ...
        'LambdaC' true {@double; @double}; ...
        'Gamma' true {@double; @double}; ...
        'Delta' true {@double; @double}; ...
        'm' true {@double; @double}; ...
        'd' true {@double; @double}; ...
        'x' true {@double; @double}; ...
        'f' true {@double; @double}; ...
        'FreePolynomOrder' true {@int32; @int32}; ... % (NOT IN ALL LEGACY VERSIONS)
        'FreePolynomStartBin' true {@double; @double}; ... % (NOT IN ALL LEGACY VERSIONS)
        'FreePolynomStopBin' true {@double; @double}; ... % (NOT IN ALL LEGACY VERSIONS)
        'FreePolynom' true {@double; @double} ... % (NOT IN ALL LEGACY VERSIONS) % Exists but not used by WITec Control software
        };
    
    % Each row: wit-tag name, isVisible, {subformat}
    format_TDSpectralTransformation = ...
        [WITio.obj.wid.DataTree_format_TData(Version_or_obj); ...
        WITio.obj.wid.DataTree_format_TDTransformation(Version_or_obj); ...
        {'TDSpectralTransformation' true subformat_TDSpectralTransformation}];
    
    format = format_TDSpectralTransformation;
end
