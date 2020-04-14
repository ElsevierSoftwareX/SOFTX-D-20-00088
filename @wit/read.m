% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Reads files with LITTLE ENDIAN ORDERING
function obj = read(File, N_bytes_max, skip_Data_criteria_for_obj, error_criteria_for_obj),
    % Reads a WIP-formatted tag from the given file stream.
    % Reading can be limited by N_bytes_max (if low on memory).
    if nargin < 2, N_bytes_max = Inf; end % By default: no read limit!
    if nargin < 3, skip_Data_criteria_for_obj = []; end % By default: no criteria!
    if nargin < 4, error_criteria_for_obj = []; end % By default: no criteria!
    
    isLittleEndian = true; % By default: Read as little endian
    % Decide if endianess should be swapped
    [~, ~, endian] = computer; % Octave-compatible
    if strcmp(endian, 'B'), % Computer uses BIG-ENDIAN ORDERING
        swapEndianess = isLittleEndian; % Swap if to read little endian
    else, % Otherwise ASSUME computer to use LITTLE-ENDIAN ORDERING
        swapEndianess = ~isLittleEndian; % Swap if to read big endian
    end
    
    % Try to open file
    fid = fopen(File, 'r');
    if isempty(fid) || fid == -1, error('File (''%s'') cannot be opened for reading!', File); end
    
    % Close the file ONLY WHEN out of the function scope
    C = onCleanup(@() fclose(fid)); % https://blogs.mathworks.com/loren/2008/03/10/keeping-things-tidy/
    
    % Get file name
    [~, name, ext] = fileparts(File);
    FileName = [name ext];
    
    % Get file size
    fseek(fid, 0, 'eof'); % Go to end of file
    FileSize = ftell(fid); % Get file size
    fseek(fid, 0, 'bof'); % Return to beginning of file
    
    % Try to get full path from relative path.
    FileFull = which(File); % This might fail for network addresses
    if ~isempty(FileFull), File = FileFull; end % Update only if not failed
    
    % Read the Tag(s)
    obj = wit();
    obj.File = File;
    
    % Determine whether or not to use low-on-memory scheme
    lowOnMemory = FileSize > N_bytes_max;
    if ~lowOnMemory,
        try, % TRY TO FIT THE FILE CONTENT TO BUFFER IN MEMORY AT ONCE
            % Avoid call to builtin 'memory', which is Octave-incompatible!
            buffer = zeros(FileSize, 1, 'uint8'); % Preallocate the buffer OR ERROR IF LOW-ON-MEMORY!
            clear buffer;
        catch, % OTHERWISE USE LOW-ON-MEMORY SCHEME!
            lowOnMemory = true;
        end
    end
    
    fun_progress(0);
    if ~lowOnMemory, % FIT THE FILE CONTENT TO BUFFER IN MEMORY AT ONCE
        buffer = fread(fid, Inf, 'uint8=>uint8'); % Read the file content to the buffer
        obj.binaryread(buffer, [], N_bytes_max, swapEndianess, skip_Data_criteria_for_obj, error_criteria_for_obj, @fun_progress); % Parse the file content in the buffer
    else, % OTHERWISE USE LOW-ON-MEMORY SCHEME!
        if isinf(N_bytes_max),
            warning('Low on memory... Reading file ''%s'' of %d bytes, but skipping over any Data of >%d bytes!', FileName, FileSize, N_bytes_max);
            N_bytes_max = 4096; % Do not obey infinite N_bytes_max here!
        end
        obj.fread(fid, N_bytes_max, swapEndianess, skip_Data_criteria_for_obj, error_criteria_for_obj, @fun_progress);
    end
    fun_progress(FileSize);
    
    function fun_progress(N_bytes_read),
        N_blocks = 50;
        persistent tictoc N_blocks_read;
        if isempty(N_blocks_read), N_blocks_read = 0; end
        if N_bytes_read == 0,
            fprintf('Reading %d bytes from file: %s\n', FileSize, FileName);
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
