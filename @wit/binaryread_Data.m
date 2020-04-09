% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function ind_begin = binaryread_Data(obj, buffer, N_bytes_max, swapEndianess),
    % Reads a WIT-formatted tag data from the given file stream.
    % Reading can be limited by N_bytes_max (if low on memory).
    if nargin < 3, N_bytes_max = Inf; end % Default: no read limit!
    if nargin < 4, swapEndianess = false; end % By default: Read without swapping endianess

    % Test the data stream
    if isempty(buffer), return; end
    ind_max = numel(buffer);

    % Test if Type is not 0 or abort
    if obj.Type == 0, return; end

    % Go to starting location of read
    ind_begin = double(obj.Start)+1; % Double OFFSET for compability!

    % Calculate Length (byte length of data)
    Length = double(obj.End-obj.Start); % Double OFFSET for compability!
    ind_end = ind_begin-1 + Length;

    % Abort, if the end is reached
    if ind_end > ind_max, return; end

    % Skip, if upper read limit is reached.
    if Length > N_bytes_max,
        obj.File = obj.File; % Save the parent filename for the later
        ind_begin = double(obj.End)+1; % Double OFFSET for compability!
        return;
    end

    % Read data within [Start, End] in uint8 format
    Data = reshape(buffer(ind_begin:ind_end), 1, []); % Row vector
    
    % Convert the read data to proper type specified by Type
    old_state = warning('query', 'backtrace'); % Store warning state
    warning off backtrace; % Disable the stack trace
    if swapEndianess, % Swap endianess using built-in flipud and reshape
        switch(obj.Type),
            case 2, % Double (8 bytes)
                if mod(Length, 8) == 0, Data = typecast(reshape(flipud(reshape(Data, 8, [])), 1, []), 'double'); % Convert only if proper byte length
                else, warning(warning_msg(), 'double'); end
            case 3, % Float (4 bytes)
                if mod(Length, 4) == 0, Data = typecast(reshape(flipud(reshape(Data, 4, [])), 1, []), 'single'); % Convert only if proper byte length
                else, warning(warning_msg(), 'single'); end
            case 4, % Int64 (8 bytes)
                if mod(Length, 8) == 0, Data = typecast(reshape(flipud(reshape(Data, 8, [])), 1, []), 'int64'); % Convert only if proper byte length
                else, warning(warning_msg(), 'int64'); end
            case 5, % Int32 (4 bytes)
                if mod(Length, 4) == 0, Data = typecast(reshape(flipud(reshape(Data, 4, [])), 1, []), 'int32'); % Convert only if proper byte length
                else, warning(warning_msg(), 'int32'); end
            case 6, % Uint32 (4 bytes) % SPECIAL CASE: Uint16 for 'Dates'-tag (2 bytes)
                if mod(Length, 4) == 0, Data = typecast(reshape(flipud(reshape(Data, 4, [])), 1, []), 'uint32'); % Convert only if proper byte length
                elseif mod(Length, 2) == 0, Data = typecast(reshape(flipud(reshape(Data, 2, [])), 1, []), 'uint16'); % SPECIAL CASE: for 'Dates'-tag
                else, warning(warning_msg(), 'uint32 or uint16'); end
            case 7, % Uint8 (1 byte)
                Data = uint8(Data);
            case 8, % Bool (1 byte)
                Data = cast(Data, 'logical'); % Cast instead of logical for compability!
            case 9, % NameLength (4 bytes) + String (NameLength # of bytes)
                % Length = typecast(Data(4:-1:1), 'uint32');
                Data = char(Data(5:end));
            otherwise,
                warning('Tag(%s): Unsupported Type (%d)!', obj.FullName, obj.Type);
        end
    else,
        switch(obj.Type),
            case 2, % Double (8 bytes)
                if mod(Length, 8) == 0, Data = typecast(Data, 'double'); % Convert only if proper byte length
                else, warning(warning_msg(), 'double'); end
            case 3, % Float (4 bytes)
                if mod(Length, 4) == 0, Data = typecast(Data, 'single'); % Convert only if proper byte length
                else, warning(warning_msg(), 'single'); end
            case 4, % Int64 (8 bytes)
                if mod(Length, 8) == 0, Data = typecast(Data, 'int64'); % Convert only if proper byte length
                else, warning(warning_msg(), 'int64'); end
            case 5, % Int32 (4 bytes)
                if mod(Length, 4) == 0, Data = typecast(Data, 'int32'); % Convert only if proper byte length
                else, warning(warning_msg(), 'int32'); end
            case 6, % Uint32 (4 bytes) % SPECIAL CASE: Uint16 for 'Dates'-tag (2 bytes)
                if mod(Length, 4) == 0, Data = typecast(Data, 'uint32'); % Convert only if proper byte length
                elseif mod(Length, 2) == 0, Data = typecast(Data, 'uint16'); % SPECIAL CASE: for 'Dates'-tag
                else, warning(warning_msg(), 'uint32 or uint16'); end
            case 7, % Uint8 (1 byte)
                Data = uint8(Data);
            case 8, % Bool (1 byte)
                Data = cast(Data, 'logical'); % Cast instead of logical for compability!
            case 9, % NameLength (4 bytes) + String (NameLength # of bytes)
                % Length = typecast(Data(1:4), 'uint32');
                Data = char(Data(5:end));
            otherwise,
                warning('Tag(%s): Unsupported Type (%d)!', obj.FullName, obj.Type);
        end
    end
    warning(old_state); % Restore warning state
    
    obj.skipRedundant = true; % Speed-up set.Data!
    obj.Data = Data; % Minimized expensive calls to set.Data (and get.Data)
    ind_begin = ind_end + 1; % Set next begin index
    
    % Implemented an inner function to avoid EXPENSIVE calls to sprintf.
    function str = warning_msg(),
        str = sprintf('Tag(%s): Data inconsistent with Type (%%s)!', obj.FullName); % Warning message
    end
end
