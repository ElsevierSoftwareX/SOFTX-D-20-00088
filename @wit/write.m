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
    
    % Update the root first
    obj.Root.update();
    
    % Then write the root
    % Consider using 'W'-flag instead? http://undocumentedmatlab.com/blog/improving-fwrite-performance
    obj.Root.File = File;
    fid = fopen(File, 'w');
    if fid == -1 || isempty(fid), error('File (''%s'') cannot be opened for writing!', obj.Root.File); end
    
    % Close the file ONLY WHEN out of the function scope
    C = onCleanup(@() fclose(fid)); % https://blogs.mathworks.com/loren/2008/03/10/keeping-things-tidy/
    
    % Get file name and size
    [~, name, ext] = fileparts(File);
    FileName = [name ext];
    FileSize = obj.End; % Get file size
    
    try, % TRY TO FIT THE FILE CONTENT TO BUFFER IN MEMORY AT ONCE
        % Avoid call to builtin 'memory', which is Octave-incompatible!
        buffer = ones(FileSize, 1, 'uint8'); % Preallocate the buffer OR ERROR IF LOW-ON-MEMORY!
        clear buffer; % ON SUCCESS, clear the preallocated array!
        buffer = obj.binary(swapEndianess);
        fwrite(fid, buffer, 'uint8');
    catch, % OTHERWISE USE LOW-ON MEMORY SCHEME!
        warning('Low on memory... Writing file ''%s'' of %d bytes children-by-children!', FileName, FileSize);
        obj.Root.fwrite(fid, swapEndianess);
    end
end
