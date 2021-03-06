% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function obj = new_Transformation_Space(O_wit),
    if nargin == 0 || isempty(O_wit), O_wit = WITio.obj.wid.new(); end % Create O_wit
    Version = WITio.obj.wip.get_Root_Version(O_wit);
    
    % Coefficients that do not transform (in WITec Project 2.10.3.3)
    Tag_Extra = WITio.obj.wit('TDSpaceTransformation', [ ...
        WITio.obj.wit('Version', int32(0)) ...
        WITio.obj.wit('ViewPort3D', [ ...
            WITio.obj.wit('ModelOrigin', double([0 0 0])) ...
            WITio.obj.wit('WorldOrigin', double([0 0 0])) ... % [1 1 1] for null-transformation in MATLAB
            WITio.obj.wit('Scale', double(eye(3))) ...
            WITio.obj.wit('Rotation', double(eye(3))) ...
            ]) ...
        WITio.obj.wit('LineInformationValid', true) ...
        WITio.obj.wit('LineStart_D', double([0 0 0])) ... % (NOT IN ALL LEGACY VERSIONS) % 1st point == WorldOrigin<ViewPort3D
        WITio.obj.wit('LineStart', single([0 0 0])) ... % 1st point
        WITio.obj.wit('LineStop_D', double([1 1 1])) ... % (NOT IN ALL LEGACY VERSIONS) % N+1'th point
        WITio.obj.wit('LineStop', single([1 1 1])) ... % N+1'th point
        WITio.obj.wit('NumberOfLinePoints', int32(1)) ... % N points
        ]);
    
    Tag_DataClassName = WITio.obj.wit('DataClassName 0', 'TDSpaceTransformation');
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
