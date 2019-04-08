% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Reads files with LITTLE ENDIAN ORDERING
function obj = read(File, N_bytes_max),
    % Reads a WIP-formatted tag from the given file stream.
    % Reading can be limited by N_bytes_max (if low on memory).
    if nargin < 2, N_bytes_max = Inf; end % Default: no read limit!
    
    isLittleEndian = true; % By default: Read as little endian
    % Decide if endianess should be swapped
    [~, ~, endian] = computer;
    if strcmp(endian, 'B'), % Computer uses BIG-ENDIAN ORDERING
        swapEndianess = isLittleEndian; % Swap if to read little endian
    else, % Otherwise ASSUME computer to use LITTLE-ENDIAN ORDERING
        swapEndianess = ~isLittleEndian; % Swap if to read big endian
    end
    
    % Get available memory in bytes (IN ORDER TO HANDLE LOW-MEMORY CASE!)
    [~, sys] = memory;
    
    % Try to open file
    fid = fopen(File, 'r');
    if isempty(fid) || fid == -1, error('File (''%s'') cannot be opened for reading!', File); end
    
    % Close the file ONLY WHEN out of the function scope
    C = onCleanup(@() fclose(fid)); % https://blogs.mathworks.com/loren/2008/03/10/keeping-things-tidy/
    
    % From relative path to full path
    File = which(File);
    
    % Read the Tag(s)
    obj = wit();
    obj.File = File;
    
    if 1.2.*obj.End + 1e6 < sys.PhysicalMemory.Available, % TEST IF BUFFER FITS IN MEM
        buffer = fread(fid, Inf, 'uint8=>uint8');
        obj.binaryread(buffer, [], N_bytes_max, swapEndianess);
    else,
        warning('Reading file in slower LOW-ON-MEMORY mode!');
        obj.fread(fid, N_bytes_max, swapEndianess); % ONLY FOR LOW-ON MEMORY!
    end
end
