% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function obj = new_Text(O_wit),
    if nargin == 0 || isempty(O_wit), O_wit = wid.new(); end % Create O_wit
    Version = wit.io.wip.get_Root_Version(O_wit);
    
    Tag_DataClassName = wit.io.wit('DataClassName 0', 'TDText');
    Tag_Data = wit.io.wit('Data 0');
    
    Tag_TData = wit.io.wip.new_TData(Version, sprintf('New %s', Tag_DataClassName.Data));
    Tag_TDStream = wit.io.wit('TDStream', [ ...
        wit.io.wit('Version', int32(0)) ...
        wit.io.wit('StreamSize', int32(0)) ...
        wit.io.wit('StreamData', uint8.empty) ...
        ]);
    Tag_Data.Data = [Tag_TData Tag_TDStream];
    
    % Append these to the given (or created) O_wit
    [~, Pair] = wit.io.wip.append(O_wit, [Tag_DataClassName Tag_Data]);
    
    % Create new wid
    obj = wid(Pair);
end
