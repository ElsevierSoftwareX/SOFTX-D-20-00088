% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This compresses file contents in blocks to local disk using Java. Current
% implementation can only compress to .zip and .zst (Zstd or Zstandard).
% Compression algorithm is automatically determined by the file extension.
% Zstandard is inherently multi-threaded and state-of-the-art algorithm.
% This requires a running Java Virtual Machine. The following case-
% insensitive extra inputs are parsed:
% '-Compressor' (= from file extension): Can be set to '.zip' or '.zst'.
% '-CompressionLevel' (= 1 by default): For .zip, compression level ranges
% from 0 (= none) to 9 (= maximum). For .zst, compression level ranges from
% 1 (= minimum) to 22 (= maximum).
% Provide [] to prefer Java library's default compression level.
% '-MaxBlockSize' (= from compressor): Set maximum blocksize per write to
% allow writing in smaller blocks and to reduce risk of exceeding Java Heap
% Memory (>= 128 MB for R2011a or newer) limit. For .zip, default value is
% 1048576 or 1 MB. For .zst, default value is 4194304 or 4 MB.
% '-ProgressBar' (= none): Use verbose wit.io.wit.progress_bar in Command
% Window. If a function handle (with equivalent output arguments) is
% provided, then use it instead.
function compress(file, files, datas, varargin),
    % Notes on zipping using Java:
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
    % (a) ZipOutputStream (and its member functions putNextEntry and
    % closeEntry), and (b) ZipEntry.
    % * Although this is the second best library, it is used in this code,
    % because it has relatively new version within MATLAB releases.
    % * https://ant.apache.org/manual/api/org/apache/tools/zip/package-summary.html
    % * For instance, MATLAB R2011a and R2019b come with ant.jar or Apache
    % Ant 1.5.4 (release date 2003-08-12) and 1.9.9 (release date
    % 2017-02-06), respectively.
    %
    % (2) Apache Commons Compress (org.apache.commons.compress.archivers.zip)
    % (a) ZipArchiveOutputStream (and its member functions putArchiveEntry
    % and closeArchiveEntry), and (b) ZipArchiveEntry.
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
    % (a) ZipOutputStream (and its member functions putNextEntry and
    % closeEntry), and (b) ZipEntry.
    % * Java's built-in tools are inferior to the two above.
    % * For instance, MATLAB R2011a and R2019b come with Java 1.6.0_17-b04
    % (release date 2009-05-21) and 1.8.0_202-b08 (release date
    % 2019-01-15), respectively.
    %
    % Decided to use (1) due to its freshness (within MATLAB releases),
    % although the latest (2) Apache Commons Compress 1.20 (release date
    % 2020-02-08) comes with a useful "split ZIP archive" -feature but
    % MATLAB seriously lags behind the Commons Compress version.
    
    jrt = java.lang.Runtime.getRuntime();
    
    % Parse extra inputs: Compressor
    parsed = wit.io.parse.varargin_dashed_str_datas('Compressor', varargin, -1);
    Compressor = []; % By default, determine compressor from the file extension
    if numel(parsed) > 0, Compressor = parsed{1}; end
    if isempty(Compressor), [~, ~, Compressor] = fileparts(file); end
    
    persistent zst_library;
    
    % Use ZIP compression
    if strcmpi('.zip', Compressor),
        MaxBlockSize = 1024.^2; % By default, 1 MB max subblocksize per write
        compressor_multiple_files = true;
        compressor_constructor = @compress_zip_construct;
        compressor = @compress_zip;
        compressor_finish = @compress_zip_finish;
    % Use ZST or Zstandard or Zstd compression
    elseif strcmpi('.zst', Compressor),
        MaxBlockSize = 4.*1024.^2; % By default, 4 MB max subblocksize per write
        % Documentation: https://www.javadoc.io/doc/com.github.luben/zstd-jni/latest/index.html
        if isempty(zst_library), % Load java library only once per session
            compressor_library = {'+lib', '+zstd-jni', 'zstd-jni-1.4.5-12.jar'};
            zst_library = fullfile(wit.io.path, compressor_library{:});
            javaaddpath(zst_library);
        end
        compressor_multiple_files = false;
        compressor_constructor = @compress_zst_construct;
        compressor = @compress_zst;
        compressor_finish = @compress_zst_finish;
    % Otherwise ERROR
    else,
        error('Specified compressor, ''%s'' is not yet implemented!', Compressor);
    end
    
    % Parse extra inputs: MaxBlockSize
    parsed = wit.io.parse.varargin_dashed_str_datas('MaxBlockSize', varargin, -1);
    if numel(parsed) > 0, MaxBlockSize = parsed{1}; end
    
    % Parse extra inputs: MaxSubBlockSize
    parsed = wit.io.parse.varargin_dashed_str_datas('MaxSubBlockSize', varargin, -1);
    if numel(parsed) > 0, MaxBlockSize = parsed{1}; end
    
    % Make 'files' and 'datas' a cell arrays if not so
    if ~iscell(files), files = {files}; end
    if ~iscell(datas), datas = {datas}; end
    
    % Error if trying to compress multiple files when not supported
    if ~compressor_multiple_files && numel(files) ~= 1,
        error('This compressor, ''%s'' can only compress a single file!', Compressor);
    end
    
    % Parse extra inputs: CompressionLevel
    parsed = wit.io.parse.varargin_dashed_str_datas('CompressionLevel', varargin, -1);
    CompressionLevel = 1; % By default, minimum compression
    if numel(parsed) > 0, CompressionLevel = parsed{1}; end
    
    % Parse extra inputs: ProgressBar
    [ProgressBar, parsed] = wit.io.parse.varargin_dashed_str_exists_and_datas('ProgressBar', varargin, -1);
    if ProgressBar, ProgressBar = @wit.io.wit.progress_bar; end
    if numel(parsed) > 0, ProgressBar = parsed{1}; end
    verbose = isa(ProgressBar, 'function_handle');
    
    % Try compressing the files and datas (or catch error)
    [jco, jbo, jfo] = deal([]);
    ocuo = {};
    try,
        % Open or create the file for writing
        compressor_constructor();
        
        % Compress the given files and datas
        compressor();
        
        % Finish writing the contents of the compressing output stream (and close the underlying stream on exit)
        compressor_finish();
        
        % Free variable for garbage collection
        clear ocuo;
    catch ME,
        warning('Cannot compress files and datas to ''%s'' for some reason!\n\n%s', file, ME.message);
    end
    
    % Invoke Java's garbage collection
    jrt.gc;
    
    %% .zst compressor
    function compress_zst_construct(),
        jfo = java.io.FileOutputStream(file);
        ocuo{3} = onCleanup(@() jfo.close()); % Ensure safe closing of the compressed file in the end
        
        jbo = java.io.BufferedOutputStream(jfo); % Required for faster performance!
        ocuo{2} = onCleanup(@() jbo.close()); % Ensure safe closing of the compressed file in the end
        
        jco = com.github.luben.zstd.ZstdOutputStream(jbo);
        ocuo{1} = onCleanup(@() jco.close()); % Ensure safe closing of the compressed file in the end
        
        % Set workers
        jco.setWorkers(jrt.availableProcessors()); % Use all processors as workers
        
        % Set compression level
        if ~isempty(CompressionLevel), % If empty, then use built-in default
            jco.setLevel(CompressionLevel);
        end
    end
    function compress_zst_finish(),
        
    end
    function compress_zst(),
        % Compress the given file and data
        entry_file = files{1};
        entry_data = typecast(datas{1}, 'int8'); % Java-friendly int8

        % Compress entry data
        compress_entry(entry_file, entry_data);
    end
    
    %% .zip compressor
    function compress_zip_construct(),
        jfo = java.io.FileOutputStream(file);
        ocuo{3} = onCleanup(@() jfo.close()); % Ensure safe closing of the compressed file in the end
        
        jbo = java.io.BufferedOutputStream(jfo); % Required for faster performance!
        ocuo{2} = onCleanup(@() jbo.close()); % Ensure safe closing of the compressed file in the end
        
        jco = org.apache.tools.zip.ZipOutputStream(jbo);
        ocuo{1} = onCleanup(@() jco.close()); % Ensure safe closing of the compressed file in the end
        
        % Set compression level
        if ~isempty(CompressionLevel), % If empty, then use built-in default
            jco.setLevel(CompressionLevel);
        end
    end
    function compress_zip_finish(),
