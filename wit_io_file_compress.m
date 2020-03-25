% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This compresses file contents in blocks to local disk using Java. Current
% implementation can only compress ZIP archives. This requires a running
% Java Virtual Machine. The following case-insensitive extra inputs are
% parsed:
% '-CompressionLevel' (= 9 by default): Compression level ranges for
% DEFLATED from 0 (= none) to 9 (= maximum).
% '-MaxBlockSize' (= 67108864 or 64 MB by default): Set maximum blocksize
% per write to allow writing in smaller blocks and to reduce risk of
% exceeding Java Heap Memory (>= 128 MB for R2011a or newer) limit.
function wit_io_file_compress(file, files, datas, varargin),
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
    
    % Parse extra inputs: MaxBlockSize
    parsed = varargin_dashed_str_datas('MaxBlockSize', varargin, -1);
    MaxBlockSize = 64.*1024.^2; % By default, 64 MB max blocksize per write
    if numel(parsed) > 0, MaxBlockSize = parsed{1}; end
    
    % Make 'files' and 'datas' a cell arrays if not so
    if ~iscell(files), files = {files}; end
    if ~iscell(datas), datas = {datas}; end
    
    % Parse extra inputs: CompressionLevel
    parsed = varargin_dashed_str_datas('CompressionLevel', varargin, -1);
    CompressionLevel = 9; % By default, maximum compression
    if numel(parsed) > 0, CompressionLevel = parsed{1}; end
    
    % Try compressing the files and datas (or catch error)
    try,
        % Open or create the file for writing
        jfos = java.io.FileOutputStream(file);
        
        % Ensure safe closing of all the output streams in the end
        oc = onCleanup(@() jfos.close());
        
        % Create a ZIP output stream
        jzos = org.apache.tools.zip.ZipOutputStream(jfos);
        
        % Set DEFLATED compression level from 0 (= none) to 9 (= maximum)
        jzos.setLevel(CompressionLevel);
        
        % Compress the given files and datas in loop
        for ii = 1:numel(files),
            file = files{ii};
            data = typecast(datas{ii}, 'uint8');
            
            % Create a ZIP file entry
            entry = org.apache.tools.zip.ZipEntry(file);
            entry_size = numel(data);
            entry.setSize(entry_size); % Set the uncompressed size of the entry data (to allow 64-bit ZIP if needed)
            
            % Write the ZIP file entry to the ZIP output stream
            jzos.putNextEntry(entry); % Write the entry headers and position the stream to the start of the entry data
            if entry_size <= MaxBlockSize, % Write the entry data at once
                jzos.write(data);
            else, % Write the entry data in blocks
                N_blocks = ceil(entry_size ./ MaxBlockSize);
                ind = 1:MaxBlockSize; % Preallocate block indices once
                for jj = 1:N_blocks,
                    if jj < N_blocks,
                        jzos.write(data(ind));
                        ind = ind + MaxBlockSize; % Update block indices for next write
                    else,
                        ind = ind(ind <= entry_size); % Truncate block indices for last write
                        jzos.write(data(ind));
                    end
                end
            end
            jzos.closeEntry(); % Finish writing the contents of the entry
        end
        
        % Finish writing the contents of the ZIP output stream (and close the underlying stream on exit)
        jzos.finish();
    catch ME,
        warning('Cannot compress files and datas to ''%s'' for some reason!\n\n%s', file, ME.message);
    end
    
    % Invoke Java's garbage collection
    java.lang.Runtime.getRuntime().gc;
end
