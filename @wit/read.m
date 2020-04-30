% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Tree can be loaded from any file. This can be customized with the
% following case-insensitive extra inputs:
% '-CustomFun' (= none by default): Can be used to provide call custom
% function for writing wit Tree object. This is used in wip-class read.
function obj = read(File, N_bytes_max, skip_Data_criteria_for_obj, error_criteria_for_obj, varargin),
    % Reads a WIP-formatted tag from the given file stream.
    % Reading can be limited by N_bytes_max (if low on memory).
    if nargin < 2, N_bytes_max = Inf; end % By default: no read limit!
    if nargin < 3, skip_Data_criteria_for_obj = []; end % By default: no criteria!
    if nargin < 4, error_criteria_for_obj = []; end % By default: no criteria!
    
    % Check if CustomFun was specified
    datas = varargin_dashed_str_datas('CustomFun', varargin, -1);
    CustomFun = [];
    if numel(datas) > 0, CustomFun = datas{1}; end
    
    % Check if Silent was specified
    Silent = varargin_dashed_str_exists('Silent', varargin);
    
    % Try to get full path from relative path.
    FileFull = which(File); % This might fail for network addresses
    if ~isempty(FileFull), File = FileFull; end % Update only if not failed
    
    % Get file name
    [~, name, ext] = fileparts(File);
    FileName = [name ext];
    
    % Construct the wit Tree root object
    obj = wit();
    
    % Then read the file
    if ~Silent,
        fprintf('\nReading from file: %s\n', FileName);
    end
    if isa(CustomFun, 'function_handle'),
        CustomFun(obj, File);
    else,
        % Try to open file
        fid = fopen(File, 'r');
        if isempty(fid) || fid == -1, error('File (''%s'') cannot be opened for reading!', File); end
        
        % Close the file ONLY WHEN out of the function scope
        C = onCleanup(@() fclose(fid)); % https://blogs.mathworks.com/loren/2008/03/10/keeping-things-tidy/
        
        % Get file size
        fseek(fid, 0, 'eof'); % Go to end of file
        FileSize = ftell(fid); % Get file size
        fseek(fid, 0, 'bof'); % Return to beginning of file
        
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
        
        if ~lowOnMemory, % FIT THE FILE CONTENT TO BUFFER IN MEMORY AT ONCE
            buffer = fread(fid, Inf, 'uint8=>uint8'); % Read the file content to the buffer
            obj.bread(buffer, N_bytes_max, [], skip_Data_criteria_for_obj, error_criteria_for_obj); % Parse the file content in the buffer
        else, % OTHERWISE USE LOW-ON-MEMORY SCHEME!
            if isinf(N_bytes_max), N_bytes_max = 4096; end % Do not obey infinite N_bytes_max here!
            obj.fread(fid, N_bytes_max, [], skip_Data_criteria_for_obj, error_criteria_for_obj);
        end
    end
    
    % On success, update wit Tree object root File-property
    obj.File = File;
end
