% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This decompresses file contents in blocks directly to memory using Java.
% If second output is omitted, then this will only decompress the file
% names. Current implementation can only decompress ZIP archives. Unlike
% MATLAB's built-in unzip, this can also filter which file contents to
% decompress. This requires a running Java Virtual Machine. The following
% case-insensitive extra inputs are parsed:
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
% '-MaxBlockSize' (= 1048576 or 1 MB by default): Set maximum blocksize
% per read to allow reading in smaller blocks and to reduce risk of
% exceeding Java Heap Memory (>= 128 MB for R2011a or newer) limit.
% '-ProgressBar' (= none): Use verbose wit.progress_bar in Command
% Window. If a function handle (with equivalent output arguments) is
% provided, then use it instead.
function [files, datas] = wit_io_file_decompress(file, varargin),
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
    if nargout > 1,
        datas = {};
    end
    
    % Test if the file exists
    jf = java.io.File(file);
    if ~jf.exists(), return; end % Abort if does not exist
    
    % Parse extra inputs: MaxBlockSize
    parsed = varargin_dashed_str_datas('MaxBlockSize', varargin, -1);
    MaxBlockSize = 1024.^2; % By default, 1 MB max blocksize per read
    if numel(parsed) > 0, MaxBlockSize = parsed{1}; end
    
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
    if ProgressBar, ProgressBar = @wit.progress_bar; end
    if numel(parsed) > 0, ProgressBar = parsed{1}; end
    verbose = isa(ProgressBar, 'function_handle');
    
    % Try uncompressing the files and datas (or catch error)
    try,
        % Open the ZIP file for reading
        jzf = org.apache.tools.zip.ZipFile(jf);
        
        % Ensure safe closing of the ZIP file in the end
        c_jzf = onCleanup(@() jzf.close());
        
        % Get the ZIP file entries
        entries = jzf.getEntries();
        
        if nargout > 1,
            % Preallocate Java buffer once
            java_buffer = java.nio.ByteBuffer.allocate(MaxBlockSize);
        end
        
        % Loop through each ZIP file entry (and decompress only if needed)
        while entries.hasMoreElements(), % Stop loop only if no more entries
            entry = entries.nextElement(); % Get the next ZIP file entry
            if entry.isDirectory(), continue; end % Skip directories
            entry_file = char(entry.getName); % Get its file name (converted to char array)
            
            % Skip entry if it does not meet the files filtering criteria
            if ~isempty(Files) && all(~strcmp(Files, entry_file)), % Test the file
                continue;
            end
            
            % Skip entry if it does not meet the file extension filtering criteria
            [~, ~, entry_ext] = fileparts(entry_file); % Extract its file extension
            if ~isempty(FilterExtension) && all(~strcmpi(FilterExtension, entry_ext)), % Test the file extension
                continue;
            end
            
            % Skip entry if it does not meet the file regexp filtering criteria
            if ~isempty(FilterRegexp) && isempty(regexp(entry_file, FilterRegexp{1}, 'start', 'once', FilterRegexp{2:end})), % Test the file
                continue;
            end
            
            % Accept entry
            files{end+1} = entry_file;
            if nargout > 1,
                entry_size = entry.getSize(); % Get the entry data uncompressed size
                if DataSizes, % If true, then return only entry size and skip data decompression
                    datas{end+1} = entry_size;
                    continue;
                end
                
                if verbose,
                    fprintf('Decompressing %d bytes of binary from file entry: %s\n', entry_size, entry_file);
                    [fun_start, fun_now, fun_end] = ProgressBar(entry_size);
                    fun_start(0);
                    ocu = onCleanup(fun_end); % Automatically call fun_end whenever end of function is reached
                end
                
                % Extract entry input stream binary to MATLAB but without:
                % (a) java.io.ByteArrayOutputStream and com.mathworks.mlwidgets.io.InterruptibleStreamCopier.getInterruptibleStreamCopier().copyStream
                % (b) org.apache.commons.io.IOUtils().toByteArray % Available at least since R2011a
                % Instead use ReadableByteChannel of java.nio.channels
                % introduced with Java 1.4.
                entry_is = jzf.getInputStream(entry); % Get entry input stream
                entry_rbc = java.nio.channels.Channels.newChannel(entry_is); % Get ReadableByteChannel that works with ByteBuffer!
                if entry_size <= MaxBlockSize, % Read the entry data at once
                    N_read = entry_rbc.read(java_buffer); % Takes in ByteBuffer instead of byte []!
                    matlab_buffer = java_buffer.array(); % Extract buffer content to MATLAB
                    java_buffer.rewind(); % Reset buffer position to zero and discard mark
                    data = matlab_buffer(1:N_read);
                    if verbose,
                        fun_now(entry_size);
                    end
                else, % Read the entry data in blocks
                    data = zeros(entry_size, 1, 'int8'); % Preallocate
                    N_blocks = ceil(entry_size ./ MaxBlockSize);
                    ind = 1:MaxBlockSize; % Preallocate block indices once
                    for jj = 1:N_blocks,
                        N_read = entry_rbc.read(java_buffer); % Takes in ByteBuffer instead of byte []!
                        matlab_buffer = java_buffer.array(); % Extract buffer content to MATLAB
                        java_buffer.rewind(); % Reset position to zero and discard mark
                        if jj < N_blocks,
                            data(ind) = matlab_buffer;
                            ind = ind + MaxBlockSize; % Update block indices for next read
                        else,
                            ind = ind(ind <= entry_size); % Truncate block indices for last read
                            data(ind) = matlab_buffer(1:N_read);
                        end
                        if verbose,
                            fun_now(ind(end));
                        end
                    end
                end
                datas{end+1} = typecast(data, 'uint8');
                if verbose,
                    clear ocu;
                end
            end
        end
        
        if nargout > 1,
            % Invoke Java's garbage collection
            clear java_buffer; % Free variable from Java Heap Memory
            java.lang.Runtime.getRuntime().gc;
        end
        
        clear c_jzf; % Ensure the underlying stream is closed before the ZipFile object is cleared to avoid "Cleaning up unclosed ZipFile for archive"-warning (except when file does not exist due to bug)
    catch ME,
        warning('Cannot uncompress files and datas from ''%s'' for some reason!\n\n%s', file, ME.message);
    end
end
