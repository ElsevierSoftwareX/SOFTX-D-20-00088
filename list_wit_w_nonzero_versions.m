% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This helper script can be used to inspect NEW VERSIONS of tags in WIP-files!

% Also, analyze the tree structures visually by comparing two identical
% WIP-files saved under old and new formats (using official softwares).

[filename, folder] = uigetfile({'*.wip', 'WITec Project (*.WIP)'; '*.wid', 'WITec Data (*.WID)'; '*.*', 'WIT-formatted files (*.*)'}, 'Open Project', 'MultiSelect', 'off');
if ~iscell(filename), filename = {filename}; end
if folder ~= 0, file = fullfile(folder, filename);
else, return; end % Abort as no file was selected!

% Read file wit-tags
C_wit = wit.read(file{1});
if isempty(C_wit), return; end
fprintf('File = %s\nVersion = %d\n', file{1}, wip.get_Root_Version(C_wit));

% Find tags with nonzero Versions
C_wit_w_version = C_wit.regexp('^Version<');
C_wit_w_nonzero_version = C_wit_w_version.match_by_Data_criteria(@(x) x ~= 0);

% Find names of the parents using regexp
str_Parent_Name = regexprep({C_wit_w_version.FullName}, '^Version<([^<]*)<?.*$', '$1');
str_Parent_Name_nonzero = regexprep({C_wit_w_nonzero_version.FullName}, '^Version<([^<]*)<?.*$', '$1');

% Keep only the unique-Parent-Name any and nonzero Versions
[~, ind_unique] = unique(str_Parent_Name);
UNIQUE_C_wit_w_version = C_wit_w_version(ind_unique);
[~, ind_unique_nonzero] = unique(str_Parent_Name_nonzero);
UNIQUE_C_wit_w_nonzero_version = C_wit_w_nonzero_version(ind_unique_nonzero);

% See the tree structure by double-clicking either variable under Workspace
C_static_tree = C_wit.collapse; % Fast to load because it is ONLY READ!
% C_dynamic_tree = wit_debug(C_wit); % Slow to load because it is READ+WRITE!
