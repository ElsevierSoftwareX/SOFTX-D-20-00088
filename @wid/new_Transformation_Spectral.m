% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function obj = new_Transformation_Spectral(O_wit),
    if nargin == 0 || isempty(O_wit), O_wit = wid.new(); end % Create O_wit
    Version = wip.get_Root_Version(O_wit);
    
    % Coefficients that do not (asymptotically) transform (in WITec Project 2.10.3.3)
    Tag_Extra = wit.io.wit('TDSpectralTransformation', [ ...
        wit.io.wit('Version', int32(0)) ...
        wit.io.wit('SpectralTransformationType', int32(1)) ... % 0 if Polynom-transformation
        wit.io.wit('Polynom', double([0 1 0])) ... % [1 1 0] for null-transformation in MATLAB
        wit.io.wit('nC', double(0)) ... % -1 for null-transformation in MATLAB
        wit.io.wit('LambdaC', double(0)) ...
        wit.io.wit('Gamma', double(0)) ...
        wit.io.wit('Delta', double(0)) ...
        wit.io.wit('m', double(1)) ...
        wit.io.wit('d', double(realmax('double'))) ...
        wit.io.wit('x', double(1)) ...
        wit.io.wit('f', double(realmax('double'))) ...
        wit.io.wit('FreePolynomOrder', double(1)) ... % (NOT IN ALL LEGACY VERSIONS)
        wit.io.wit('FreePolynomStartBin', double(0)) ... % (NOT IN ALL LEGACY VERSIONS)
        wit.io.wit('FreePolynomStopBin', double(realmax('double'))) ... % (NOT IN ALL LEGACY VERSIONS)
        wit.io.wit('FreePolynom', double([0 1])) ... % (NOT IN ALL LEGACY VERSIONS) % [1 1] for null-transformation in MATLAB
        ]);
    
    Tag_DataClassName = wit.io.wit('DataClassName 0', 'TDSpectralTransformation');
    Tag_Data = wit.io.wit('Data 0');
    
    Tag_TData = wip.new_TData(Version, sprintf('New %s', Tag_DataClassName.Data));
    Tag_TDTransformation = wit.io.wit('TDTransformation', [ ...
        wit.io.wit('Version', int32(0)) ...
        wit.io.wit('StandardUnit', '') ...
        wit.io.wit('UnitKind', int32(0)) ...
        wit.io.wit('InterpretationID', int32(0)) ... % (NOT IN ALL LEGACY VERSIONS)
        wit.io.wit('IsCalibrated', true) ... % (NOT IN ALL LEGACY VERSIONS)
        ]);
    Tag_Data.Data = [Tag_TData Tag_TDTransformation Tag_Extra];
    
    % Append these to the given (or created) O_wit
    [~, Pair] = wip.append(O_wit, [Tag_DataClassName Tag_Data]);
    
    % Create new wid
    obj = wid(Pair);
end
