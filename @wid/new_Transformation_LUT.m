% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function obj = new_Transformation_LUT(O_wit, LUTSize),
    if nargin == 0 || isempty(O_wit), O_wit = wid.new(); end % Create O_wit
    if nargin < 2, LUTSize = 1600; end
    Version = wit.io.wip.get_Root_Version(O_wit);
    
    % Coefficients that do not transform (in WITec Project 2.10.3.3)
    Tag_Extra = wit.io.wit('TDLUTTransformation', [ ...
        wit.io.wit('Version', int32(0)) ...
        wit.io.wit('LUTSize', int32(LUTSize)) ...
        wit.io.wit('LUT', double(1:LUTSize)) ...
        wit.io.wit('LUTIsIncreasing', true) ...
        ]);
    
    Tag_DataClassName = wit.io.wit('DataClassName 0', 'TDLUTTransformation');
    Tag_Data = wit.io.wit('Data 0');
    
    Tag_TData = wit.io.wip.new_TData(Version, sprintf('New %s', Tag_DataClassName.Data));
    Tag_TDTransformation = wit.io.wit('TDTransformation', [ ...
        wit.io.wit('Version', int32(0)) ...
        wit.io.wit('StandardUnit', '') ...
        wit.io.wit('UnitKind', int32(0)) ...
        wit.io.wit('InterpretationID', int32(0)) ... % (NOT IN ALL LEGACY VERSIONS)
        wit.io.wit('IsCalibrated', true) ... % (NOT IN ALL LEGACY VERSIONS)
        ]);
    Tag_Data.Data = [Tag_TData Tag_TDTransformation Tag_Extra];
    
    % Append these to the given (or created) O_wit
    [~, Pair] = wit.io.wip.append(O_wit, [Tag_DataClassName Tag_Data]);
    
    % Create new wid
    obj = wid(Pair);
end
