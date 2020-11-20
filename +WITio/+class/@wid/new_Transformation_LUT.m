% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function obj = new_Transformation_LUT(O_wit, LUTSize),
    if nargin == 0 || isempty(O_wit), O_wit = WITio.class.wid.new(); end % Create O_wit
    if nargin < 2, LUTSize = 1600; end
    Version = WITio.class.wip.get_Root_Version(O_wit);
    
    % Coefficients that do not transform (in WITec Project 2.10.3.3)
    Tag_Extra = WITio.class.wit('TDLUTTransformation', [ ...
        WITio.class.wit('Version', int32(0)) ...
        WITio.class.wit('LUTSize', int32(LUTSize)) ...
        WITio.class.wit('LUT', double(1:LUTSize)) ...
        WITio.class.wit('LUTIsIncreasing', true) ...
        ]);
    
    Tag_DataClassName = WITio.class.wit('DataClassName 0', 'TDLUTTransformation');
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
