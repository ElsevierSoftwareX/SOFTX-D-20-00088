% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This decompresses file contents in blocks directly to memory using Java.
% If second output is omitted, then this will only decompress the file
% names. Current implementation can only decompress ZIP archives. Unlike
% MATLAB's built-in unzip, this can also filter which file contents to
% decompress. This requires a running Java Virtual Machine. The following
% case-insensitive extra inputs are parsed:
% '-Decompressor' (= from file extension): Can be set to '.zip' or '.zst'.
% '-Files': Read only the specified files (unless modified by the filters
% below). It is recommended to first read all the files (with second output
% omitted) and parse them and provide the parsed files with this option.
% '-DataSizes': Instead of reading datas, read only their data sizes and
% return these as 'datas'-output.
% '-FilterExtension': Filter files to be decompressed by strcmpi-matching
% case-insensitively their file extensions using consecutive char arrays
% (i.e. '.wid' and '.wip').
% '-FilterRegexp': Filter files to be decompressed by regexp-matching their
% full file names using consecutive char arrays (i.e. '\.wi[dp]$' and
% 'ignorecase' or '\.[wW][iI][dDpP]$'), where first input is the pattern
% and the rest are extra options to regexp-function.
% '-MaxBlockSize' (= 67108864 or 64 MB): Set maximum blocksize per read to
% allow reading in smaller blocks and to reduce risk of exceeding Java Heap
% Memory (>= 128 MB for R2011a or newer) limit.
% '-MaxSubBlockSize' (= from decompressor): Each block is read in sub
% blocks in order to allow smoother user interrupts and less communication
% with MATLAB. MaxBlockSize should be divisible by this. For .zip, default
% value is 1048576 or 1 MB. For .zst, default value is 4194304 or 4 MB.
% '-ProgressBar' (= none): Use verbose wit.io.wit.progress_bar in Command
% Window. If a function handle (with equivalent input/output arguments) is
% provided, then use it instead.
function [files, datas] = wit_io_file_decompress(file, varargin),
    % Notes on unzipping using Java:
    %
    % It is noteworthy that the 64-bit ZIP archives (with individual
    % entries and archives larger than 4 GB or with more than 65536
    % entries) are supported since Apache Ant 1.9.0 (release date
    % 2013-03-07) and since Apache Commons Compress 1.3 (release date
    % 2011-11-01) and sinze Java 1.7 (release date 2011-07-28).
    %
    % Considered Java libraries with relevant zip toolbox functions:
    %
    % (1) Apache Ant (org.apache.tools.zip)
    % (a) ZipFile (and its member function getEntries).
    % * Although this is the second best library, it is used in this code,
    % because it has relatively new version within MATLAB releases.
    % * https://ant.apache.org/manual/api/org/apache/tools/zip/package-summary.html
    % * For instance, MATLAB R2011a and R2019b come with ant.jar or Apache
    % Ant 1.5.4 (release date 2003-08-12) and 1.9.9 (release date
    % 2017-02-06), respectively.
    %
    % (2) Apache Commons Compress (org.apache.commons.compress.archivers.zip)
    % (a) ZipFile (and its member function getEntries).
    % * This is the most versatile library with the best features, but
    % unfortunately its version is not updated within MATLAB releases.
    % * https://commons.apache.org/proper/commons-compress/examples.html
    % * https://commons.apache.org/proper/commons-compress/zip.html
    % * https://commons.apache.org/proper/commons-compress/apidocs/org/apache/commons/compress/archivers/zip
    % * For instance, MATLAB R2011a and R2019b come with
    % commons-compress.jar or Apache Commons Compress 1.0 (release date
    % 2009-05-21) and 1.8.1 (release date 2014-05-14), respectively.
    %
    % (3) Java (java.util.zip)
    % (a) ZipFile (and its member function entries).
    % * Java's built-in tools are inferior to the two above.
    % * For instance, MATLAB R2011a and R2019b come with Java 1.6.0_17-b04
    % (release date 2009-05-21) and 1.8.0_202-b08 (release date
    % 2019-01-15), respectively.
    %
    % Decided to use (1) due to its freshness (within MATLAB releases),
    % although the latest (2) Apache Commons Compress 1.20 (release date
    % 2020-02-08) comes with a useful "split ZIP archive" -feature but
    % MATLAB seriously lags behind the Commons Compress version.
    
    % Initialize return values
    files = {};
    decompress = nargout > 1;
    if decompress,
        datas = {};
    end
    
    % Test if the file exists
    jf = java.io.File(file);
    if ~jf.exists(), return; end % Abort if does not exist
    
    % Parse extra inputs: Decompressor
    parsed = varargin_dashed_str_datas('Decompressor', varargin, -1);
    Decompressor = []; % By default, determine decompressor from the file extension
    if numel(parsed) > 0, Decompressor = parsed{1}; end
    if isempty(Decompressor), [~, ~, Decompressor] = fileparts(file); end
    
    persistent zst_library;
    
    % Use ZIP compression
    if strcmpi('.zip', Decompressor),
        MaxSubBlockSize = 1024.^2; % By default, 1 MB max subblocksize per read
        decompressor_constructor = @decompress_zip_construct;
        decompressor = @decompress_zip;
    % Use ZST or Zstandard or Zstd compression
    elseif strcmpi('.zst', Decompressor),
        MaxSubBlockSize = 4.*1024.^2; % By default, 4 MB max subblocksize per read
        % Documentation: https://www.javadoc.io/doc/com.github.luben/zstd-jni/latest/index.html
        if isempty(zst_library), % Load java library only once per session
            decompressor_library = {'+lib', '+zstd-jni', 'zstd-jni-1.4.5-12.jar'};
            zst_library = fullfile(wit.io.path, decompressor_library{:});
            javaaddpath(zst_library);
        end
        decompressor_constructor = @decompress_zst_construct;
        decompressor = @decompress_zst;
    % Otherwise ERROR
    else,
        error('Specified decompressor, ''%s'' is not yet implemented!', Decompressor);
    end
    
    jrt = java.lang.Runtime.getRuntime();
    
    % Parse extra inputs: MaxBlockSize
    parsed = varargin_dashed_str_datas('MaxBlockSize', varargin, -1);
    MaxBlockSize = 64.*1024.^2; % By default, 64 MB max blocksize per read
    if numel(parsed) > 0, MaxBlockSize = parsed{1}; end
    
    % Parse extra inputs: MaxSubBlockSize
    parsed = varargin_dashed_str_datas('MaxSubBlockSize', varargin, -1);
    if numel(parsed) > 0, MaxSubBlockSize = parsed{1}; end
    
    % Parse extra inputs: Files
    Files = varargin_dashed_str_datas('Files', varargin);
    for ii = numel(Files):-1:1,
        if iscell(Files{ii}),
            Files = [Files(1:ii-1) Files(ii+1:end) Files{ii}]; % If a cell was provided, then append its contents to the end
        end
    end
    
    % Parse extra inputs: DataSizes
    DataSizes = varargin_dashed_str_exists('DataSizes', varargin);
    
    % Parse extra inputs: FilterExtension
    FilterExtension = varargin_dashed_str_datas('FilterExtension', varargin);
    
    % Parse extra inputs: FilterRegexp
    FilterRegexp = varargin_dashed_str_datas('FilterRegexp', varargin);
    
    % Parse extra inputs: ProgressBar
    [ProgressBar, parsed] = varargin_dashed_str_exists_and_datas('ProgressBar', varargin, -1);
    if ProgressBar, ProgressBar = @wit.io.wit.progress_bar; end
    if numel(parsed) > 0, ProgressBar = parsed{1}; end
    verbose = isa(ProgressBar, 'function_handle');
    
    % Try uncompressing the files and datas (or catch error)
    [jci, jbi, jfi] = deal([]);
    ocui = {};
    try,
        % Open the compressed file for reading
        decompressor_constructor();
        
        if decompress,
            % Preallocate Java buffer once
            java_buffer = java.nio.ByteBuffer.allocate(MaxBlockSize);
        end
        
        % Load compressor-specific entries
        decompressor();
        
        if decompress,
            % Invoke Java's garbage collection
            clear java_buffer; % Free variable from Java Heap Memory
        end
        
        clear ocui; % Close the file
    catch ME,
        warning('Cannot uncompress files and datas from ''%s'' for some reason!\n\n%s', file, ME.message);
    end
    
    % Invoke Java's garbage collection
    jrt.gc;
    
    %% .zst decompressor
    function decompress_zst_construct(),
        jfi = java.io.FileInputStream(jf);
        ocui{end+1} = onCleanup(@() jfi.close()); % Ensure safe closing of the compressed file in the end
        
        jbi = java.io.BufferedInputStream(jfi); % Required for faster performance!
        ocui{end+1} = onCleanup(@() jbi.close()); % Ensure safe closing of the compressed file in the end
        
        jci = com.github.luben.zstd.ZstdInputStream(jbi);
        ocui{end+1} = onCleanup(@() jci.close()); % Ensure safe closing of the compressed file in the end
    end
    function decompress_zst(),
        [~, entry_file, ~] = fileparts(file);
            
        % Test entry
        if ~accept_entry(entry_file),
            return;
        end
        
        % Accept entry
        files{end+1} = entry_file;
        
        if decompress,
            entry_size = NaN; % Get the entry data uncompressed size
            if DataSizes, % If true, then return only entry size and skip data decompression
                datas{end+1} = entry_size;
            else,
                entry_is = jci; % Get entry input stream
                datas{end+1} = decompress_entry(entry_is, entry_file, entry_size);
            end
        end
    end
    
    %% .zip decompressor
    function decompress_zip_construct(),
        jci = org.apache.tools.zip.ZipFile(jf);
        % Ensure safe closing of the compressed file in the end
        ocui{end+1} = onCleanup(@() jci.close());
    end
    function decompress_zip(),
        % Get the compressed file entries
        entries = jci.getEntries();
        
        % Loop through each file entry (and decompress only if needed)
        while entries.hasMoreElements(), % Stop loop only if no more entries
            entry = entries.nextElement(); % Get the next file entry
            if entry.isDirectory(), continue; end % Skip directories
            entry_file = char(entry.getName); % Get its file name (converted to char array)
            
            % Test entry
            if ~accept_entry(entry_file),
                continue;
            end
            
            % Accept entry
            files{end+1} = entry_file;
            
            if decompress,
                entry_size = entry.getSize(); % Get the entry data uncompressed size
                if DataSizes, % If true, then return only entry size and skip data decompression
                    datas{end+1} = entry_size;
                    continue;
                end
                
                % Extract entry input stream binary to MATLAB but without:
                % (a) java.io.ByteArrayOutputStream and com.mathworks.mlwidgets.io.InterruptibleStreamCopier.getInterruptibleStreamCopier().copyStream
                % (b) org.apache.commons.io.IOUtils().toByteArray % Available at least since R2011a
                % Instead use ReadableByteChannel of java.nio.channels
                % introduced with Java 1.4.
                entry_is = jci.getInputStream(entry); % Get entry input stream
                datas{end+1} = decompress_entry(entry_is, entry_file, entry_size);
            end
        end
    end
    
    %% Common helper functions
    function tf = accept_entry(entry_file),
        tf = true;
        
        % Skip entry if it does not meet the files filtering criteria
        if ~isempty(Files) && all(~strcmp(Files, entry_file)), % Test the file
            tf = false;
            return;
        end

        % Skip entry if it does not meet the file extension filtering criteria
        [~, ~, entry_ext] = fileparts(entry_file); % Extract its file extension
        if ~isempty(FilterExtension) && all(~strcmpi(FilterExtension, entry_ext)), % Test the file extension
            tf = false;
            return;
        end

        % Skip entry if it does not meet the file regexp filtering criteria
        if ~isempty(FilterRegexp) && isempty(regexp(entry_file, FilterRegexp{1}, 'start', 'once', FilterRegexp{2:end})), % Test the file
            tf = false;
            return;
        end
    end
    function entry_data = decompress_entry(entry_is, entry_file, entry_size),
        if nargin < 3 || isnan(entry_size),
            isknown = false;
            entry_size = jfi.available();
            if verbose,
                fprintf('Decompressing %d bytes of compressed binary from file entry: %s\n', entry_size, entry_file);
                [fun_start, fun_now, fun_end] = ProgressBar(entry_size, '-OnlyIncreasing', '-FlipStartEnd');
                fun_start(entry_size);
                ocu = onCleanup(fun_end); % Automatically call fun_end whenever end of function is reached
            end
        else,
            isknown = true;
            if verbose,
                fprintf('Decompressing %d bytes of uncompressed binary from file entry: %s\n', entry_size, entry_file);
                [fun_start, fun_now, fun_end] = ProgressBar(entry_size, '-OnlyIncreasing');
                fun_start(0);
                ocu = onCleanup(fun_end); % Automatically call fun_end whenever end of function is reached
            end
        end
        
        entry_rbc = java.nio.channels.Channels.newChannel(entry_is); % Get ReadableByteChannel that works with ByteBuffer!
        
        N_subblocks = ceil(MaxBlockSize./MaxSubBlockSize);
        if isknown && entry_size <= MaxBlockSize, % If known and fits in Java buffer, then read the entry data at once
            for jj = 1:N_subblocks,
                java_buffer.limit(java_buffer.position()+MaxSubBlockSize); % Limit read to MaxSubBlockSize
                N_read_subblock = entry_rbc.read(java_buffer); % Takes in ByteBuffer instead of byte []!
                if verbose,
                    fun_now(java_buffer.limit());
                end
                if N_read_subblock < MaxSubBlockSize, % Stop loop if last read
                    break;
                end
            end
            java_buffer.flip(); % Set limit to the current position and position to zero and discard mark
            N_read_block = java_buffer.remaining();
            java_buffer.clear(); % Reset position to zero, limit to capacity and discard mark
            matlab_buffer = java_buffer.array(); % Extract buffer content to MATLAB
            entry_data = matlab_buffer(1:N_read_block);
        else,
            % Read the entry data in blocks
            available = entry_size; % May or may not be exact
            N_blocks_allocated = ceil(available./MaxBlockSize);
            entry_data = zeros(MaxBlockSize, N_blocks_allocated, 'int8'); % First allocation
            N_read = 0;
            N_blocks = 0;
            while available > 0,
                N_blocks = N_blocks + 1;
                prev_available = available;
                for jj = 1:N_subblocks,
                    java_buffer.limit(java_buffer.position()+MaxSubBlockSize); % Limit read to MaxSubBlockSize
                    N_read_subblock = entry_rbc.read(java_buffer); % Takes in ByteBuffer instead of byte []!
                    if isknown, available = N_read + java_buffer.limit();
                    else, available = jfi.available(); end
                    if verbose,
                        fun_now(available);
                    end
                    if N_read_subblock < MaxSubBlockSize, % Stop loop if last read
                        break;
                    end
                end
                java_buffer.flip(); % Set limit to the current position and position to zero and discard mark
                N_read_block = java_buffer.remaining();
                java_buffer.clear(); % Reset position to zero, limit to capacity and discard mark
                N_read = N_read + N_read_block;
                if N_blocks > N_blocks_allocated,
                    ratio_global = N_read ./ (entry_size-available);
                    ratio_block = N_read_block ./ (prev_available-available);
                    ratio = sqrt(ratio_global.*ratio_block); % Geometric mean of global and local ratios
                    N_blocks_unallocated = ceil((N_read_block+available.*ratio)./MaxBlockSize);
                    entry_data(:,end+1:end+N_blocks_unallocated) = 0; % Reallocate
                    N_blocks_allocated = N_blocks_allocated + N_blocks_unallocated;
                end
                entry_data(:,N_blocks) = java_buffer.array(); % Extract buffer content to MATLAB
                if N_read_block ~= MaxBlockSize, break; end
            end
            
            % Truncate collected dataset on completion
            entry_data = [reshape(entry_data(:,1:N_blocks-1), [], 1); entry_data(1:N_read_block,N_blocks)];
        end
        
        entry_data = typecast(entry_data, 'uint8'); % From Java-friendly int8 to uint8
        
        if verbose,
            clear ocu;
        end
    end
end
