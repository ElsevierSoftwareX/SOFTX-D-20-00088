% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function was implemented to enable unzip/zip-utilities and provide
% SPEED-UP when reading file, because we can call EXPENSIVE fread only
% once.
function ind_begin = binaryread(obj, buffer, ind_begin, N_bytes_max, swapEndianess, skip_Data_criteria_for_obj, error_criteria_for_obj),
    % Reads a WIT-formatted tag info from the given file stream.
    % Reading can be limited by N_bytes_max (if low on memory).
    if nargin < 4, N_bytes_max = Inf; end % Default: no read limit!
    if nargin < 5, swapEndianess = false; end % By default: Read without swapping endianess
    if nargin < 6, skip_Data_criteria_for_obj = []; end % By default: no criteria!
    if nargin < 7, error_criteria_for_obj = []; end % By default: no criteria!
    
    warning('You are using a deprecated version! Use bread-function instead.');
    obj.bread(obj, buffer, N_bytes_max, swapEndianess, skip_Data_criteria_for_obj, error_criteria_for_obj);
    ind_begin = obj.End+1;
end
