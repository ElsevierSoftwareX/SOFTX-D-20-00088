% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Quickly get the file Versions. This can be applied even on hundreds of
% files at once. If no 'files' are given, then it opens a folder selection
% dialog box.
function [versions, files] = get_Versions(files),
    if nargin == 0, files = WITio.dev.get_dir_files_recursively(); end
    
    % Keep only *.wip and *.wid files
    [~, ~, ext] = cellfun(@fileparts, files, 'UniformOutput', false);
    B_wit = strcmpi(ext, '.wip') | strcmpi(ext, '.wid');
    files = files(B_wit);
    
    % Open such files and collect Version-statistics
    versions = nan(size(files));
    for ii = 1:numel(files),
        fprintf('File %d/%d OR %s:\n', ii, numel(files), files{ii});
        Version = WITio.obj.wip.read_Version(files{ii});
        if ~isempty(Version), versions(ii) = Version; end
        fprintf('Version = %d\n', versions(ii));
    end
end
