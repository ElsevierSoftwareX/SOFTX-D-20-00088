% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function determines whether or not the file reading/writing code
% should swap data endianess. To author's best knowledge, all wit-Tree
% formatted files are always LITTLE-ENDIAN ORDERED. For this reason, the
% operating system's native endianess must be taken into account. 
function swapEndianess = swap_endianess(),
    toLittleEndian = true; % By default: Write as little endian
    % Decide if endianess should be swapped
    [~, ~, endian] = computer;
    if strcmp(endian, 'B'), % Computer uses BIG-ENDIAN ORDERING
        swapEndianess = toLittleEndian; % Swap if to write little endian
    else, % Otherwise ASSUME computer to use LITTLE-ENDIAN ORDERING
        swapEndianess = ~toLittleEndian; % Swap if to write big endian
    end
end
