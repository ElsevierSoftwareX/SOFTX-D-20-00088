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
    if nargin < 7, fun_progress_bar = @(x) wit.progress_bar(x, '-OnlyIncreasing'); end % By default: verbose progress bar in Command Window
    
    % Test the file stream
    if isempty(fid) || fid == -1,
        delete(obj); % Delete obj if not valid (and avoid Octave-incompatible isvalid-function)
    end
    
    % Determine fread endianess
    if ~swapEndianess, endianess = 'l';
    else, endianess = 'b'; end
    
    verbose = isa(fun_progress_bar, 'function_handle');
    if verbose,
        % Get file size
        fseek(fid, 0, 'eof'); % Go to end of file
        FileSize = ftell(fid); % Get file size
        fseek(fid, 0, 'bof'); % Return to beginning of file
        
        IntervalBlockSize = 1024.^2; % Limit progress updates to every 1 MB
        IntervalNextLimit = 0;
        
        fprintf('Reading %d bytes of binary as wit Tree objects:\n', FileSize);
        [fun_start, fun_now, fun_end, fun_now_text] = fun_progress_bar(FileSize);
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
        % Abort, if file stream has reached the end
        if feof(fid),
            delete(obj); % Delete obj if not valid (and avoid Octave-incompatible isvalid-function)
        end
        obj.Magic = reshape(fread(fid, 8, 'uint8=>char', 0, endianess), 1, []); % Force ascii-conversion
    end
    
    % Read wit Tree objects
    if ~fread_helper(obj, obj.FullName),
        delete(obj); % Delete obj if not valid (and avoid Octave-incompatible isvalid-function)
    end
    
    function isDone = fread_helper(obj, FullName),
        isDone = false; % Needed to properly handle failure cases
        
        % Do not allow obj to notify its ancestors on modifications
        obj.ModifiedAncestors = false;
        
        % Read NameLength (4 bytes)
        if feof(fid), % Abort, if file stream has reached the end
            obj.ParentNow = wit.empty; % Do not touch obj.Parent.Data on deletion!
            return;
        end
        obj_NameLength = fread(fid, 1, 'uint32=>uint32', 0, endianess);
        obj.NameLength = obj_NameLength;
        
        % Read Name (NameLength # of bytes)
        if feof(fid), % Abort, if file stream has reached the end
            obj.ParentNow = wit.empty; % Do not touch obj.Parent.Data on deletion!
            return;
        end
        obj_NameNow = reshape(fread(fid, double(obj_NameLength), 'uint8=>char', 0, endianess), 1, []); % String is a char row vector % Double OFFSET for compability!
        obj.NameNow = obj_NameNow;
        
        % Read Type (4 bytes)
        if feof(fid), % Abort, if file stream has reached the end
            obj.ParentNow = wit.empty; % Do not touch obj.Parent.Data on deletion!
            return;
        end
        obj_Type = fread(fid, 1, 'uint32=>uint32', 0, endianess);
        obj.Type = obj_Type;
        
        % Read Start (8 bytes)
        if feof(fid), % Abort, if file stream has reached the end
            obj.ParentNow = wit.empty; % Do not touch obj.Parent.Data on deletion!
            return;
        end
        obj_Start = fread(fid, 1, 'uint64=>uint64', 0, endianess);
        obj.Start = obj_Start;
        
        % Read End (8 bytes)
        if feof(fid), % Abort, if file stream has reached the end
            obj.ParentNow = wit.empty; % Do not touch obj.Parent.Data on deletion!
            return;
        end
        obj_End = fread(fid, 1, 'uint64=>uint64', 0, endianess);
        obj.End = obj_End;
        
        doVerbose = false;
        if verbose,
            if obj_Start >= IntervalNextLimit,
                IntervalNextLimit = obj_Start + IntervalBlockSize;
                doVerbose = true;
            end
        end
        
        if isempty(FullName), FullName = obj_NameNow;
        else, FullName = [FullName '>' obj_NameNow]; end
        if doVerbose,
            fun_now_text(FullName);
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
            fseek(fid, double(obj_End), 'bof'); % Double OFFSET for compability!
        elseif obj_Type == 0, % Read the children
            children = wit.empty;
            while(ftell(fid) < obj_End), % Continue reading until DataEnd
                child = wit(); % Many times faster than wit(obj) due to redundant code
                child.ParentNow = obj; % Adopt the new child being created
                if fread_helper(child, FullName), % Read the new child contents (or destroy it on failure)
                    children(end+1) = child; % Add child if valid (and avoid Octave-incompatible isvalid-function)
                    child.OrdinalNumber = numel(children);
                else, delete(child); end % Delete child if not valid (and avoid Octave-incompatible isvalid-function)
            end
            obj.DataNow = children; % Adopt the new child being created
            obj.ChildrenNow = children; % Adopt the new child being created
        else, obj.fread_Data(fid, N_bytes_max, swapEndianess); end % Otherwise, read the Data
        
        if verbose,
            fun_now(obj_End);
        end
        
        % Allow obj to notify its ancestors on modifications
        obj.ModifiedAncestors = true;
        
        % SPECIAL CASE: Abort if obj meets the given error criteria.
        if isa(error_criteria_for_obj, 'function_handle'),
            temp = obj.ParentNow;
            obj.ParentNow = wit.empty; % Do not touch obj.Parent.Data on deletion!
            error_criteria_for_obj(obj); % EXPECTED TO ERROR if its criteria is met
            obj.ParentNow = temp;
        end
        
        isDone = true; % Needed to properly handle failure cases
    end
end
