% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function Data = wid_get_DataType(obj, Data)
    % Assuming that the given data is binary stream in uint8 format!
    Data = Data(:); % Force vector!
    DataType = obj.Tag.Data.regexp('^DataType<', true).Data;
    % Supported DataTypes: 1. Int64 (8 bytes), 2. Int32 (4 bytes),
    % 3. Int16 (2 bytes), 4. Int8 (1 byte), 5. Uint32 (4 bytes),
    % 6. Uint16 (2 bytes), 7. Uint8 (1 byte), 8. Bool (1 byte),
    % 9. Float (4 bytes), 10. Double (8 bytes)
    supported_classes = {'int64', 'int32', 'int16', 'int8', 'uint32', ...
        'uint16', 'uint8', 'logical', 'single', 'double'};
    if DataType == 0 || DataType > 10, error('Unsupported Datatype!');
    elseif DataType == 8, Data = cast(Data, 'logical'); % Special case: Bool % Cast instead of logical for compability!
    else, Data = typecast(Data, supported_classes{DataType}); end
end
