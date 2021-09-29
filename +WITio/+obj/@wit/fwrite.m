% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% USE THIS ONLY IF LOW-ON MEMORY OR WHEN WRITING HUGE FILES!
function fwrite(obj, fid, swapEndianess, fun_progress_bar), %#ok
    if nargin < 3 || isempty(swapEndianess), swapEndianess = WITio.obj.wit.swap_endianess(); end % By default: Binary with little endianess
    if nargin < 4, fun_progress_bar = @(x) WITio.obj.wit.progress_bar(x, '-OnlyIncreasing'); end % By default: verbose progress bar in Command Window
    
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
    
    % Write wit Tree objects
    fwrite_helper(obj);
    
    function fwrite_helper(obj), %#ok
        % Test the file stream
        if isempty(fid) || fid == -1, error('File stream is not open!'); end

        % Get number of bytes
        N_magic = 8.*isempty(obj.ParentNow);
        N_header = N_magic + 4 + 1.*double(obj.NameLength) + 4 + 8 + 8;
        N_buffer = N_header;

        % Preallocate
        buffer = zeros(N_buffer, 1, 'uint8');
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

        fwrite(fid, buffer, 'uint8', 0, 'l');
        
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
        if ~isempty(obj.DataNow), %#ok
            % Convert the data to proper type specified by Type before writing
            switch(obj.Type), %#ok
                case 0, %#ok % List of Tags
                    for ii = 1:numel(obj.DataNow), %#ok
                        fwrite_helper(obj.DataNow(ii));
                    end
                case 2, %#ok % Double (8 bytes)
                    if ~swapEndianess, fwrite(fid, obj.DataNow, 'double', 0, 'l');
                    else, fwrite(fid, obj.DataNow, 'double', 0, 'b'); end
                case 3, %#ok % Float (4 bytes)
                    if ~swapEndianess, fwrite(fid, obj.DataNow, 'single', 0, 'l');
                    else, fwrite(fid, obj.DataNow, 'single', 0, 'b'); end
                case 4, %#ok % Int64 (8 bytes)
                    if ~swapEndianess, fwrite(fid, obj.DataNow, 'int64', 0, 'l');
                    else, fwrite(fid, obj.DataNow, 'int64', 0, 'b'); end
                case 5, %#ok % Int32 (4 bytes)
                    if ~swapEndianess, fwrite(fid, obj.DataNow, 'int32', 0, 'l');
                    else, fwrite(fid, obj.DataNow, 'int32', 0, 'b'); end
                case 6, %#ok % Uint32 (4 bytes) % SPECIAL CASE: Uint16 for 'Dates'-tag (2 bytes)
                    if ~swapEndianess, %#ok
                        if isa(obj.DataNow, 'uint32'), fwrite(fid, obj.DataNow, 'uint32', 0, 'l');
                        else, fwrite(fid, obj.DataNow, 'uint16', 0, 'l'); end % SPECIAL CASE: for 'Dates'-tag
                    else, %#ok
                        if isa(obj.DataNow, 'uint32'), fwrite(fid, obj.DataNow, 'uint32', 0, 'b');
                        else, fwrite(fid, obj.DataNow, 'uint16', 0, 'b'); end % SPECIAL CASE: for 'Dates'-tag
                    end
                case 7, %#ok % Uint8 (1 byte)
                    fwrite(fid, obj.DataNow, 'uint8', 0, 'l');
                case 8, %#ok % Bool (1 byte)
                    fwrite(fid, obj.DataNow, 'uint8', 0, 'l');
                case 9, %#ok % NameLength (4 bytes) + String (NameLength # of bytes)
                    strs = obj.DataNow;
                    if ~isempty(strs), %#ok
                        if ~iscell(strs), strs = {strs}; end
                        for ii = 1:numel(strs), %#ok
                            str_ii = strs{ii};
                            if ~swapEndianess, fwrite(fid, numel(str_ii), 'uint32', 0, 'l');
                            else, fwrite(fid, numel(str_ii), 'uint32', 0, 'b'); end
                            fwrite(fid, str_ii, 'uint8', 0, 'l');
                        end
                    end
                otherwise, %#ok
                    old_state = warning('query', 'backtrace'); % Store warning state
                    warning off backtrace; % Disable the stack trace
                    warning('Tag(%s): Unsupported Type (%d)!', obj.FullName, obj.Type);
                    warning(old_state); % Restore warning state
            end
        end
        
        if doVerbose, %#ok
            fun_now(obj.End);
        end
    end
end
