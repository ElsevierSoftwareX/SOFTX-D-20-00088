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
O_wit = WITio.core.wit.read(file{1});
if isempty(O_wit), return; end
fprintf('File = %s\nVersion = %d\n', file{1}, WITio.core.wip.get_Root_Version(O_wit));

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
C_static_tree = collapse(O_wit); % Fast to load because it is ONLY READ!
% C_dynamic_tree = WITio.core.debug(O_wit); % Slow to load because it is READ+WRITE!

% This function collapses the WIT tree structure into an all summarizing
% READ-only struct. This is an essential tool to reverse engineer new file
% versions for interoperability and implement them into MATLAB. If you want
% to have WRITE+READ version of this, then use debug-class instead.

% This code is deprecated and may be removed in the future revisions due to
% addition of wit-class 'DataTree_get' and 'DataTree_set' static functions.
function S = collapse(obj),
    S = struct();
    for ii = 1:numel(obj),
        Id = sprintf(sprintf('%%0%dd', floor(log10(numel(obj))+1)), ii);
        S.(['Tag_' Id]) = obj(ii);
        S.(['Name_' Id]) = obj(ii).Name;
        if isa(obj(ii).Data, 'WITio.core.wit'),
            S_sub = collapse(obj(ii).Data);
            C_sub = struct2cell(S_sub);
            subfields = cellfun(@(s) sprintf('%s_%s', ['Data_' Id], s), fieldnames(S_sub), 'UniformOutput', false);
            for jj = 1:numel(subfields),
                S.(subfields{jj}) = C_sub{jj};
            end
        else, S.(['Data_' Id]) = obj(ii).Data; end
    end
end
