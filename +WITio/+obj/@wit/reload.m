% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function reload(obj),
    if ~isempty(obj) && ~isempty(obj.File) && obj.HasData,
        % Try to open file or abort
        fid = fopen(obj.File, 'r');
        if isempty(fid) || fid == -1, error('File (''%s'') cannot be opened for reading!', obj.File); end
        
        % Close the file ONLY WHEN out of the function scope
        C = onCleanup(@() fclose(fid)); % https://blogs.mathworks.com/loren/2008/03/10/keeping-things-tidy/
        
        obj.fread_Data(fid); % Reloads if obj.Type ~= 0
    end
end
