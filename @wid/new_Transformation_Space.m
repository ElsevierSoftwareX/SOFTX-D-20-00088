% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function obj = new_Transformation_Space(O_wit),
    if nargin == 0 || isempty(O_wit), O_wit = wid.new(); end % Create O_wit
    Version = wip.get_Root_Version(O_wit);
    
    % Coefficients that do not transform (in WITec Project 2.10.3.3)
    Tag_Extra = wit.io.wit('TDSpaceTransformation', [ ...
        wit.io.wit('Version', int32(0)) ...
        wit.io.wit('ViewPort3D', [ ...
            wit.io.wit('ModelOrigin', double([0 0 0])) ...
            wit.io.wit('WorldOrigin', double([0 0 0])) ... % [1 1 1] for null-transformation in MATLAB
            wit.io.wit('Scale', double(eye(3))) ...
            wit.io.wit('Rotation', double(eye(3))) ...
            ]) ...
        wit.io.wit('LineInformationValid', true) ...
        wit.io.wit('LineStart_D', double([0 0 0])) ... % (NOT IN ALL LEGACY VERSIONS) % 1st point == WorldOrigin<ViewPort3D
        wit.io.wit('LineStart', single([0 0 0])) ... % 1st point
        wit.io.wit('LineStop_D', double([1 1 1])) ... % (NOT IN ALL LEGACY VERSIONS) % N+1'th point
        wit.io.wit('LineStop', single([1 1 1])) ... % N+1'th point
        wit.io.wit('NumberOfLinePoints', int32(1)) ... % N points
        ]);
    
    Tag_DataClassName = wit.io.wit('DataClassName 0', 'TDSpaceTransformation');
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
