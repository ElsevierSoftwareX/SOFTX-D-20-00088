% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function obj = new_Transformation_Spectral(O_wit),
    if nargin == 0 || isempty(O_wit), O_wit = WITio.obj.wid.new(); end % Create O_wit
    Version = WITio.obj.wip.get_Root_Version(O_wit);
    
    % Coefficients that do not (asymptotically) transform (in WITec Project 2.10.3.3)
    Tag_Extra = WITio.obj.wit('TDSpectralTransformation', [ ...
        WITio.obj.wit('Version', int32(0)) ...
        WITio.obj.wit('SpectralTransformationType', int32(1)) ... % 0 if Polynom-transformation
        WITio.obj.wit('Polynom', double([0 1 0])) ... % [1 1 0] for null-transformation in MATLAB
        WITio.obj.wit('nC', double(0)) ... % -1 for null-transformation in MATLAB
        WITio.obj.wit('LambdaC', double(0)) ...
        WITio.obj.wit('Gamma', double(0)) ...
        WITio.obj.wit('Delta', double(0)) ...
        WITio.obj.wit('m', double(1)) ...
        WITio.obj.wit('d', double(realmax('double'))) ...
        WITio.obj.wit('x', double(1)) ...
        WITio.obj.wit('f', double(realmax('double'))) ...
        WITio.obj.wit('FreePolynomOrder', double(1)) ... % (NOT IN ALL LEGACY VERSIONS)
        WITio.obj.wit('FreePolynomStartBin', double(0)) ... % (NOT IN ALL LEGACY VERSIONS)
        WITio.obj.wit('FreePolynomStopBin', double(realmax('double'))) ... % (NOT IN ALL LEGACY VERSIONS)
        WITio.obj.wit('FreePolynom', double([0 1])) ... % (NOT IN ALL LEGACY VERSIONS) % [1 1] for null-transformation in MATLAB
        ]);
    
    Tag_DataClassName = WITio.obj.wit('DataClassName 0', 'TDSpectralTransformation');
    Tag_Data = WITio.obj.wit('Data 0');
    
    Tag_TData = WITio.obj.wip.new_TData(Version, sprintf('New %s', Tag_DataClassName.Data));
    Tag_TDTransformation = WITio.obj.wit('TDTransformation', [ ...
        WITio.obj.wit('Version', int32(0)) ...
        WITio.obj.wit('StandardUnit', '') ...
        WITio.obj.wit('UnitKind', int32(0)) ...
        WITio.obj.wit('InterpretationID', int32(0)) ... % (NOT IN ALL LEGACY VERSIONS)
        WITio.obj.wit('IsCalibrated', true) ... % (NOT IN ALL LEGACY VERSIONS)
        ]);
    Tag_Data.Data = [Tag_TData Tag_TDTransformation Tag_Extra];
    
    % Append these to the given (or created) O_wit
    [~, Pair] = WITio.obj.wip.append(O_wit, [Tag_DataClassName Tag_Data]);
    
    % Create new wid
    obj = WITio.obj.wid(Pair);
end
