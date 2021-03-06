% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function was implemented to provide CONSIDERABLE SPEED-UP when
% writing to file, because we can call EXPENSIVE fwrite only once.
function buffer = bwrite(obj, swapEndianess, fun_progress_bar), %#ok
    if nargin < 2 || isempty(swapEndianess), swapEndianess = WITio.obj.wit.swap_endianess(); end % By default: Binary with little endianess
    if nargin < 3, fun_progress_bar = @(x) WITio.obj.wit.progress_bar(x, '-OnlyIncreasing'); end % By default: verbose progress bar in Command Window
    
    % Update the wit Tree object
    obj.update();
    
    verbose = isa(fun_progress_bar, 'function_handle');
    if verbose, %#ok
        IntervalBlockSize = 1024.^2; % Limit progress updates to every 1 MB
        IntervalNextLimit = 0;
        
        fprintf('Writing wit Tree objects as %d bytes of binary:\n', obj.End);
        [fun_start, fun_now, fun_end, fun_now_text] = fun_progress_bar(obj.End);
        fun_start(0);
        ocu = onCleanup(fun_end); % Automatically call fun_end whenever end of function is reached
    end
    
    % Preallocate the whole buffer once and share it with the nested calls
    buffer = zeros(obj.End, 1, 'uint8');
    ind_begin = 1;
    
    % Write Magic string if root
    if isempty(obj.ParentNow), %#ok
        ind_end = ind_begin-1 + 8;
        Magic = obj.Magic;
        if ~isempty(Magic), %#ok
            uint8_array = uint8(obj.Magic); % String is a char row vector
            buffer(ind_begin:ind_end) = uint8_array;
        end
        ind_begin = ind_end + 1; % Set next begin index
    end
    
    % Write wit Tree objects
    binary_helper(obj);
    
    function binary_helper(obj), %#ok
        % Write NameLength (4 bytes)
        ind_end = ind_begin-1 + 4;
        if ~swapEndianess, uint8_array = typecast(obj.NameLength, 'uint8');
        else, uint8_array = fliplr(typecast(obj.NameLength, 'uint8')); end
        buffer(ind_begin:ind_end) = uint8_array;
        ind_begin = ind_end + 1; % Set next begin index
        
        % Write Name (NameLength # of bytes)
        ind_end = ind_begin-1 + double(obj.NameLength);
        uint8_array = uint8(obj.NameNow); % String is a char row vector
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
        
        % Write End (8 bytes)
        ind_end = ind_begin-1 + 8;
        if ~swapEndianess, uint8_array = typecast(obj.End, 'uint8');
        else, uint8_array = fliplr(typecast(obj.End, 'uint8')); end
        buffer(ind_begin:ind_end) = uint8_array;
        ind_begin = ind_end + 1; % Set next begin index
        
        doVerbose = false;
        if verbose, %#ok
            if obj.Start >= IntervalNextLimit, %#ok
                IntervalNextLimit = obj.Start + IntervalBlockSize;
                doVerbose = true;
            end
        end
        
        if doVerbose, %#ok
            fun_now_text(obj.FullName);
        end
        
        % Write Data
        if obj.Type == 0, %#ok % List of Tags
            for ii = 1:numel(obj.DataNow), %#ok
                binary_helper(obj.DataNow(ii));
            end
        elseif ~isempty(obj.DataNow), %#ok
            ind_end = ind_begin-1 + double(obj.End-obj.Start);
            % Convert the data to proper type specified by Type before writing
            switch(obj.Type), %#ok
                case 2, %#ok % Double (8 bytes)
                    if ~swapEndianess, uint8_array = typecast(obj.DataNow(:), 'uint8');
                    else, uint8_array = flipud(reshape(typecast(obj.DataNow(:), 'uint8'), 8, [])); end
                case 3, %#ok % Float (4 bytes)
                    if ~swapEndianess, uint8_array = typecast(obj.DataNow(:), 'uint8');
                    else, uint8_array = flipud(reshape(typecast(obj.DataNow(:), 'uint8'), 4, [])); end
                case 4, %#ok % Int64 (8 bytes)
                    if ~swapEndianess, uint8_array = typecast(obj.DataNow(:), 'uint8');
                    else, uint8_array = flipud(reshape(typecast(obj.DataNow(:), 'uint8'), 8, [])); end
                case 5, %#ok % Int32 (4 bytes)
                    if ~swapEndianess, uint8_array = typecast(obj.DataNow(:), 'uint8');
                    else, uint8_array = flipud(reshape(typecast(obj.DataNow(:), 'uint8'), 4, [])); end
                case 6, %#ok % Uint32 (4 bytes) % SPECIAL CASE: Uint16 for 'Dates'-tag (2 bytes)
                    if isa(obj.DataNow, 'uint32'), bytes = 4;
                    else, bytes = 2; end % SPECIAL CASE: for 'Dates'-tag
                    if ~swapEndianess, uint8_array = typecast(obj.DataNow(:), 'uint8');
                    else, uint8_array = flipud(reshape(typecast(obj.DataNow(:), 'uint8'), bytes, [])); end
                case 7, %#ok % Uint8 (1 byte)
                    uint8_array = uint8(obj.DataNow(:));
                case 8, %#ok % Bool (1 byte)
                    uint8_array = uint8(obj.DataNow(:));
                case 9, %#ok % NameLength (4 bytes) + String (NameLength # of bytes)
                    strs = obj.DataNow;
                    if ~isempty(strs), %#ok
                        if ~iscell(strs), strs = {strs}; end
                        uint8_array = [];
                        for ii = 1:numel(strs), %#ok
                            str_ii = strs{ii};
                            if ~swapEndianess, uint8_array_NameLength = typecast(uint32(numel(str_ii)), 'uint8');
                            else, uint8_array_NameLength = fliplr(typecast(uint32(numel(str_ii)), 'uint8')); end
                            uint8_array = [uint8_array; uint8_array_NameLength(:); uint8(str_ii(:))]; %#ok
                        end
                    end
                otherwise, %#ok
                    old_state = warning('query', 'backtrace'); % Store warning state
                    warning off backtrace; % Disable the stack trace
                    warning('Tag(%s): Unsupported Type (%d)!', obj.FullName, obj.Type);
                    warning(old_state); % Restore warning state
            end
            buffer(ind_begin:ind_end) = uint8_array;
            ind_begin = ind_end + 1; % Set next begin index
        end
        
        if doVerbose, %#ok
            fun_now(obj.End);
        end
    end
end
