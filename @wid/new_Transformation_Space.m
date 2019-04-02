% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function obj = new_Transformation_Space(C_wit)
    if nargin == 0 || isempty(C_wit), C_wit = wid.new(); end % Create C_wit
    Version = wip.get_Root_Version(C_wit);
    
    % Coefficients that do not transform (in WITec Project 2.10.3.3)
    Tag_Extra = wit('TDSpaceTransformation', [ ...
        wit('Version', int32(0)) ...
        wit('ViewPort3D', [ ...
            wit('ModelOrigin', double([0 0 0])) ...
            wit('WorldOrigin', double([0 0 0])) ... % [1 1 1] for null-transformation in MATLAB
            wit('Scale', double(eye(3))) ...
            wit('Rotation', double(eye(3))) ...
            ]) ...
        wit('LineInformationValid', false) ... % Unimplemented
        wit('LineStart_D', double([0 0 0])) ... % Unimplemented
        wit('LineStart', single([0 0 0])) ... % Unimplemented
        wit('LineStop_D', double([0 0 0])) ... % Unimplemented
        wit('LineStop', single([0 0 0])) ... % Unimplemented
        wit('NumberOfLinePoints', int32(1)) ... % Unimplemented
        ]);
    
    Tag_DataClassName = wit('DataClassName 0', 'TDSpaceTransformation');
    Tag_Data = wit('Data 0');
    
    Tag_TData = wip.new_TData(Version, sprintf('New %s', Tag_DataClassName.Data));
    Tag_TDTransformation = wit('TDTransformation', [ ...
        wit('Version', int32(0)) ...
        wit('StandardUnit', '�m') ...
        wit('UnitKind', int32(1)) ... % WITec software requires 1 = um or 6 = 1/um
        wit('InterpretationID', int32(0)) ...
        wit('IsCalibrated', true) ...
        ]);
    Tag_Data.Data = [Tag_TData Tag_TDTransformation Tag_Extra];
    
    % Append these to the given (or created) C_wit
    [~, Pair] = wip.append(C_wit, [Tag_DataClassName Tag_Data]);
    
    % Create new wid
    obj = wid(Pair(2));
end
