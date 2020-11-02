% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function obj = new_Transformation_Linear(O_wit),
    if nargin == 0 || isempty(O_wit), O_wit = wid.new(); end % Create O_wit
    Version = wip.get_Root_Version(O_wit);
    
    % Coefficients that do not transform (in WITec Project 2.10.3.3)
    Tag_Extra = wit('TDLinearTransformation', [ ...
        wit('Version', int32(0)) ...
        wit('ModelOrigin_D', double(0)) ... % (NOT IN ALL LEGACY VERSIONS)
        wit('WorldOrigin_D', double(0)) ... % (NOT IN ALL LEGACY VERSIONS) % 1 for null-transformation in MATLAB
        wit('Scale_D', double(1)) ... % (NOT IN ALL LEGACY VERSIONS)
        wit('ModelOrigin', single(0)) ...
        wit('WorldOrigin', single(0)) ... % 1 for null-transformation in MATLAB
        wit('Scale', single(1)) ...
        ]);
    
    Tag_DataClassName = wit('DataClassName 0', 'TDLinearTransformation');
    Tag_Data = wit('Data 0');
    
    Tag_TData = wip.new_TData(Version, sprintf('New %s', Tag_DataClassName.Data));
    Tag_TDTransformation = wit('TDTransformation', [ ...
        wit('Version', int32(0)) ...
        wit('StandardUnit', '') ...
        wit('UnitKind', int32(0)) ...
        wit('InterpretationID', int32(0)) ... % (NOT IN ALL LEGACY VERSIONS)
        wit('IsCalibrated', true) ... % (NOT IN ALL LEGACY VERSIONS)
        ]);
    Tag_Data.Data = [Tag_TData Tag_TDTransformation Tag_Extra];
    
    % Append these to the given (or created) O_wit
    [~, Pair] = wip.append(O_wit, [Tag_DataClassName Tag_Data]);
    
    % Create new wid
    obj = wid(Pair);
end
