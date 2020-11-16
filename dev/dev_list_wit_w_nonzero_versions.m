% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This helper script can be used to inspect NEW VERSIONS of tags in WIP-files!

% Also, analyze the tree structures visually by comparing two identical
% WIP-files saved under old and new formats (using official softwares).

[filename, folder] = uigetfile( ...
    {'*.wip;*.wiP;*.wIp;*.wIP;*.Wip;*.WiP;*.WIp;*.WIP', 'WITec Project (*.WIP)'; ... % Include all the case-sensitive permutations
    '*.wid;*.wiD;*.wId;*.wID;*.Wid;*.WiD;*.WId;*.WID', 'WITec Data (*.WID)'; ... % Include all the case-sensitive permutations
    '*.*', 'WIT-formatted files (*.*)'}, ...
    'Open Project', 'MultiSelect', 'off');
if ~iscell(filename), filename = {filename}; end
if folder ~= 0, file = fullfile(folder, filename);
else, return; end % Abort as no file was selected!

% Read file wit-tags
O_wit = wit.io.wit.read(file{1});
if isempty(O_wit), return; end
fprintf('File = %s\nVersion = %d\n', file{1}, wip.get_Root_Version(O_wit));

% Find tags with nonzero Versions
O_wit_w_version = O_wit.regexp('^Version<');
O_wit_w_nonzero_version = O_wit_w_version.match_by_Data_criteria(@(x) x ~= 0);

% Find names of the parents using regexp
str_Parent_Name = regexprep({O_wit_w_version.FullName}, '^Version<([^<]*)<?.*$', '$1');
str_Parent_Name_nonzero = regexprep({O_wit_w_nonzero_version.FullName}, '^Version<([^<]*)<?.*$', '$1');

% Keep only the unique-Parent-Name any and nonzero Versions
[~, ind_unique] = unique(str_Parent_Name);
UNIQUE_O_wit_w_version = O_wit_w_version(ind_unique);
[~, ind_unique_nonzero] = unique(str_Parent_Name_nonzero);
UNIQUE_O_wit_w_nonzero_version = O_wit_w_nonzero_version(ind_unique_nonzero);

% See the tree structure by double-clicking either variable under Workspace
C_static_tree = O_wit.collapse; % Fast to load because it is ONLY READ!
% C_dynamic_tree = wit_debug(O_wit); % Slow to load because it is READ+WRITE!
