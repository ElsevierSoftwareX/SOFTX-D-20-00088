% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function was implemented to provide CONSIDERABLE SPEED-UP when
% writing to file, because we can call EXPENSIVE fwrite only once. Due to
% variations between PC's, this allows swapping endianess. As far as the
% author knows, the WIT-formatted files are always LITTLE-ENDIAN ORDERED.
function buffer = binary(obj, swapEndianess, fun_progress),
    if nargin < 2, swapEndianess = false; end % By default: Binary without swapping endianess
    if nargin < 3, fun_progress = []; end % By default: no progress function
    
    % Before PREALLOCATIONS, call itself for Type=0 Data and store buffers.
    % In other words, begin this call from the ends of the tree branches.
    % This is done to avoid huge memory requirements.
    if ~isempty(obj.Data) && obj.Type == 0,
        buffer_Data = cell(numel(obj.Data), 1);
        for ii = 1:numel(obj.Data),
            buffer_Data{ii} = obj.Data(ii).binary(swapEndianess, fun_progress);
        end
    end
    
    % Get number of bytes
    N_magic = 8.*isempty(obj.Parent);
    N_header = N_magic + 4 + 1.*double(obj.NameLength) + 4 + 8 + 8;
    N_data = double(obj.End-obj.Start);
    N_buffer = N_header + N_data;
    
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
    ind_begin = ind_end + 1; % Set next begin index
    
    % Write Data
    if ~isempty(obj.Data),
        ind_end = ind_begin-1 + N_data;
        % Convert the data to proper type specified by Type before writing
        switch(obj.Type),
            case 0, % List of Tags
                uint8_array = cat(1, buffer_Data{:});
            case 2, % Double (8 bytes)
                if ~swapEndianess, uint8_array = typecast(obj.Data(:), 'uint8');
                else, uint8_array = flipud(reshape(typecast(obj.Data(:), 'uint8'), 8, [])); end
            case 3, % Float (4 bytes)
                if ~swapEndianess, uint8_array = typecast(obj.Data(:), 'uint8');
                else, uint8_array = flipud(reshape(typecast(obj.Data(:), 'uint8'), 4, [])); end
            case 4, % Int64 (8 bytes)
                if ~swapEndianess, uint8_array = typecast(obj.Data(:), 'uint8');
                else, uint8_array = flipud(reshape(typecast(obj.Data(:), 'uint8'), 8, [])); end
            case 5, % Int32 (4 bytes)
                if ~swapEndianess, uint8_array = typecast(obj.Data(:), 'uint8');
                else, uint8_array = flipud(reshape(typecast(obj.Data(:), 'uint8'), 4, [])); end
            case 6, % Uint32 (4 bytes) % SPECIAL CASE: Uint16 for 'Dates'-tag (2 bytes)
                if isa(obj.Data, 'uint32'), bytes = 4;
                else, bytes = 2; end % SPECIAL CASE: for 'Dates'-tag
                if ~swapEndianess, uint8_array = typecast(obj.Data(:), 'uint8');
                else, uint8_array = flipud(reshape(typecast(obj.Data(:), 'uint8'), bytes, [])); end
            case 7, % Char (1 byte)
                uint8_array = uint8(obj.Data(:));
            case 8, % Bool (1 byte)
                uint8_array = uint8(obj.Data(:));
            case 9, % NameLength (4 bytes) + String (NameLength # of bytes)
                if ~swapEndianess, uint8_array_NameLength = typecast(uint32(numel(obj.Data(:))), 'uint8');
                else, uint8_array_NameLength = fliplr(typecast(uint32(numel(obj.Data(:))), 'uint8')); end
                uint8_array = [uint8_array_NameLength(:); uint8(obj.Data(:))];
            otherwise,
                old_state = warning('query', 'backtrace'); % Store warning state
                warning off backtrace; % Disable the stack trace
                warning('Tag(%s): Unsupported Type (%d)!', obj.FullName, obj.Type);
                warning(old_state); % Restore warning state
        end
        buffer(ind_begin:ind_end) = uint8_array;
    end
end
