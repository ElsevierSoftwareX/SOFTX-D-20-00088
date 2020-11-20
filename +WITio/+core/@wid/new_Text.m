% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function obj = new_Text(O_wit),
    if nargin == 0 || isempty(O_wit), O_wit = WITio.core.wid.new(); end % Create O_wit
    Version = WITio.core.wip.get_Root_Version(O_wit);
    
    Tag_DataClassName = WITio.core.wit('DataClassName 0', 'TDText');
    Tag_Data = WITio.core.wit('Data 0');
    
    Tag_TData = WITio.core.wip.new_TData(Version, sprintf('New %s', Tag_DataClassName.Data));
    Tag_TDStream = WITio.core.wit('TDStream', [ ...
        WITio.core.wit('Version', int32(0)) ...
        WITio.core.wit('StreamSize', int32(0)) ...
        WITio.core.wit('StreamData', uint8.empty) ...
        ]);
    Tag_Data.Data = [Tag_TData Tag_TDStream];
    
    % Append these to the given (or created) O_wit
    [~, Pair] = WITio.core.wip.append(O_wit, [Tag_DataClassName Tag_Data]);
    
    % Create new wid
    obj = WITio.core.wid(Pair);
end
