% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function obj = new_Text(O_wit),
    if nargin == 0 || isempty(O_wit), O_wit = WITio.class.wid.new(); end % Create O_wit
    Version = WITio.class.wip.get_Root_Version(O_wit);
    
    Tag_DataClassName = WITio.class.wit('DataClassName 0', 'TDText');
    Tag_Data = WITio.class.wit('Data 0');
    
    Tag_TData = WITio.class.wip.new_TData(Version, sprintf('New %s', Tag_DataClassName.Data));
    Tag_TDStream = WITio.class.wit('TDStream', [ ...
        WITio.class.wit('Version', int32(0)) ...
        WITio.class.wit('StreamSize', int32(0)) ...
        WITio.class.wit('StreamData', uint8.empty) ...
        ]);
    Tag_Data.Data = [Tag_TData Tag_TDStream];
    
    % Append these to the given (or created) O_wit
    [~, Pair] = WITio.class.wip.append(O_wit, [Tag_DataClassName Tag_Data]);
    
    % Create new wid
    obj = WITio.class.wid(Pair);
end
