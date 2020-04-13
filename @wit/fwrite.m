% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% USE THIS ONLY IF LOW-ON MEMORY OR WHEN WRITING HUGE FILES!
function fwrite(obj, fid, swapEndianess, fun_progress, update),
    if nargin < 3, swapEndianess = false; end % By default: Write without swapping endianess
    if nargin < 4, fun_progress = []; end % By default: no progress function
    if nargin < 5 || update, obj.update(); end % By default: update wit Tree object
    
    % Test the file stream
    if isempty(fid) || fid == -1, error('File stream is not open!'); end

    % Get number of bytes
    N_magic = 8.*isempty(obj.Parent);
    N_header = N_magic + 4 + 1.*double(obj.NameLength) + 4 + 8 + 8;
    N_buffer = N_header;
    
    % Preallocate
    buffer = zeros(N_buffer, 1, 'uint8');
    ind_begin = 1;

    % Write Magic string if root
    if isempty(obj.Parent),
        ind_end = ind_begin-1 + 8;
        Magic = obj.Magic;
        if ~isempty(Magic),
            uint8_array = uint8(obj.Magic); % String is a char row vector
            buffer(ind_begin:ind_end) = uint8_array;
        end
        ind_begin = ind_end + 1; % Set next begin index
    end
    
    % Write NameLength (4 bytes)
    ind_end = ind_begin-1 + 4;
    if ~swapEndianess, uint8_array = typecast(obj.NameLength, 'uint8');
    else, uint8_array = fliplr(typecast(obj.NameLength, 'uint8')); end
    buffer(ind_begin:ind_end) = uint8_array;
    ind_begin = ind_end + 1; % Set next begin index
    
    % Write Name (NameLength # of bytes)
    ind_end = ind_begin-1 + double(obj.NameLength);
    uint8_array = uint8(obj.Name); % String is a char row vector
    buffer(ind_begin:ind_end) = uint8_array;
    ind_begin = ind_end + 1; % Set next begin index
    
    % Write Type (4 bytes)
    ind_end = ind_begin-1 + 4;
    if ~swapEndianess, uint8_array = typecast(obj.Type, 'uint8');
    else, uint8_array = fliplr(typecast(obj.Type, 'uint8')); end
    buffer(ind_begin:ind_end) = uint8_array;
    ind_begin = ind_end + 1; % Set next begin index
    
    % Write Start (8 bytes)
    ind_end = ind_begin-1 + 8;
    if ~swapEndianess, uint8_array = typecast(obj.Start, 'uint8');
    else, uint8_array = fliplr(typecast(obj.Start, 'uint8')); end
    buffer(ind_begin:ind_end) = uint8_array;
    ind_begin = ind_end + 1; % Set next begin index
    
    if isa(fun_progress, 'function_handle'),
        fun_progress(obj.Start);
    end
    
    % Write End (8 bytes)
    ind_end = ind_begin-1 + 8;
    if ~swapEndianess, uint8_array = typecast(obj.End, 'uint8');
    else, uint8_array = fliplr(typecast(obj.End, 'uint8')); end
    buffer(ind_begin:ind_end) = uint8_array;
    
    fwrite(fid, buffer, 'uint8', 0, 'l');

    % Write Data
    if ~isempty(obj.Data),
        % Convert the data to proper type specified by Type before writing
        switch(obj.Type),
            case 0, % List of Tags
                for ii = 1:numel(obj.Data),
                    obj.Data(ii).fwrite(fid, swapEndianess, fun_progress, false);
                end
            case 2, % Double (8 bytes)
                fwrite(fid, obj.Data, 'double', 0, 'l');
            case 3, % Float (4 bytes)
                fwrite(fid, obj.Data, 'single', 0, 'l');
            case 4, % Int64 (8 bytes)
                fwrite(fid, obj.Data, 'int64', 0, 'l');
            case 5, % Int32 (4 bytes)
                fwrite(fid, obj.Data, 'int32', 0, 'l');
            case 6, % Uint32 (4 bytes) % SPECIAL CASE: Uint16 for 'Dates'-tag (2 bytes)
                if isa(obj.Data, 'uint32'), fwrite(fid, obj.Data, 'uint32', 0, 'l');
                else, fwrite(fid, obj.Data, 'uint16', 0, 'l'); end % SPECIAL CASE: for 'Dates'-tag
            case 7, % Char (1 byte)
                fwrite(fid, obj.Data, 'uint8', 0, 'l');
            case 8, % Bool (1 byte)
                fwrite(fid, obj.Data, 'uint8', 0, 'l');
            case 9, % NameLength (4 bytes) + String (NameLength # of bytes)
                fwrite(fid, numel(obj.Data), 'uint32', 0, 'l');
                fwrite(fid, obj.Data, 'uint8', 0, 'l');
            otherwise,
                old_state = warning('query', 'backtrace'); % Store warning state
                warning off backtrace; % Disable the stack trace
                warning('Tag(%s): Unsupported Type (%d)!', obj.FullName, obj.Type);
                warning(old_state); % Restore warning state
        end
    end
end
