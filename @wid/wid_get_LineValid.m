% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function Data = wid_get_LineValid(obj, Data)
    LineValid = obj.Tag.Data.regexp('^LineValid<', true).Data;
    if sum(~LineValid) > 0 && ~islogical(Data),
        if ~isa(Data, 'double') && ~isa(Data, 'single'),
            if numel(typecast(Data(1), 'uint8')) >= 3, Data = double(Data); % Convert to double (100% precise for 52-bit integers) if needed
            else, Data = single(Data); end % Convert to single (100% precise for 23-bit integers) if needed
        end
        Data(~repmat(LineValid(:).', [size(Data, 1) 1 size(Data, 3) size(Data, 4)])) = NaN; % Assign NaNs
    end
end
