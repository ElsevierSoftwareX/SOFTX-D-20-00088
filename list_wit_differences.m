% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This helper script can be used to inspect NEW VERSIONS of tags in WIP-files!

% Also, analyze the tree structures visually by comparing two identical
% WIP-files saved under old and new formats (using official softwares).

[filename, folder] = uigetfile({'*.wip', 'WITec Project (*.WIP)'; '*.wid', 'WITec Data (*.WID)'; '*.*', 'WIT-formatted files (*.*)'}, 'Open Project', 'MultiSelect', 'off');
if ~iscell(filename), filename = {filename}; end
if folder ~= 0, file_left = fullfile(folder, filename);
else, return; end % Abort as no file was selected!

% Read file wit-tags
O_wit_left = wit.read(file_left{1});
if isempty(O_wit_left), return; end
fprintf('LEFT: File = %s\nVersion = %d\n', file_left{1}, wip.get_Root_Version(O_wit_left));

[filename, folder] = uigetfile({'*.wip', 'WITec Project (*.WIP)'; '*.wid', 'WITec Data (*.WID)'; '*.*', 'WIT-formatted files (*.*)'}, 'Open Project', 'MultiSelect', 'off');
if ~iscell(filename), filename = {filename}; end
if folder ~= 0, file_right = fullfile(folder, filename);
else, return; end % Abort as no file was selected!

% Read file wit-tags
O_wit_right = wit.read(file_right{1});
if isempty(O_wit_right), return; end
fprintf('RIGHT: File = %s\nVersion = %d\n', file_right{1}, wip.get_Root_Version(O_wit_right));

[C_only_left, C_only_right, C_differ] = helper(O_wit_left, O_wit_right);

S_only_left = C_only_left.collapse;
S_only_right = C_only_right.collapse;
S_differ_left = C_differ(:,1).collapse;
S_differ_right = C_differ(:,2).collapse;

DT_left = wit.DataTree_get(O_wit_left);
DT_right = wit.DataTree_get(O_wit_right);

function [C_only_left, C_only_right, C_differ] = helper(C_left, C_right, level),
    if nargin < 3, level = 0; end
    C_only_left = wit.empty;
    C_only_right = wit.empty;
    C_differ = wit.empty;
    str_offset = repmat(' ', [1 level]);
    
    % If left and right are not both wit, then do nothing
    if ~isa(C_left, 'wit') || ~isa(C_right, 'wit'), return; end
    
    Names1 = {C_left.FullName};
    Names2 = {C_right.FullName};
    unique_Names = unique([Names1 Names2]);
    
    for ii = 1:numel(unique_Names),
        unique_Name = unique_Names{ii};
        C_left_ii = C_left(strcmp(Names1, unique_Name));
        C_right_ii = C_right(strcmp(Names2, unique_Name));
        C_left_ii_Data = wit.empty;
        C_right_ii_Data = wit.empty;
        if ~isempty(C_left_ii), C_left_ii_Data = C_left_ii.Data; end
        if ~isempty(C_right_ii), C_right_ii_Data = C_right_ii.Data; end
        
        if ~isempty(C_left_ii) && ~isempty(C_right_ii), % Both exist
            if isa(C_left_ii_Data, 'wit') && isa(C_right_ii_Data, 'wit'), % Both Datas are wit
                [C_only_left_new, C_only_right_new, C_differ_new] = ...
                    helper(C_left_ii_Data, C_right_ii_Data, level+1); % Step down one level
                C_only_left = [C_only_left; C_only_left_new];
                C_only_right = [C_only_right; C_only_right_new];
                C_differ = [C_differ; C_differ_new];
            elseif ~isa(C_left_ii_Data, class(C_right_ii_Data)) || numel(C_left_ii_Data) ~= numel(C_right_ii_Data) || any(C_left_ii_Data(:) ~= C_right_ii_Data(:)),
                C_differ = [C_differ; C_left_ii C_right_ii];
                fprintf('%sDIFFER: %s\n', str_offset, unique_Name);
                fprintf('%s %s %s vs. %s %s\n', str_offset, regexprep(sprintf('%dx', size(C_left_ii_Data)), 'x$', ''), class(C_left_ii_Data), regexprep(sprintf('%dx', size(C_right_ii_Data)), 'x$', ''), class(C_right_ii_Data));
            end
        elseif ~isempty(C_left_ii), % Only left exists
            C_only_left = [C_only_left; C_left_ii];
            fprintf('%sONLY LEFT: %s\n', str_offset, unique_Name);
%             if isa(C_left_ii_Data, 'wit'), % Left Data is wit
%                 [C_only_left_new, C_only_right_new, C_differ_new] = ...
%                     helper(C_left_ii_Data, wit.empty, level+1);
%                 C_only_left = [C_only_left; C_only_left_new];
%                 C_only_right = [C_only_right; C_only_right_new];
%                 C_differ = [C_differ; C_differ_new];
%             else, % Left Data is not wit
                fprintf('%s %s %s\n', str_offset, regexprep(sprintf('%dx', size(C_left_ii_Data)), 'x$', ''), class(C_left_ii_Data));
%             end
        elseif ~isempty(C_right_ii), % Only right exists
            C_only_right = [C_only_right; C_right_ii];
            fprintf('%sONLY RIGHT: %s\n', str_offset, unique_Name);
%             if isa(C_right_ii_Data, 'wit'), % Right Data is wit
%                 [C_only_left_new, C_only_right_new, C_differ_new] = ...
%                     helper(wit.empty, C_right_ii_Data, level+1);
%                 C_only_left = [C_only_left; C_only_left_new];
%                 C_only_right = [C_only_right; C_only_right_new];
%                 C_differ = [C_differ; C_differ_new];
%             else, % Right Data is not wit
                fprintf('%s %s %s\n', str_offset, regexprep(sprintf('%dx', size(C_right_ii_Data)), 'x$', ''), class(C_right_ii_Data));
%             end
        end
    end
end
