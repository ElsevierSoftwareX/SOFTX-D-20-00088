% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function obj = new_Transformation_LUT(O_wit, LUTSize),
    if nargin == 0 || isempty(O_wit), O_wit = WITio.obj.wid.new(); end % Create O_wit
    if nargin < 2, LUTSize = 1600; end
    Version = WITio.obj.wip.get_Root_Version(O_wit);
    
    % Coefficients that do not transform (in WITec Project 2.10.3.3)
    Tag_Extra = WITio.obj.wit('TDLUTTransformation', [ ...
        WITio.obj.wit('Version', int32(0)) ...
        WITio.obj.wit('LUTSize', int32(LUTSize)) ...
        WITio.obj.wit('LUT', double(1:LUTSize)) ...
        WITio.obj.wit('LUTIsIncreasing', true) ...
        ]);
    
    Tag_DataClassName = WITio.obj.wit('DataClassName 0', 'TDLUTTransformation');
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
