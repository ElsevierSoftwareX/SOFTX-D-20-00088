% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function was implemented to enable unzip/zip-utilities and provide
% SPEED-UP when reading file, because we can call EXPENSIVE fread only
% once. Due to variations between PC's, this allows swapping endianess. As
% far as the author knows, the WIT-formatted files are always LITTLE-ENDIAN
% ORDERED.
function ind_begin = binaryread(obj, buffer, ind_begin, N_bytes_max, swapEndianess, skip_Data_criteria_for_obj, error_criteria_for_obj),
    % Reads a WIT-formatted tag info from the given file stream.
    % Reading can be limited by N_bytes_max (if low on memory).
    if nargin < 3 || isempty(ind_begin), ind_begin = 1; end
    if nargin < 4, N_bytes_max = Inf; end % Default: no read limit!
    if nargin < 5, swapEndianess = false; end % By default: Read without swapping endianess
    if nargin < 6, skip_Data_criteria_for_obj = []; end % By default: no criteria!
    if nargin < 7, error_criteria_for_obj = []; end % By default: no criteria!
    
    % Test the data stream
    if isempty(buffer), delete(obj); return; end
    ind_max = numel(buffer);
    
    % Do not allow obj to notify its ancestors on modifications
    obj.ModificationsToAncestors = false;
    
    % Set the object itself as its own latest modified object (known beforehand)
    obj.ModificationsLatestAt = obj;
    
    % Read Magic (8 bytes) (only if Root)
    if isempty(obj.Parent),
        ind_end = ind_begin-1 + 8;
        if ind_end > ind_max, delete(obj); return; end % Abort, if the end is reached
        obj.Magic = reshape(char(buffer(ind_begin:ind_end)), 1, []); % Force ascii-conversion
        ind_begin = ind_end + 1; % Set next begin index
    end

    % Read NameLength (4 bytes)
    ind_end = ind_begin-1 + 4;
    if ind_end > ind_max, delete(obj); return; end % Abort, if the end is reached
    if ~swapEndianess, obj.NameLength = typecast(buffer(ind_begin:ind_end), 'uint32');
    else, obj.NameLength = typecast(fliplr(buffer(ind_begin:ind_end)), 'uint32'); end
    ind_begin = ind_end + 1; % Set next begin index

    % Read Name (NameLength # of bytes)
    ind_end = ind_begin-1 + double(obj.NameLength);
    if ind_end > ind_max, delete(obj); return; end % Abort, if the end is reached
    obj.Name = reshape(char(buffer(ind_begin:ind_end)), 1, []);
    ind_begin = ind_end + 1; % Set next begin index

    % Read Type (4 bytes)
    ind_end = ind_begin-1 + 4;
    if ind_end > ind_max, delete(obj); return; end % Abort, if the end is reached
    if ~swapEndianess, obj.Type = typecast(buffer(ind_begin:ind_end), 'uint32');
    else, obj.Type = typecast(fliplr(buffer(ind_begin:ind_end)), 'uint32'); end
    ind_begin = ind_end + 1; % Set next begin index

    % Read Start (8 bytes)
    ind_end = ind_begin-1 + 8;
    if ind_end > ind_max, delete(obj); return; end % Abort, if the end is reached
    if ~swapEndianess, obj.Start = typecast(buffer(ind_begin:ind_end), 'uint64');
    else, obj.Start = typecast(fliplr(buffer(ind_begin:ind_end)), 'uint64'); end
    ind_begin = ind_end + 1; % Set next begin index

    % Read End (8 bytes)
    ind_end = ind_begin-1 + 8;
    if ind_end > ind_max, delete(obj); return; end % Abort, if the end is reached
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
        while(ind_begin < obj.End), % Continue reading until DataEnd
            child = wit(obj); % Adopt the new child being created
            ind_begin = child.binaryread(buffer, ind_begin, N_bytes_max, swapEndianess, error_criteria_for_obj); % Read the new child contents (or destroy it on failure)
        end
    else, ind_begin = obj.binaryread_Data(buffer, N_bytes_max, swapEndianess); end % Otherwise, read the Data
    
    % Allow obj to notify its ancestors on modifications
    obj.ModificationsToAncestors = true;
    
    % SPECIAL CASE: Abort if obj meets the given error criteria.
    if isa(error_criteria_for_obj, 'function_handle'),
        error_criteria_for_obj(obj); % EXPECTED TO ERROR if its criteria is met
    end
end
