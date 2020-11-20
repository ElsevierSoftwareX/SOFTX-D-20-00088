% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function Data = wid_Data_set_DataType(obj, Data),
    Data = Data(:); % Force vector!
    % Supported DataTypes: 1. Int64 (8 bytes), 2. Int32 (4 bytes),
    % 3. Int16 (2 bytes), 4. Int8 (1 byte), 5. Uint32 (4 bytes),
    % 6. Uint16 (2 bytes), 7. Uint8 (1 byte), 8. Bool (1 byte),
    % 9. Float (4 bytes), 10. Double (8 bytes)
    supported_classes = {'int64', 'int32', 'int16', 'int8', 'uint32', ...
        'uint16', 'uint8', 'logical', 'single', 'double'};
    DataType = find(strcmp(class(Data), supported_classes), 1);
    if isempty(DataType), error('Unsupported Datatype!');
    elseif DataType == 8, Data = uint8(Data); % DataType 8 is special case used for boolean maps in WITec Project 2.10.3.3 but surprisingly could also contain other uint8 values than 0 and 1.
    else, Data = typecast(Data, 'uint8'); end
    obj.Tag.Data.regexp('^DataType<', true).Data = int32(DataType); % int32 required by WITec Project 2.10.3.3
end
