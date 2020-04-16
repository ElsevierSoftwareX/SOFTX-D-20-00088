% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Project can be saved as *.wip, *.wid (and compressed as *.zip). File
% extensions are case-insensitive. First non-dashed char array input is
% always taken as target file. If not given, then Project's File is used.
% This can be customized with the following case-insensitive extra inputs:
% '-Params' (= none by default): Can be used to provide parameters to the
% underlying writing function, i.e. wit_io_file_compress.m. See its
% documentation for more details.
function write(obj, varargin),
    % First char array input is always File if non-dashed
    if nargin > 1 && ischar(varargin{1}) && ~strncmp(varargin{1}, '-', 1),
        File = varargin{1};
        if isempty(File),
            error('File must be a non-empty char array!');
        end
    else, % If not found, then use Project's File-property
        File = obj.File;
        if isempty(File),
            error('Project has no File specified! Provide File as a char array!');
        end
    end
    
    % Check if Params was specified
    Params = varargin_dashed_str_datas('Params', varargin);
    
    % Determine the required file extension
    switch(obj.Type),
        case 'WITec Project',
            required_ext = '.wip';
        case 'WITec Data',
            required_ext = '.wid';
        otherwise,
            required_ext = '';
    end
    
    % Determine the compressed file extension
    compressed_ext = '.zip';
    
    % Add the required file extension if it is missing nor is compression used
    [~, ~, ext] = fileparts(File);
    OnWriteCompress = strcmpi(ext, compressed_ext);
    if OnWriteCompress,
        File_uncompressed = regexprep(File, ['(\' compressed_ext ')$'], required_ext, 'ignorecase');
    elseif ~strcmpi(ext, required_ext),
        File = [File required_ext];
        warning('Adding expected ''%s'' file extension!', required_ext);
    end
    
    if obj.OnWriteDestroyAllViewers,
        obj.destroy_all_Viewers;
    end
    
    if obj.OnWriteDestroyDuplicateTransformations,
        obj.destroy_duplicate_Transformations;
    end
    
    if OnWriteCompress, % Write compressed
        obj.Tree.write(File, '-CustomFun', @OnWriteCompress_helper);
    else, % Write uncompressed
        obj.Tree.write(File);
    end
    
    function OnWriteCompress_helper(obj, File),
        wit_io_file_compress(File, File_uncompressed, obj.bwrite(), '-ProgressBar', Params{:}); % Compress binary to zip archive
    end
end
