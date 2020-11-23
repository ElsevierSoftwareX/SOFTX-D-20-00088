% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function was implemented to enable unzip/zip-utilities and provide
% SPEED-UP when reading file, because we can call EXPENSIVE fread only
% once.
function bread(obj, buffer, N_bytes_max, swapEndianess, skip_Data_criteria_for_obj, error_criteria_for_obj, fun_progress_bar),
    % Reads a WIT-formatted tag info from the given buffer stream.
    % Reading can be limited by N_bytes_max (if low on memory).
    if nargin < 3, N_bytes_max = Inf; end % Default: no read limit!
    if nargin < 4 || isempty(swapEndianess), swapEndianess = WITio.obj.wit.swap_endianess(); end % By default: Binary with little endianess
    if nargin < 5, skip_Data_criteria_for_obj = []; end % By default: no criteria!
    if nargin < 6, error_criteria_for_obj = []; end % By default: no criteria!
    if nargin < 7, fun_progress_bar = @(x) WITio.obj.wit.progress_bar(x, '-OnlyIncreasing'); end % By default: verbose progress bar in Command Window
    
    % Test the data stream
    if isempty(buffer),
        delete(obj); % Delete obj if not valid (and avoid Octave-incompatible isvalid-function)
        return;
    end
    ind_begin = 1;
    ind_max = numel(buffer);
    buffer = reshape(buffer, 1, []); % Force row vector (only once!)
    
    verbose = isa(fun_progress_bar, 'function_handle');
    if verbose,
        % Get buffer size
        BufferSize = uint64(ind_max);
        
        IntervalBlockSize = 1024.^2; % Limit progress updates to every 1 MB
        IntervalNextLimit = 0;
        
        fprintf('Reading %d bytes of binary as wit Tree objects:\n', BufferSize);
        [fun_start, fun_now, fun_end, fun_now_text] = fun_progress_bar(BufferSize);
        fun_start(0);
        
        % Automatically call fun_end whenever end of function is reached
        ocu = onCleanup(fun_end);
    end
    
    % Temporarily adjust warning settings
    old_state = warning('query', 'backtrace'); % Get current warning state
    warning off backtrace; % Disable the stack trace
    ocu_restore_warning = onCleanup(@() warning(old_state)); % Restore warning state on exit
    
    % Read Magic (8 bytes) (only if Root)
    if isempty(obj.Parent),
        ind_end = ind_begin-1 + 8;
        % Abort, if the end is reached
        if ind_end > ind_max,
            delete(obj); % Delete obj if not valid (and avoid Octave-incompatible isvalid-function)
            return;
        end
        obj.Magic = char(buffer(ind_begin:ind_end)); % Force ascii-conversion
        ind_begin = ind_end + 1; % Set next begin index
    end
    
    % Read wit Tree objects
    if ~bread_helper(obj),
        delete(obj); % Delete obj if not valid (and avoid Octave-incompatible isvalid-function)
    end
    
    function isDone = bread_helper(obj),
        isDone = false; % Needed to properly handle failure cases
        
        % Do not allow obj to notify its ancestors on modifications
        obj.ModifiedAncestors = false;
        
        % Read NameLength (4 bytes)
        ind_end = ind_begin-1 + 4;
        if ind_end > ind_max, % Abort, if the end is reached
            obj.ParentNow = WITio.obj.wit.empty; % Do not touch obj.Parent.Data on deletion!
            return;
        end
        if ~swapEndianess, obj_NameLength = typecast(buffer(ind_begin:ind_end), 'uint32');
        else, obj_NameLength = typecast(fliplr(buffer(ind_begin:ind_end)), 'uint32'); end
        obj.NameLength = obj_NameLength;
        ind_begin = ind_end + 1; % Set next begin index
        
        % Read Name (NameLength # of bytes)
        ind_end = ind_begin-1 + double(obj_NameLength);
        if ind_end > ind_max, % Abort, if the end is reached
            obj.ParentNow = WITio.obj.wit.empty; % Do not touch obj.Parent.Data on deletion!
            return;
        end
        obj_NameNow = char(buffer(ind_begin:ind_end)); % Speed-up
        obj.NameNow = obj_NameNow;
        ind_begin = ind_end + 1; % Set next begin index
        
        % Read Type (4 bytes)
        ind_end = ind_begin-1 + 4;
        if ind_end > ind_max, % Abort, if the end is reached
            obj.ParentNow = WITio.obj.wit.empty; % Do not touch obj.Parent.Data on deletion!
            return;
        end
        if ~swapEndianess, obj_Type = typecast(buffer(ind_begin:ind_end), 'uint32');
        else, obj_Type = typecast(fliplr(buffer(ind_begin:ind_end)), 'uint32'); end
        obj.Type = obj_Type;
        ind_begin = ind_end + 1; % Set next begin index
        
        % Read Start (8 bytes)
        ind_end = ind_begin-1 + 8;
        if ind_end > ind_max, % Abort, if the end is reached
            obj.ParentNow = WITio.obj.wit.empty; % Do not touch obj.Parent.Data on deletion!
            return;
        end
        if ~swapEndianess, obj_Start = typecast(buffer(ind_begin:ind_end), 'uint64');
        else, obj_Start = typecast(fliplr(buffer(ind_begin:ind_end)), 'uint64'); end
        obj.Start = obj_Start;
        ind_begin = ind_end + 1; % Set next begin index
        
        % Read End (8 bytes)
        ind_end = ind_begin-1 + 8;
        if ind_end > ind_max, % Abort, if the end is reached
            obj.ParentNow = WITio.obj.wit.empty; % Do not touch obj.Parent.Data on deletion!
            return;
        end
        if ~swapEndianess, obj_End = typecast(buffer(ind_begin:ind_end), 'uint64');
        else, obj_End = typecast(fliplr(buffer(ind_begin:ind_end)), 'uint64'); end
        obj.End = obj_End;
        ind_begin = ind_end + 1; % Set next begin index
        
        doVerbose = false;
        if verbose,
            if obj_Start >= IntervalNextLimit,
                IntervalNextLimit = obj_Start + IntervalBlockSize;
                doVerbose = true;
            end
        end
        
        if doVerbose,
            fun_now_text(obj.FullName);
        end
        
        % Update the flag used for the reloading cases
        obj.HasData = obj_End > obj_Start;
        
        % SPECIAL CASE: Skip if obj meets the given skip Data criteria.
        skip_Data = false;
        if isa(skip_Data_criteria_for_obj, 'function_handle'),
            skip_Data = skip_Data_criteria_for_obj(obj);
        end
        
        % Data reading
        if skip_Data, % Handle Data skipping
            ind_begin = double(obj_End)+1; % Double OFFSET for compability!
        elseif obj_Type == 0, % Read the children
            children = WITio.obj.wit.empty;
            while(ind_begin < obj_End), % Continue reading until DataEnd
                child = WITio.obj.wit(); % Many times faster than WITio.obj.wit(obj) due to redundant code
                child.ParentNow = obj; % Adopt the new child being created
                if bread_helper(child), % Read the new child contents (or destroy it on failure)
                    children(end+1) = child; % Add child if valid (and avoid Octave-incompatible isvalid-function)
                    child.OrdinalNumber = numel(children);
                else, delete(child); end % Delete child if not valid (and avoid Octave-incompatible isvalid-function)
            end
            obj.DataNow = children; % Adopt the new child being created
            obj.ChildrenNow = children; % Adopt the new child being created
        else,
            obj.bread_Data(buffer, N_bytes_max, swapEndianess);
            ind_begin = double(obj_End)+1; % Double OFFSET for compability!
        end % Otherwise, read the Data
        
        if doVerbose,
            fun_now(obj_End);
        end
        
        % Allow obj to notify its ancestors on modifications
        obj.ModifiedAncestors = true;
        
        % SPECIAL CASE: Abort if obj meets the given error criteria.
        if isa(error_criteria_for_obj, 'function_handle'),
            temp = obj.ParentNow;
            obj.ParentNow = WITio.obj.wit.empty; % Do not touch obj.Parent.Data on deletion!
            error_criteria_for_obj(obj); % EXPECTED TO ERROR if its criteria is met
            obj.ParentNow = temp;
        end
        
        isDone = true; % Needed to properly handle failure cases
    end
end
