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
if folder ~= 0, file_left = fullfile(folder, filename);
else, return; end % Abort as no file was selected!

% Read file wit-tags
O_wit_left = WITio.obj.wit.read(file_left{1});
if isempty(O_wit_left), return; end
fprintf('LEFT: File = %s\nVersion = %d\n', file_left{1}, WITio.obj.wip.get_Root_Version(O_wit_left));

[filename, folder] = uigetfile({'*.wip', 'WITec Project (*.WIP)'; '*.wid', 'WITec Data (*.WID)'; '*.*', 'WIT-formatted files (*.*)'}, 'Open Project', 'MultiSelect', 'off');
if ~iscell(filename), filename = {filename}; end
if folder ~= 0, file_right = fullfile(folder, filename);
else, return; end % Abort as no file was selected!

% Read file wit-tags
O_wit_right = WITio.obj.wit.read(file_right{1});
if isempty(O_wit_right), return; end
fprintf('RIGHT: File = %s\nVersion = %d\n', file_right{1}, WITio.obj.wip.get_Root_Version(O_wit_right));

[C_only_left, C_only_right, C_differ] = helper(O_wit_left, O_wit_right);

S_only_left = collapse(C_only_left);
S_only_right = collapse(C_only_right);
S_differ_left = collapse(C_differ(:,1));
S_differ_right = collapse(C_differ(:,2));

DT_left = WITio.obj.wit.DataTree_get(O_wit_left);
DT_right = WITio.obj.wit.DataTree_get(O_wit_right);

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
        if isa(obj(ii).Data, 'WITio.obj.wit'),
            S_sub = collapse(obj(ii).Data);
            C_sub = struct2cell(S_sub);
            subfields = cellfun(@(s) sprintf('%s_%s', ['Data_' Id], s), fieldnames(S_sub), 'UniformOutput', false);
            for jj = 1:numel(subfields),
                S.(subfields{jj}) = C_sub{jj};
            end
        else, S.(['Data_' Id]) = obj(ii).Data; end
    end
end

function [C_only_left, C_only_right, C_differ] = helper(C_left, C_right, level),
    if nargin < 3, level = 0; end
    C_only_left = WITio.obj.wit.empty;
    C_only_right = WITio.obj.wit.empty;
    C_differ = WITio.obj.wit.empty;
    str_offset = repmat(' ', [1 level]);
    
    % If left and right are not both wit, then do nothing
    if ~isa(C_left, 'WITio.obj.wit') || ~isa(C_right, 'WITio.obj.wit'), return; end
    
    Names1 = {C_left.FullName};
    Names2 = {C_right.FullName};
    unique_Names = unique([Names1 Names2]);
    
    for ii = 1:numel(unique_Names),
        unique_Name = unique_Names{ii};
        C_left_ii = C_left(strcmp(Names1, unique_Name));
        C_right_ii = C_right(strcmp(Names2, unique_Name));
        C_left_ii_Data = WITio.obj.wit.empty;
        C_right_ii_Data = WITio.obj.wit.empty;
        if ~isempty(C_left_ii), C_left_ii_Data = C_left_ii.Data; end
        if ~isempty(C_right_ii), C_right_ii_Data = C_right_ii.Data; end
        
        if ~isempty(C_left_ii) && ~isempty(C_right_ii), % Both exist
            if isa(C_left_ii_Data, 'WITio.obj.wit') && isa(C_right_ii_Data, 'WITio.obj.wit'), % Both Datas are wit
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
%             if isa(C_left_ii_Data, 'WITio.obj.wit'), % Left Data is wit
%                 [C_only_left_new, C_only_right_new, C_differ_new] = ...
%                     helper(C_left_ii_Data, WITio.obj.wit.empty, level+1);
%                 C_only_left = [C_only_left; C_only_left_new];
%                 C_only_right = [C_only_right; C_only_right_new];
%                 C_differ = [C_differ; C_differ_new];
%             else, % Left Data is not wit
                fprintf('%s %s %s\n', str_offset, regexprep(sprintf('%dx', size(C_left_ii_Data)), 'x$', ''), class(C_left_ii_Data));
%             end
        elseif ~isempty(C_right_ii), % Only right exists
            C_only_right = [C_only_right; C_right_ii];
            fprintf('%sONLY RIGHT: %s\n', str_offset, unique_Name);
%             if isa(C_right_ii_Data, 'WITio.obj.wit'), % Right Data is wit
%                 [C_only_left_new, C_only_right_new, C_differ_new] = ...
%                     helper(WITio.obj.wit.empty, C_right_ii_Data, level+1);
%                 C_only_left = [C_only_left; C_only_left_new];
%                 C_only_right = [C_only_right; C_only_right_new];
%                 C_differ = [C_differ; C_differ_new];
%             else, % Right Data is not wit
                fprintf('%s %s %s\n', str_offset, regexprep(sprintf('%dx', size(C_right_ii_Data)), 'x$', ''), class(C_right_ii_Data));
%             end
        end
    end
end
