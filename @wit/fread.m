% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% USE THIS ONLY IF LOW-ON MEMORY OR WHEN READING HUGE FILES!
function fread(obj, fid, N_bytes_max, swapEndianess, skip_Data_criteria_for_obj, error_criteria_for_obj, fun_progress_bar),
    % Reads a WIT-formatted tag info from the given file stream.
    % Reading can be limited by N_bytes_max (if low on memory).
    if nargin < 3, N_bytes_max = Inf; end % Default: no read limit!
    if nargin < 4 || isempty(swapEndianess), swapEndianess = wit.swap_endianess(); end % By default: Binary with little endianess
    if nargin < 5, skip_Data_criteria_for_obj = []; end % By default: no criteria!
    if nargin < 6, error_criteria_for_obj = []; end % By default: no criteria!
    if nargin < 7, fun_progress_bar = @wit.progress_bar; end % By default: verbose progress bar in Command Window
    
    verbose = isa(fun_progress_bar, 'function_handle');
    if verbose,
        % Get file size
        fseek(fid, 0, 'eof'); % Go to end of file
        FileSize = ftell(fid); % Get file size
        fseek(fid, 0, 'bof'); % Return to beginning of file
        
        fprintf('Reading %d bytes of binary as wit Tree objects:\n', FileSize);
        [fun_start, fun_now, fun_end] = fun_progress_bar(FileSize);
        fun_start(0);
        ocu = onCleanup(fun_end); % Automatically call fun_end whenever end of function is reached
    end
    
    % Temporarily adjust warning settings
    old_state = warning('query', 'backtrace'); % Get current warning state
    warning off backtrace; % Disable the stack trace
    ocu_restore_warning = onCleanup(@() warning(old_state)); % Restore warning state on exit
    
    % Read wit Tree objects
    fread_helper(obj);
    
    function fread_helper(obj),
        % Test the file stream
        if isempty(fid) || fid == -1,
            obj.skipRedundant = true; % Do not touch obj.Parent.Data on deletion!
            obj.IsValid = false; % Mark this object for deletion!
            return;
        end
        
        % Do not allow obj to notify its ancestors on modifications
        obj.ModificationsToAncestors = false;
        
        % Set the object itself as its own latest modified object (known beforehand)
        obj.ModificationsLatestAt = obj;
        
        % Read Magic (8 bytes) (only if Root)
        if isempty(obj.Parent),
            if feof(fid), % Abort, if file stream has reached the end
                obj.skipRedundant = true; % Do not touch obj.Parent.Data on deletion!
                obj.IsValid = false; % Mark this object for deletion!
                return;
            end
            obj.Magic = reshape(fread(fid, 8, 'uint8=>char', 0, 'l'), 1, []); % Force ascii-conversion
        end
        
        % Read NameLength (4 bytes)
        if feof(fid), % Abort, if file stream has reached the end
            obj.skipRedundant = true; % Do not touch obj.Parent.Data on deletion!
            obj.IsValid = false; % Mark this object for deletion!
            return;
        end
        obj.NameLength = fread(fid, 1, 'uint32=>uint32', 0, 'l');
        
        % Read Name (NameLength # of bytes)
        if feof(fid), % Abort, if file stream has reached the end
            obj.skipRedundant = true; % Do not touch obj.Parent.Data on deletion!
            obj.IsValid = false; % Mark this object for deletion!
            return;
        end
        obj.skipRedundant = true; % Speed-up set.Name!
        obj.Name = fread(fid, double(obj.NameLength), 'uint8=>char', 0, 'l'); % String is a char row vector % Double OFFSET for compability!
        
        % Read Type (4 bytes)
        if feof(fid), % Abort, if file stream has reached the end
            obj.skipRedundant = true; % Do not touch obj.Parent.Data on deletion!
            obj.IsValid = false; % Mark this object for deletion!
            return;
        end
        obj.Type = fread(fid, 1, 'uint32=>uint32', 0, 'l');
        
        % Read Start (8 bytes)
        if feof(fid), % Abort, if file stream has reached the end
            obj.skipRedundant = true; % Do not touch obj.Parent.Data on deletion!
            obj.IsValid = false; % Mark this object for deletion!
            return;
        end
        obj.Start = fread(fid, 1, 'uint64=>uint64', 0, 'l');
        
        % Read End (8 bytes)
        if feof(fid), % Abort, if file stream has reached the end
            obj.skipRedundant = true; % Do not touch obj.Parent.Data on deletion!
            obj.IsValid = false; % Mark this object for deletion!
            return;
        end
        obj.End = fread(fid, 1, 'uint64=>uint64', 0, 'l');
        
        % Update the flag used for the reloading cases
        obj.HasData = obj.End > obj.Start;
        
        % SPECIAL CASE: Skip if obj meets the given skip Data criteria.
        skip_Data = false;
        if isa(skip_Data_criteria_for_obj, 'function_handle'),
            skip_Data = skip_Data_criteria_for_obj(obj);
        end
        
        % Data reading
        if skip_Data, % Handle Data skipping
            fseek(fid, double(obj.End), 'bof'); % Double OFFSET for compability!
        elseif obj.Type == 0, % Read the children
            children = wit.empty;
            while(ftell(fid) < obj.End), % Continue reading until DataEnd
                child = wit(); % Many times faster than wit(obj) due to redundant code
                child.skipRedundant = true; % Speed-up set.Parent
                child.Parent = obj; % Adopt the new child being created
                fread_helper(child); % Read the new child contents (or destroy it on failure)
                if child.IsValid, children(end+1) = child; % Add child if valid (and avoid Octave-incompatible isvalid-function)
                else, delete(child); end % Delete child if not valid (and avoid Octave-incompatible isvalid-function)
            end
            obj.skipRedundant = true; % Speed-up set.Data
            obj.Data = children; % Adopt the new child being created
        else, obj.fread_Data(fid, N_bytes_max, swapEndianess); end % Otherwise, read the Data
        
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
