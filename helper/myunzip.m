% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Unlike MATLAB's built-in unzip, uncompress filtered parts of the archive
% file directly in memory using Java. This requires a running Java Virtual
% Machine. Current implementation is limited by Java heap memory size. If
% the 2nd input (= a char array or a cell array of char array, i.e. '.wip')
% is given, then the files and datas are filtered by their file extensions.
function [files, datas] = myunzip(file_zip, filter_ext),
    % MATLAB R2013b or newer supports 64-bit ZIP archives via Java Runtime
    % Environment 7 or newer.
    if nargin < 2, filter_ext = {}; end
    files = {};
    datas = {};
    try,
        % Try to open the given ZIP file for uncompression (or catch error)
        jzf = java.util.zip.ZipFile(file_zip); % Open the ZIP file for reading
        c_jzf = onCleanup(@() jzf.close()); % Ensure safe closing of the ZIP file in the end
        entries = jzf.entries(); % Get the ZIP file entries
        % Loop through each ZIP file entry (and uncompress only if needed)
        while entries.hasMoreElements(), % Stop loop only if no more entries
            entry = entries.nextElement(); % Get the next ZIP file entry
            entry_file = char(entry.getName); % Get its file name (converted to char array)
            [~, ~, entry_ext] = fileparts(entry_file); % Extract its file extension
            if iscell(filter_ext) && isempty(filter_ext) || any(strcmpi(filter_ext, entry_ext)), % Accept entry if it meets the file extension filtering criteria
                files{end+1} = entry_file;
                % Extract entry input stream binary to MATLAB but avoid using java.io.ByteArrayOutputStream and com.mathworks.mlwidgets.io.InterruptibleStreamCopier.getInterruptibleStreamCopier().copyStream
                entry_is = jzf.getInputStream(entry); % Get entry input stream
                datas{end+1} = org.apache.commons.io.IOUtils().toByteArray(entry_is); % Available at least since R2011a
            end
        end
    catch,
        warning('Cannot uncompress files and datas from ''%s'' for some reason! It may not exist or it is not a zip archive or it is encrypted or its compression method is not STORED nor DEFLATED!', file_zip);
    end
end
