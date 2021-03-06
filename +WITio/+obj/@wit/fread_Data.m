% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function fread_Data(obj, fid, N_bytes_max, swapEndianess), %#ok
    % Reads a WIT-formatted tag data from the given file stream.
    % Reading can be limited by N_bytes_max (if low on memory).
    if nargin < 3, N_bytes_max = Inf; end % Default: no read limit!
    if nargin < 4 || isempty(swapEndianess), swapEndianess = WITio.obj.wit.swap_endianess(); end % By default: Binary with little endianess

    % Test if the file stream exists or abort
    if isempty(fid) || fid == -1, return; end

    % Test if Type is not 0 or abort
    if obj.Type == 0, return; end

    % Go to starting location of read
    fseek(fid, double(obj.Start), 'bof'); % Double OFFSET for compability!

    % Abort, if file stream has reached the end
    if feof(fid), return; end

    % Calculate Length (byte length of data)
    Length = double(obj.End-obj.Start); % Double OFFSET for compability!

    % Skip, if upper read limit is reached.
    if Length > N_bytes_max, %#ok
        obj.File = obj.File; % Save the parent filename for the later
        fseek(fid, double(obj.End), 'bof'); % Double OFFSET for compability!
        return;
    end

    % Read data within [Start, End] in uint8 format
    Data = reshape(fread(fid, Length, 'uint8=>uint8', 0, 'l'), 1, []); % Row vector

    % Convert the read data to proper type specified by Type
    if swapEndianess, %#ok % Swap endianess using built-in flipud and reshape
        switch(obj.Type), %#ok
            case 2, %#ok % Double (8 bytes)
                if mod(Length, 8) == 0, Data = typecast(reshape(flipud(reshape(Data, 8, [])), 1, []), 'double'); % Convert only if proper byte length
                else, warning(warning_msg(), 'double'); end
            case 3, %#ok % Float (4 bytes)
                if mod(Length, 4) == 0, Data = typecast(reshape(flipud(reshape(Data, 4, [])), 1, []), 'single'); % Convert only if proper byte length
                else, warning(warning_msg(), 'single'); end
            case 4, %#ok % Int64 (8 bytes)
                if mod(Length, 8) == 0, Data = typecast(reshape(flipud(reshape(Data, 8, [])), 1, []), 'int64'); % Convert only if proper byte length
                else, warning(warning_msg(), 'int64'); end
            case 5, %#ok % Int32 (4 bytes)
                if mod(Length, 4) == 0, Data = typecast(reshape(flipud(reshape(Data, 4, [])), 1, []), 'int32'); % Convert only if proper byte length
                else, warning(warning_msg(), 'int32'); end
            case 6, %#ok % Uint32 (4 bytes) % SPECIAL CASE: Uint16 for 'Dates'-tag (2 bytes)
                if mod(Length, 4) == 0, Data = typecast(reshape(flipud(reshape(Data, 4, [])), 1, []), 'uint32'); %#ok % Convert only if proper byte length
                elseif mod(Length, 2) == 0, Data = typecast(reshape(flipud(reshape(Data, 2, [])), 1, []), 'uint16'); % SPECIAL CASE: for 'Dates'-tag
                else, warning(warning_msg(), 'uint32 or uint16'); end
            case 7, %#ok % Uint8 (1 byte)
                Data = uint8(Data);
            case 8, %#ok % Bool (1 byte)
                Data = cast(Data, 'logical'); % Cast instead of logical for compability!
            case 9, %#ok % NameLength (4 bytes) + String (NameLength # of bytes)
                strs = {''};
                N_strs = 0;
                subind_begin = uint32(1);
                while subind_begin < numel(Data), %#ok
                    N_strs = N_strs + 1; % Set number of strings
                    subind_end = subind_begin-1 + 4;
                    str_len = typecast(Data(subind_begin:subind_end), 'uint32');
                    subind_begin = subind_end + 1; % Set next begin index
                    subind_end = subind_begin-1 + str_len;
                    strs{1,N_strs} = char(Data(subind_begin:subind_end));
                    subind_begin = subind_end + 1; % Set next begin index
                end
                if numel(strs) == 1, Data = strs{1};
                else, Data = strs; end
            otherwise, %#ok
                warning('Tag(%s): Unsupported Type (%d)!', obj.FullName, obj.Type);
        end
    else, %#ok
        switch(obj.Type), %#ok
            case 2, %#ok % Double (8 bytes)
                if mod(Length, 8) == 0, Data = typecast(Data, 'double'); % Convert only if proper byte length
                else, warning(warning_msg(), 'double'); end
            case 3, %#ok % Float (4 bytes)
                if mod(Length, 4) == 0, Data = typecast(Data, 'single'); % Convert only if proper byte length
                else, warning(warning_msg(), 'single'); end
            case 4, %#ok % Int64 (8 bytes)
                if mod(Length, 8) == 0, Data = typecast(Data, 'int64'); % Convert only if proper byte length
                else, warning(warning_msg(), 'int64'); end
            case 5, %#ok % Int32 (4 bytes)
                if mod(Length, 4) == 0, Data = typecast(Data, 'int32'); % Convert only if proper byte length
                else, warning(warning_msg(), 'int32'); end
            case 6, %#ok % Uint32 (4 bytes) % SPECIAL CASE: Uint16 for 'Dates'-tag (2 bytes)
                if mod(Length, 4) == 0, Data = typecast(Data, 'uint32'); %#ok % Convert only if proper byte length
                elseif mod(Length, 2) == 0, Data = typecast(Data, 'uint16'); % SPECIAL CASE: for 'Dates'-tag
                else, warning(warning_msg(), 'uint32 or uint16'); end
            case 7, %#ok % Uint8 (1 byte)
                Data = uint8(Data);
            case 8, %#ok % Bool (1 byte)
                Data = cast(Data, 'logical'); % Cast instead of logical for compability!
            case 9, %#ok % NameLength (4 bytes) + String (NameLength # of bytes)
                strs = {''};
                N_strs = 0;
                subind_begin = uint32(1);
                while subind_begin < numel(Data), %#ok
                    N_strs = N_strs + 1; % Set number of strings
                    subind_end = subind_begin-1 + 4;
                    str_len = typecast(Data(subind_begin:subind_end), 'uint32');
                    subind_begin = subind_end + 1; % Set next begin index
                    subind_end = subind_begin-1 + str_len;
                    strs{1,N_strs} = char(Data(subind_begin:subind_end));
                    subind_begin = subind_end + 1; % Set next begin index
                end
                if numel(strs) == 1, Data = strs{1};
                else, Data = strs; end
            otherwise, %#ok
                warning('Tag(%s): Unsupported Type (%d)!', obj.FullName, obj.Type);
        end
    end
    
    obj.DataNow = Data; % Minimized expensive calls to set.Data (and get.Data)
    obj.ChildrenNow = obj([]); % Faster than WITio.obj.wit.empty
    
    % Implemented an inner function to avoid EXPENSIVE calls to sprintf.
    function str = warning_msg(), %#ok
        str = sprintf('Tag(%s): Data inconsistent with Type (%%s)!', obj.FullName); % Warning message
    end
end
