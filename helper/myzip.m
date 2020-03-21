% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Compress the given files and datas into an archive file using Java. This
% requires a running Java Virtual Machine. Current implementation is
% limited by Java heap memory size. Compression level ranges for DEFLATED
% from 0 (= none) to 9 (= maximum), which is set to 9 by default.
function myzip(file_zip, files, datas, compression_level),
    % MATLAB R2013b or newer supports 64-bit ZIP archives via Java Runtime
    % Environment 7 or newer.
    if nargin < 4, compression_level = 9; end % Maximum DEFLATED compression by default
    compression_level = min(max(compression_level, 0), 9);
    try,
        % Try compressing to the given file (or catch error)
        jfos = java.io.FileOutputStream(file_zip); % Open or create the file for writing
        jzos = java.util.zip.ZipOutputStream(jfos); % Create a ZIP output stream
        c_jzos = onCleanup(@() jzos.close()); % Ensure safe closing of the ZIP output stream and the stream being filtered in the end
        jzos.setLevel(compression_level); % Set DEFLATED compression level from 0 (= none) to 9 (= maximum)
        for ii = 1:numel(files), % Compress the given files and datas
            file = files{ii};
            data = datas{ii};
            entry = java.util.zip.ZipEntry(file); % Create a new ZIP file entry
            entry.setSize(numel(data)); % Set the uncompressed size of the entry data
            jzos.putNextEntry(entry); % Write a new ZIP file entry and position the stream to the start of the entry data
            jzos.write(data); % Write data as the current ZIP entry data
        end
        jzos.finish; % Finish writing the contents of the ZIP output stream without closing the underlying stream
    catch,
        warning('Cannot compress files and datas to ''%s'' for some reason!', file_zip);
    end
end
