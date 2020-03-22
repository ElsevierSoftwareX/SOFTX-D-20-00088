% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Unlike MATLAB's built-in unzip, uncompress filtered parts of the archive
% file directly in memory using Java. This requires a running Java Virtual
% Machine. Current implementation is limited by Java heap memory size. The
% following case-insensitive extra inputs are parsed:
% '-FilterExt' (= disabled by default): If enabled, then uncompress only
% the files (and datas) that match (case-insensitively) the given file
% extensions. Generates a cell array of char arrays (i.e. '.zip') from the
% consecutive inputs.
% '-MaxBlockSize' (= 67108864 or 64 MB by default): Set maximum blocksize
% per write to allow writing in smaller blocks and avoid Java Heap Memory
% limitation.
function [files, datas] = myunzip(file_zip, varargin),
    % It is noteworthy that the 64-bit ZIP archives (with individual
    % entries and archives larger than 4 GB or with more than 65536
    % entries) are supported since Apache Ant 1.9.0 (release date
    % 2013-03-07) and since Apache Commons Compress 1.3 (release date
    % 2011-11-01).
    %
    % Considered Java libraries with relevant zip toolbox functions:
    %
    % (1) Apache Ant (org.apache.tools.zip) % NEWEST LIBRARY VERSION
    % (a) ZipFile (and its member function getEntries).
    % https://ant.apache.org/manual/api/org/apache/tools/zip/package-summary.html
    % For instance, MATLAB R2011a and R2019b come with ant.jar or Apache
    % Ant 1.5.4 (release date 2003-08-12) and 1.9.9 (release date
    % 2017-02-06), respectively.
    %
    % (2) Apache Commons Compress (org.apache.commons.compress.archivers.zip)
    % (a) ZipFile (and its member function getEntries).
    % https://commons.apache.org/proper/commons-compress/examples.html
    % https://commons.apache.org/proper/commons-compress/zip.html
    % https://commons.apache.org/proper/commons-compress/apidocs/org/apache/commons/compress/archivers/zip
    % For instance, MATLAB R2011a and R2019b come with commons-compress.jar
    % or Apache Commons Compress 1.0 (release date 2009-05-21) and 1.8.1
    % (release date 2014-05-14), respectively.
    %
    % (3) Java (java.util.zip) % INFERIOR IMPLEMENTATION
    % (a) ZipFile (and its member function entries).
    % For instance, MATLAB R2011a and R2019b come with Java 1.6.0_17-b04
    % (release date 2009-05-21) and 1.8.0_202-b08 (release date
    % 2019-01-15), respectively.
    %
    % Decided to use (1) due to freshness (within MATLAB releases),
    % although the latest (2) Apache Commons Compress 1.20 (release date
    % 2020-02-08) comes with a useful "split ZIP archive" -feature but
    % MATLAB seriously lags behind the Commons Compress version.
    %
    % Also, use ReadableByteChannel of java.nio.channels introduced with
    % Java 1.4.
    
    % Parse extra inputs: FilterExt
    FilterExt = varargin_dashed_str_datas('FilterExt', varargin);
    
    % Parse extra inputs: MaxBlockSize
    parsed = varargin_dashed_str_datas('MaxBlockSize', varargin, -1);
%     MaxBlockSize = 64.*1024.^2; % By default, 64 MB max blocksize per write
    MaxBlockSize = ceil(java.lang.Runtime.getRuntime().freeMemory./2); % Consume half of the free Java Heap Memory
    java_buffer = java.nio.ByteBuffer.allocate(MaxBlockSize); % Preallocate once
    if numel(parsed) > 0, MaxBlockSize = parsed{1}; end
    
    files = {};
    datas = {};
    % Try uncompressing the files and datas (or catch error)
    try,
        % Open the ZIP file for reading
        jzf = org.apache.tools.zip.ZipFile(file_zip);
        
        % Ensure safe closing of the ZIP file in the end
        c_jzf = onCleanup(@() jzf.close());
        
        % Get the ZIP file entries
        entries = jzf.getEntries();
        
        % Loop through each ZIP file entry (and uncompress only if needed)
        while entries.hasMoreElements(), % Stop loop only if no more entries
            entry = entries.nextElement(); % Get the next ZIP file entry
            if entry.isDirectory(), continue; end % Skip directories
            entry_file = char(entry.getName); % Get its file name (converted to char array)
            
            % Accept entry if it meets the file extension filtering criteria
            [~, ~, entry_ext] = fileparts(entry_file); % Extract its file extension
            if isempty(FilterExt) || any(strcmpi(FilterExt, entry_ext)),
                files{end+1} = entry_file;
                
                entry_size = entry.getSize(); % Get the entry data uncompressed size
                
                % Extract entry input stream binary to MATLAB but without:
                % (a) java.io.ByteArrayOutputStream and com.mathworks.mlwidgets.io.InterruptibleStreamCopier.getInterruptibleStreamCopier().copyStream
                % (b) org.apache.commons.io.IOUtils().toByteArray % Available at least since R2011a
                entry_is = jzf.getInputStream(entry); % Get entry input stream
                entry_rbc = java.nio.channels.Channels.newChannel(entry_is); % Get ReadableByteChannel that works with ByteBuffer!
                if entry_size <= MaxBlockSize, % Read the entry data at once
                    N_read = entry_rbc.read(java_buffer);
                    java_buffer.rewind(); % Set position to zero and discard mark
                    matlab_buffer = java_buffer.array();
                    data = matlab_buffer(1:N_read);
                else, % Read the entry data in blocks
                    data = zeros(entry_size, 1, 'int8'); % Preallocate
                    N_blocks = ceil(entry_size ./ MaxBlockSize);
                    ind = 1:MaxBlockSize; % Preallocate once
                    for jj = 1:N_blocks,
                        N_read = entry_rbc.read(java_buffer);
                        java_buffer.rewind(); % Set position to zero and discard mark
                        matlab_buffer = java_buffer.array();
                        if jj < N_blocks,
                            data(ind) = matlab_buffer;
                            ind = ind + MaxBlockSize; % Update block indices
                        else,
                            ind = ind(ind <= entry_size); % Truncate block indices
                            data(ind) = matlab_buffer(1:N_read);
                        end
                    end
                end
                datas{end+1} = typecast(data, 'uint8');
            end
        end
    catch ME,
        warning('Cannot uncompress files and datas from ''%s'' for some reason!\n\n%s', file_zip, ME.message);
    end
    java.lang.Runtime.getRuntime().gc; % Garbage collection
end
