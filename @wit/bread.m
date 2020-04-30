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
    if nargin < 4 || isempty(swapEndianess), swapEndianess = wit.swap_endianess(); end % By default: Binary with little endianess
    if nargin < 5, skip_Data_criteria_for_obj = []; end % By default: no criteria!
    if nargin < 6, error_criteria_for_obj = []; end % By default: no criteria!
    if nargin < 7, fun_progress_bar = @wit.progress_bar; end % By default: verbose progress bar in Command Window
    
    ind_begin = 1;
    
    verbose = isa(fun_progress_bar, 'function_handle');
    if verbose,
        % Get buffer size
        BufferSize = uint64(numel(buffer));
        
        fprintf('Reading %d bytes of binary as wit Tree objects:\n', BufferSize);
        [fun_start, fun_now, fun_end] = fun_progress_bar(BufferSize);
        fun_start(0);
        ocu = onCleanup(fun_end); % Automatically call fun_end whenever end of function is reached
    end
    
    % Temporarily adjust warning settings
    old_state = warning('query', 'backtrace'); % Get current warning state
    warning off backtrace; % Disable the stack trace
    ocu_restore_warning = onCleanup(@() warning(old_state)); % Restore warning state on exit
    
    % Read wit Tree objects
    bread_helper(obj);
    
    function bread_helper(obj),
        % Test the data stream
        if isempty(buffer),
            obj.skipRedundant = true; % Do not touch obj.Parent.Data on deletion!
            obj.IsValid = false; % Mark this object for deletion!
            return;
        end
        ind_max = numel(buffer);
        
        % Do not allow obj to notify its ancestors on modifications
        obj.ModificationsToAncestors = false;
        
        % Set the object itself as its own latest modified object (known beforehand)
        obj.ModificationsLatestAt = obj;
        
        % Read Magic (8 bytes) (only if Root)
        if isempty(obj.Parent),
            ind_end = ind_begin-1 + 8;
            if ind_end > ind_max, % Abort, if the end is reached
                obj.skipRedundant = true; % Do not touch obj.Parent.Data on deletion!
                obj.IsValid = false; % Mark this object for deletion!
                return;
            end
            obj.Magic = reshape(char(buffer(ind_begin:ind_end)), 1, []); % Force ascii-conversion
            ind_begin = ind_end + 1; % Set next begin index
        end
        
        % Read NameLength (4 bytes)
        ind_end = ind_begin-1 + 4;
        if ind_end > ind_max, % Abort, if the end is reached
            obj.skipRedundant = true; % Do not touch obj.Parent.Data on deletion!
            obj.IsValid = false; % Mark this object for deletion!
            return;
        end
        if ~swapEndianess, obj.NameLength = typecast(buffer(ind_begin:ind_end), 'uint32');
        else, obj.NameLength = typecast(fliplr(buffer(ind_begin:ind_end)), 'uint32'); end
        ind_begin = ind_end + 1; % Set next begin index
        
        % Read Name (NameLength # of bytes)
        ind_end = ind_begin-1 + double(obj.NameLength);
        if ind_end > ind_max, % Abort, if the end is reached
            obj.skipRedundant = true; % Do not touch obj.Parent.Data on deletion!
            obj.IsValid = false; % Mark this object for deletion!
            return;
        end
        obj.skipRedundant = true; % Speed-up set.Name!
        obj.Name = char(buffer(ind_begin:ind_end));
        ind_begin = ind_end + 1; % Set next begin index
        
        % Read Type (4 bytes)
        ind_end = ind_begin-1 + 4;
        if ind_end > ind_max, % Abort, if the end is reached
            obj.skipRedundant = true; % Do not touch obj.Parent.Data on deletion!
            obj.IsValid = false; % Mark this object for deletion!
            return;
        end
        if ~swapEndianess, obj.Type = typecast(buffer(ind_begin:ind_end), 'uint32');
        else, obj.Type = typecast(fliplr(buffer(ind_begin:ind_end)), 'uint32'); end
        ind_begin = ind_end + 1; % Set next begin index
        
        % Read Start (8 bytes)
        ind_end = ind_begin-1 + 8;
        if ind_end > ind_max, % Abort, if the end is reached
            obj.skipRedundant = true; % Do not touch obj.Parent.Data on deletion!
            obj.IsValid = false; % Mark this object for deletion!
            return;
        end
        if ~swapEndianess, obj.Start = typecast(buffer(ind_begin:ind_end), 'uint64');
        else, obj.Start = typecast(fliplr(buffer(ind_begin:ind_end)), 'uint64'); end
        ind_begin = ind_end + 1; % Set next begin index
        
        % Read End (8 bytes)
        ind_end = ind_begin-1 + 8;
        if ind_end > ind_max, % Abort, if the end is reached
            obj.skipRedundant = true; % Do not touch obj.Parent.Data on deletion!
            obj.IsValid = false; % Mark this object for deletion!
            return;
        end
        if ~swapEndianess, obj.End = typecast(buffer(ind_begin:ind_end), 'uint64');
        else, obj.End = typecast(fliplr(buffer(ind_begin:ind_end)), 'uint64'); end
        ind_begin = ind_end + 1; % Set next begin index
        
        % Update the flag used for the reloading cases
        obj.HasData = obj.End > obj.Start;
        
        % SPECIAL CASE: Skip if obj meets the given skip Data criteria.
        skip_Data = false;
        if isa(skip_Data_criteria_for_obj, 'function_handle'),
            skip_Data = skip_Data_criteria_for_obj(obj);
        end
        
        % Data reading
        if skip_Data, % Handle Data skipping
            ind_begin = double(obj.End)+1; % Double OFFSET for compability!
        elseif obj.Type == 0, % Read the children
            children = wit.empty;
            while(ind_begin < obj.End), % Continue reading until DataEnd
                child = wit(); % Many times faster than wit(obj) due to redundant code
                child.skipRedundant = true; % Speed-up set.Parent
                child.Parent = obj; % Adopt the new child being created
                bread_helper(child); % Read the new child contents (or destroy it on failure)
                if child.IsValid, children(end+1) = child; % Add child if valid (and avoid Octave-incompatible isvalid-function)
                else, delete(child); end % Delete child if not valid (and avoid Octave-incompatible isvalid-function)
            end
            obj.skipRedundant = true; % Speed-up set.Data
            obj.Data = children; % Adopt the new child being created
        else,
            obj.bread_Data(buffer, N_bytes_max, swapEndianess);
            ind_begin = double(obj.End)+1; % Double OFFSET for compability!
        end % Otherwise, read the Data
        
        if verbose,
            fun_now(obj.End);
        end
        
        % Allow obj to notify its ancestors on modifications
        obj.ModificationsToAncestors = true;
        
        % SPECIAL CASE: Abort if obj meets the given error criteria.
        if isa(error_criteria_for_obj, 'function_handle'),
            obj.skipRedundant = true; % Do not touch obj.Parent.Data on deletion!
            error_criteria_for_obj(obj); % EXPECTED TO ERROR if its criteria is met
            obj.skipRedundant = false;
        end
    end
end
