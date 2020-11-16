% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function obj = new_Bitmap(O_wit),
    if nargin == 0 || isempty(O_wit), O_wit = wid.new(); end % Create O_wit
    Version = wit.io.wip.get_Root_Version(O_wit);
    
    Tag_DataClassName = wit.io.wit('DataClassName 0', 'TDBitmap');
    Tag_Data = wit.io.wit('Data 0');
    
    Tag_TData = wit.io.wip.new_TData(Version, sprintf('New %s', Tag_DataClassName.Data));
    if isempty(Version) || Version == 7,
        Tag_TDBitmap = wit.io.wit('TDBitmap', [ ...
            wit.io.wit('Version', int32(1)) ...
            wit.io.wit('SizeX', int32(0)) wit.io.wit('SizeY', int32(0)) ...
            wit.io.wit('SpaceTransformationID', int32(0)) ...
            wit.io.wit('SecondaryTransformationID', int32(0)) ...
            wit.io.wit('BitmapData', [wit.io.wit('Dimension', int32(2)) wit.io.wit('DataType', int32(10)) wit.io.wit('Ranges', int32([0 0])) wit.io.wit('Data', uint8.empty)]) ... % Empty cannot be opened in WITec Project 2.10.3.3
            ]);
        Tag_Data.Data = [Tag_TData Tag_TDBitmap];
    elseif Version == 6,
        Tag_TDBitmap = wit.io.wit('TDBitmap', [ ...
            wit.io.wit('Version', int32(1)) ...
            wit.io.wit('SizeX', int32(0)) wit.io.wit('SizeY', int32(0)) ...
            wit.io.wit('SpaceTransformationID', int32(0)) ...
            wit.io.wit('BitmapData', [wit.io.wit('Dimension', int32(2)) wit.io.wit('DataType', int32(10)) wit.io.wit('Ranges', int32([0 0])) wit.io.wit('Data', uint8.empty)]) ... % Empty cannot be opened in WITec Project 2.10.3.3
            ]);
        Tag_Data.Data = [Tag_TData Tag_TDBitmap];
    elseif Version >= 0 && Version <= 5, % Legacy versions
        Tag_TDStream = wit.io.wit('TDStream', [ ...
            wit.io.wit('Version', int32(0)) ...
            wit.io.wit('StreamSize', int32(0)) ...
            wit.io.wit('StreamData', uint8.empty) ... % Empty cannot be opened in WITec Project 2.10.3.3
            ]);
        Tag_TDBitmap = wit.io.wit('TDBitmap', [ ...
            wit.io.wit('Version', int32(0)) ...
            wit.io.wit('SpaceTransformationID', int32(0)) ...
            ]);
        Tag_Data.Data = [Tag_TData Tag_TDStream Tag_TDBitmap];
    else, error('Unimplemented Version (%d)!', Version); end
    
    % Append these to the given (or created) O_wit
    [~, Pair] = wit.io.wip.append(O_wit, [Tag_DataClassName Tag_Data]);
    
    % Create new wid
    obj = wid(Pair);
end
