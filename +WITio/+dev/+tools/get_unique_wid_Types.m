% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Quickly get all the unique wid-class Types in the files. If no 'files'
% are given, then it opens a folder selection dialog box. It also returns
% a 2-D boolean matrix, in which columns represent files and rows represent
% all the unique wid-class Types. This can be used to find certain kinds of
% files quickly among hundreds of files.
function [unique_wid_Types, B_diversity_matrix, versions, files] = get_unique_wid_Types(files),
    if nargin == 0, files = WITio.dev.tools.get_dir_files_recursively(); end
    
    % Keep only *.wip and *.wid files
    [~, ~, ext] = cellfun(@fileparts, files, 'UniformOutput', false);
    B_wit = strcmpi(ext, '.wip') | strcmpi(ext, '.wid');
    files = files(B_wit);
    
    % Open such files and collect DataClassName-statistics
    unique_wid_Types_per_file = cell(size(files));
    versions = nan(size(files));
    for ii = 1:numel(files),
        fprintf('\nFile %d/%d OR %s:\n', ii, numel(files), files{ii});
        O_wit = WITio.obj.wit.read(files{ii}, 4096, @skip_Data_criteria_for_obj);
        Version = WITio.obj.wip.get_Root_Version(O_wit);
        if ~isempty(Version), versions(ii) = Version; end
        Tag_Data = O_wit.regexp('^Data(<WITec (Project|Data))?$', true);
        DataClassNames = Tag_Data.search({'^DataClassName \d+$'}, 'Data');
        unique_wid_Types_per_file{ii} = unique({DataClassNames.Data});
        fprintf('Number of unique wid Types = %d\n', numel(unique_wid_Types_per_file{ii}));
        fprintf('Unique wid Types = %s\n', mystrjoin(unique_wid_Types_per_file{ii}, ', '));
    end
    
    % Generate the diversity matrix
    unique_wid_Types = unique([unique_wid_Types_per_file{:}]);
    if isempty(unique_wid_Types), unique_wid_Types = {}; end % Handle case of no unique wid Types
    unique_wid_Types = reshape(unique_wid_Types, 1, []); % Force row column
    fprintf('\nNumber of all unique wid Types = %d\n', numel(unique_wid_Types));
    fprintf('All unique wid Types = %s\n', mystrjoin(unique_wid_Types, ', '));
    B_diversity_matrix = false(numel(files), numel(unique_wid_Types));
    for ii = 1:numel(unique_wid_Types),
        B_diversity_matrix(:,ii) = cellfun(@(s) any(strcmp(s, unique_wid_Types{ii})), unique_wid_Types_per_file);
    end
    
    % This skip Data criteria enables much faster file reading!
    function tf = skip_Data_criteria_for_obj(O_wit),
        tf = isempty(O_wit.regexp('^(((DataClassName \d+<)?Data|Version)<)?WITec (Project|Data)$', true));
    end
end
