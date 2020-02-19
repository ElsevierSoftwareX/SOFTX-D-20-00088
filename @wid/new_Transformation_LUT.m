% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function obj = new_Transformation_LUT(O_wit, LUTSize),
    if nargin == 0 || isempty(O_wit), O_wit = wid.new(); end % Create O_wit
    if nargin < 2, LUTSize = 1600; end
    Version = wip.get_Root_Version(O_wit);
    
    % Coefficients that do not transform (in WITec Project 2.10.3.3)
    Tag_Extra = wit('TDLUTTransformation', [ ...
        wit('Version', int32(0)) ...
        wit('LUTSize', int32(LUTSize)) ...
        wit('LUT', double(1:LUTSize)) ...
        wit('LUTIsIncreasing', true) ...
        ]);
    
    Tag_DataClassName = wit('DataClassName 0', 'TDLUTTransformation');
    Tag_Data = wit('Data 0');
    
    Tag_TData = wip.new_TData(Version, sprintf('New %s', Tag_DataClassName.Data));
    if isempty(Version) || (Version >= 5 && Version <= 7),
        Tag_TDTransformation = wit('TDTransformation', [ ...
            wit('Version', int32(0)) ...
            wit('StandardUnit', '') ...
            wit('UnitKind', int32(0)) ...
            wit('InterpretationID', int32(0)) ...
            wit('IsCalibrated', true) ...
            ]);
    elseif Version >= 0 && Version < 5,
        Tag_TDTransformation = wit('TDTransformation', [ ...
            wit('Version', int32(0)) ...
            wit('StandardUnit', '') ...
            wit('UnitKind', int32(0)) ...
            ]);
    else, error('Unimplemented Version (%d)!', Version); end
    Tag_Data.Data = [Tag_TData Tag_TDTransformation Tag_Extra];
    
    % Append these to the given (or created) O_wit
    [~, Pair] = wip.append(O_wit, [Tag_DataClassName Tag_Data]);
    
    % Create new wid
    obj = wid(Pair(2));
end
