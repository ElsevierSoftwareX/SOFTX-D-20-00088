% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function write(obj, File),
    % Test the input
    if nargin > 1,
        if ~ischar(File) || isempty(File),
            error('File must be a non-empty string!');
        end
    elseif isempty(obj.Root.File),
        error('Root has no File specified!');
    else,
        File = obj.Root.File;
    end
    
    isLittleEndian = true; % By default: Write as little endian
    % Decide if endianess should be swapped
    [~, ~, endian] = computer;
    if strcmp(endian, 'B'), % Computer uses BIG-ENDIAN ORDERING
        swapEndianess = isLittleEndian; % Swap if to write little endian
    else, % Otherwise ASSUME computer to use LITTLE-ENDIAN ORDERING
        swapEndianess = ~isLittleEndian; % Swap if to write big endian
    end
    
    % Get available memory in bytes (IN ORDER TO HANDLE LOW-MEMORY CASE!)
    [~, sys] = memory;
    
    % Update the root first
    obj.Root.update();
    
    % Then write the root
    % Consider using 'W'-flag instead? http://undocumentedmatlab.com/blog/improving-fwrite-performance
    obj.Root.File = File;
    fid = fopen(File, 'w');
    if fid == -1 || isempty(fid), error('File (''%s'') cannot be opened for writing!', obj.Root.File); end
    
    % Close the file ONLY WHEN out of the function scope
    C = onCleanup(@() fclose(fid)); % https://blogs.mathworks.com/loren/2008/03/10/keeping-things-tidy/
    
    if 1.2.*obj.End + 1e6 < sys.PhysicalMemory.Available, % TEST IF BUFFER FITS IN MEM
        buffer = obj.binary(swapEndianess);
        fwrite(fid, buffer, 'uint8');
    else,
        warning('Writing file in slower LOW-ON-MEMORY mode!');
        obj.Root.fwrite(fid, swapEndianess); % ONLY IF LOW-ON MEMORY!
    end
end
