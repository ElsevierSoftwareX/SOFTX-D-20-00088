file = 'example_04_write_customized_data.zip';

% https://undocumentedmatlab.com/blog/savezip-utility

[~, ~, ext] = fileparts(file);
if strcmpi(ext, '.zip'), % Test if extension indicates a zip file
    % Create Java file
    JavaFile = java.io.File(file); % Used by MATLAB built-in functions
    % Create ZipFile stream
    ZipFile = org.apache.tools.zip.ZipFile(JavaFile); % Used by MATLAB built-in functions
    % Create StreamCopier
    StreamCopier = com.mathworks.mlwidgets.io.InterruptibleStreamCopier.getInterruptibleStreamCopier; % Used by MATLAB built-in functions
    % Loop through each ZipFile file entry (without unzipping)
    Entries = ZipFile.getEntries; % Used by MATLAB built-in functions
    Files = {};
    Datas = {};
    while Entries.hasMoreElements, % Continue loop if more file entries
        % Get the next file entry and its name
        Entry = Entries.nextElement(); % Used by MATLAB built-in functions
        Name = char(Entry.getName); % Used by MATLAB built-in functions
        [~, ~, entry_ext] = fileparts(Name);
        if strcmpi(entry_ext, '.wip') || strcmpi(entry_ext, '.wid'),
            Files{end+1} = Name;
            % Create InputStream for the current file entry
            InputStream = ZipFile.getInputStream(Entry);
            % Create ByteArrayOutputStream to extract binary to MATLAB
            BAOS = java.io.ByteArrayOutputStream;
            StreamCopier.copyStream(InputStream, BAOS); % Used by MATLAB built-in functions
            % Get uint8 array from the stream
            Datas{end+1} = BAOS.toByteArray;
            % Close the streams
            BAOS.close;
            InputStream.close; % Used by MATLAB built-in functions
        end
    end
    % Close the stream
    ZipFile.close; % Used by MATLAB built-in functions
end
