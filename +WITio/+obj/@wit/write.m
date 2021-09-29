% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Tree can be saved to any file. First non-dashed char array input is
% always taken as target file. If not given, then Root's File is used.
% This can be customized with the following case-insensitive extra inputs:
% '-CustomFun' (= none by default): Can be used to provide call custom
% function for writing wit Tree object. This is used in wip-class write.
function write(obj, varargin), %#ok
    % Get Root only once
    Root = obj.Root;
    
    % First char array input is always File if non-dashed
    if nargin > 1 && ischar(varargin{1}) && ~strncmp(varargin{1}, '-', 1), %#ok
        File = varargin{1};
        if isempty(File), %#ok
            error('File must be a non-empty char array!');
        end
    else, %#ok % If not found, then use Root's File-property
        File = Root.File;
        if isempty(File), %#ok
            error('Root has no File specified! Provide File as a char array!');
        end
    end
    
    % Check if CustomFun was specified
    datas = WITio.fun.varargin_dashed_str.datas('CustomFun', varargin, -1);
    CustomFun = [];
    if numel(datas) > 0, CustomFun = datas{1}; end
    
    % Get file name
    [~, name, ext] = fileparts(File);
    FileName = [name ext];
    
    % Then write the root
    fprintf('\nWriting to file: %s\n', FileName);
    if isa(CustomFun, 'function_handle'), %#ok
        CustomFun(Root, File);
    else, %#ok
        % Disable automatic flushing using 'W'-flag instead of 'w'-flag: http://undocumentedmatlab.com/blog/improving-fwrite-performance
        fid = fopen(File, 'W'); % Instead of 'w'!
        if fid == -1 || isempty(fid), error('File (''%s'') cannot be opened for writing!', File); end
        
        % Close the file ONLY WHEN out of the function scope
        C = onCleanup(@() fclose(fid)); % https://blogs.mathworks.com/loren/2008/03/10/keeping-things-tidy/
        
        % Determine whether or not to use low-on-memory scheme
        lowOnMemory = false;
        try, %#ok % TRY TO FIT THE FILE CONTENT TO BUFFER IN MEMORY AT ONCE
            % Avoid call to builtin 'memory', which is Octave-incompatible!
            buffer = zeros(obj.End, 1, 'uint8'); %#ok % Preallocate the buffer OR ERROR IF LOW-ON-MEMORY!
            clear buffer;
        catch, %#ok % OTHERWISE USE LOW-ON-MEMORY SCHEME!
            lowOnMemory = true;
        end
        
        if ~lowOnMemory, %#ok % FIT THE FILE CONTENT TO BUFFER IN MEMORY AT ONCE
            fwrite(fid, obj.bwrite(), 'uint8');
        else, %#ok % OTHERWISE USE LOW-ON MEMORY SCHEME!
            Root.fwrite(fid);
        end
    end
    
    % On success, update wit Tree object root File-property
    Root.File = File;
end
