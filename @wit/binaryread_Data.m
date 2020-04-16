% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function ind_begin = binaryread_Data(obj, buffer, N_bytes_max, swapEndianess),
    % Reads a WIT-formatted tag data from the given file stream.
    % Reading can be limited by N_bytes_max (if low on memory).
    if nargin < 3, N_bytes_max = Inf; end % Default: no read limit!
    if nargin < 4, swapEndianess = false; end % By default: Read without swapping endianess
    
    warning('You are using a deprecated version! Use bread_Data-function instead.');
    obj.bread_Data(buffer, N_bytes_max, swapEndianess);
    ind_begin = obj.End+1;
end
