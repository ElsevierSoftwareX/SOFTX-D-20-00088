% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function obj = new_Transformation_Spectral(O_wit),
    if nargin == 0 || isempty(O_wit), O_wit = WITio.class.wid.new(); end % Create O_wit
    Version = WITio.class.wip.get_Root_Version(O_wit);
    
    % Coefficients that do not (asymptotically) transform (in WITec Project 2.10.3.3)
    Tag_Extra = WITio.class.wit('TDSpectralTransformation', [ ...
        WITio.class.wit('Version', int32(0)) ...
        WITio.class.wit('SpectralTransformationType', int32(1)) ... % 0 if Polynom-transformation
        WITio.class.wit('Polynom', double([0 1 0])) ... % [1 1 0] for null-transformation in MATLAB
        WITio.class.wit('nC', double(0)) ... % -1 for null-transformation in MATLAB
        WITio.class.wit('LambdaC', double(0)) ...
        WITio.class.wit('Gamma', double(0)) ...
        WITio.class.wit('Delta', double(0)) ...
        WITio.class.wit('m', double(1)) ...
        WITio.class.wit('d', double(realmax('double'))) ...
        WITio.class.wit('x', double(1)) ...
        WITio.class.wit('f', double(realmax('double'))) ...
        WITio.class.wit('FreePolynomOrder', double(1)) ... % (NOT IN ALL LEGACY VERSIONS)
        WITio.class.wit('FreePolynomStartBin', double(0)) ... % (NOT IN ALL LEGACY VERSIONS)
        WITio.class.wit('FreePolynomStopBin', double(realmax('double'))) ... % (NOT IN ALL LEGACY VERSIONS)
        WITio.class.wit('FreePolynom', double([0 1])) ... % (NOT IN ALL LEGACY VERSIONS) % [1 1] for null-transformation in MATLAB
        ]);
    
    Tag_DataClassName = WITio.class.wit('DataClassName 0', 'TDSpectralTransformation');
    Tag_Data = WITio.class.wit('Data 0');
    
    Tag_TData = WITio.class.wip.new_TData(Version, sprintf('New %s', Tag_DataClassName.Data));
    Tag_TDTransformation = WITio.class.wit('TDTransformation', [ ...
        WITio.class.wit('Version', int32(0)) ...
        WITio.class.wit('StandardUnit', '') ...
        WITio.class.wit('UnitKind', int32(0)) ...
        WITio.class.wit('InterpretationID', int32(0)) ... % (NOT IN ALL LEGACY VERSIONS)
        WITio.class.wit('IsCalibrated', true) ... % (NOT IN ALL LEGACY VERSIONS)
        ]);
    Tag_Data.Data = [Tag_TData Tag_TDTransformation Tag_Extra];
    
    % Append these to the given (or created) O_wit
    [~, Pair] = WITio.class.wip.append(O_wit, [Tag_DataClassName Tag_Data]);
    
    % Create new wid
    obj = WITio.class.wid(Pair);
end
