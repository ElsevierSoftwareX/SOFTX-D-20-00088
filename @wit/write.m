% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function write(obj, File),
    Root = obj.Root; % Get Root only once
    
    % Test the input
    if nargin > 1,
        if ~ischar(File) || isempty(File),
            error('File must be a non-empty string!');
        end
    elseif isempty(Root.File),
        error('Root has no File specified!');
    else,
        File = Root.File;
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
    Root.update();
    
    % Then write the root
    % Disable automatic flushing using 'W'-flag instead of 'w'-flag: http://undocumentedmatlab.com/blog/improving-fwrite-performance
    Root.File = File;
    fid = fopen(File, 'W'); % Instead of 'w'!
    if fid == -1 || isempty(fid), error('File (''%s'') cannot be opened for writing!', Root.File); end
    
    % Close the file ONLY WHEN out of the function scope
    C = onCleanup(@() fclose(fid)); % https://blogs.mathworks.com/loren/2008/03/10/keeping-things-tidy/
    
    % Get file name and size
    [~, name, ext] = fileparts(File);
    FileName = [name ext];
    FileSize = obj.End; % Get file size
    
    fun_progress(0);
    try, % TRY TO FIT THE FILE CONTENT TO BUFFER IN MEMORY AT ONCE
        % Avoid call to builtin 'memory', which is Octave-incompatible!
        buffer = zeros(FileSize, 1, 'uint8'); % Preallocate the buffer OR ERROR IF LOW-ON-MEMORY!
        buffer = obj.binary(swapEndianess, @fun_progress);
        fwrite(fid, buffer, 'uint8');
    catch, % OTHERWISE USE LOW-ON MEMORY SCHEME!
        warning('Low on memory... Writing file ''%s'' of %d bytes children-by-children!', FileName, FileSize);
        Root.fwrite(fid, swapEndianess, @fun_progress);
    end
    fun_progress(FileSize);
    
    function fun_progress(N_bytes_read),
        N_blocks = 50;
        persistent tictoc N_blocks_read;
        if isempty(N_blocks_read), N_blocks_read = 0; end
        if N_bytes_read == 0,
            fprintf('Writing %d bytes to file: %s\n', FileSize, FileName);
            fprintf([' 0%%' repmat(' ', [1 ceil(N_blocks./2)-5]) '50%%' repmat(' ', [1 floor(N_blocks./2)-4]) '100%% complete!\n[']);
            N_blocks_read = 0; % Initialize the progress bar
            tictoc = tic;
        elseif N_bytes_read == FileSize,
            fprintf('.]\n');
            toc(tictoc);
        else,
            while N_bytes_read >= (N_blocks_read+1)./N_blocks.*FileSize,
                fprintf('.');
                N_blocks_read = N_blocks_read+1;
            end
        end
    end
end