%         jco.finish();
    end
    function compress_zip(),
        % Compress the given files and datas in loop
        for ii = 1:numel(files),
            entry_file = files{ii};
            entry_data = typecast(datas{ii}, 'int8'); % Java-friendly int8
            
            % Create a file entry
            entry = org.apache.tools.zip.ZipEntry(entry_file);
            entry.setSize(numel(entry_data)); % Set the uncompressed size of the entry data (i.e. to allow 64-bit ZIP if needed)
            
            % Write the entry headers and position the stream to the start of the entry data
            jco.putNextEntry(entry);
            
            % Compress entry data
            compress_entry(entry_file, entry_data);
            
            % Finish writing the contents of the entry
            jco.closeEntry();
        end
    end
    
    %% Common helper functions
    function compress_entry(entry_file, entry_data),
        N_data = numel(entry_data);
        N_data_end = mod(N_data, MaxBlockSize);
        entry_data_end = entry_data(N_data-N_data_end+1:end);
        entry_data = reshape(entry_data(1:N_data-N_data_end), MaxBlockSize, []);
        N_blocks = size(entry_data, 2);
        
        if verbose,
            fprintf('Compressing %d bytes of uncompressed binary to file entry: %s\n', N_data, entry_file);
            [fun_start, fun_now, fun_end] = ProgressBar(N_data, '-OnlyIncreasing');
            fun_start(0);
            ocu = onCleanup(fun_end); % Automatically call fun_end whenever end of function is reached
        end
        
        % Write the entry data in blocks
        for jj = 1:N_blocks,
            jco.write(entry_data(:,jj)); % Faster than ByteBuffer
            if verbose,
                fun_now(jj.*MaxBlockSize);
            end
        end
        
        % Write end of entry
        if N_data_end > 0,
            jco.write(entry_data_end); % Faster than ByteBuffer
            if verbose,
                fun_now(N_data);
            end
        end
        
        if verbose,
            clear ocu;
        end
    end
end
