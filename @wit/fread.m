% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% USE THIS ONLY IF LOW-ON MEMORY OR WHEN READING HUGE FILES!
function fread(obj, fid, N_bytes_max, swapEndianess, error_by_obj_criteria),
    % Reads a WIT-formatted tag info from the given file stream.
    % Reading can be limited by N_bytes_max (if low on memory).
    if nargin < 3, N_bytes_max = Inf; end % Default: no read limit!
    if nargin < 4, swapEndianess = false; end % By default: Read without swapping endianess
    if nargin < 5, error_by_obj_criteria = []; end % By default: no criteria!
    
    % Test the file stream
    if isempty(fid) || fid == -1, obj.IsValid = false; return; end

    % Read Magic (8 bytes) (only if Root)
    if isempty(obj.Parent),
        if feof(fid), obj.IsValid = false; return; end % Abort, if file stream has reached the end
        obj.Magic = reshape(fread(fid, 8, 'uint8=>char', 0, 'l'), 1, []); % Force ascii-conversion
    end

    % Read NameLength (4 bytes)
    if feof(fid), obj.IsValid = false; return; end % Abort, if file stream has reached the end
    obj.NameLength = fread(fid, 1, 'uint32=>uint32', 0, 'l');

    % Read Name (NameLength # of bytes)
    if feof(fid), obj.IsValid = false; return; end % Abort, if file stream has reached the end
    obj.Name = reshape(fread(fid, double(obj.NameLength), 'uint8=>char', 0, 'l'), 1, []); % String is a char row vector % Double OFFSET for compability!

    % Read Type (4 bytes)
    if feof(fid), obj.IsValid = false; return; end % Abort, if file stream has reached the end
    obj.Type = fread(fid, 1, 'uint32=>uint32', 0, 'l');

    % Read Start (8 bytes)
    if feof(fid), obj.IsValid = false; return; end % Abort, if file stream has reached the end
    obj.Start = fread(fid, 1, 'uint64=>uint64', 0, 'l');

    % Read End (8 bytes)
    if feof(fid), obj.IsValid = false; return; end % Abort, if file stream has reached the end
    obj.End = fread(fid, 1, 'uint64=>uint64', 0, 'l');
    
    % Update the flag used for the reloading cases
    obj.HasData = obj.End > obj.Start;

    % Data reading
    if obj.Type == 0, % Read the children
        children = wit.empty;
        while(ftell(fid) < obj.End), % Continue reading until DataEnd
            child = wit(obj);
            child.fread(fid, N_bytes_max, swapEndianess, error_by_obj_criteria);
            if child.IsValid, children(end+1) = child; % Append only if valid
            else, child.destroy(true); end % Otherwise destroy the child (and skip unnotified Parent)
        end
        obj.Data = children;
    else, obj.fread_Data(fid, N_bytes_max, swapEndianess); end % Otherwise, read the Data
    
    % SPECIAL CASE: Abort if obj meets the given error criteria.
    if isa(error_by_obj_criteria, 'function_handle'),
        error_by_obj_criteria(obj); % EXPECTED TO ERROR if its criteria is met
    end
end
