% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Quickly get all the unique wit-class Names in the files. If no 'files'
% are given, then it opens a folder selection dialog box. It also returns
% a 2-D boolean matrix, in which columns represent files and rows represent
% all the unique wit-class Names. This can be used to find certain kinds of
% files quickly among hundreds of files.
function [unique_wit_Names, B_diversity_matrix, versions, files] = get_unique_wit_Names(files),
    if nargin == 0, files = WITio.dev.tools.get_dir_files_recursively(); end
    
    % Keep only *.wip and *.wid files
    [~, ~, ext] = cellfun(@fileparts, files, 'UniformOutput', false);
    B_wit = strcmpi(ext, '.wip') | strcmpi(ext, '.wid');
    files = files(B_wit);
    
    % Open such files and collect Name-statistics
    unique_wit_Names_per_file = cell(size(files));
    versions = nan(size(files));
    for ii = 1:numel(files),
        fprintf('\nFile %d/%d OR %s:\n', ii, numel(files), files{ii});
        O_wit = WITio.obj.wit.read(files{ii}, 4096, @(O_wit) O_wit.Type ~= 0); % This skip Data criteria enables much faster file reading!
        Version = WITio.obj.wip.get_Root_Version(O_wit);
        if ~isempty(Version), versions(ii) = Version; end
        Descendants = O_wit;
        Names = {O_wit.Name};
        while ~isempty(Descendants),
            Names = [Names {Descendants.Name}];
            Descendants = [Descendants.Children];
        end
        unique_wit_Names_per_file{ii} = unique(Names);
        fprintf('Number of unique wit Names = %d\n', numel(unique_wit_Names_per_file{ii}));
        fprintf('Unique wit Names = %s\n', strjoin(unique_wit_Names_per_file{ii}, ', '));
    end
    
    % Generate the diversity matrix
    unique_wit_Names = unique([unique_wit_Names_per_file{:}]);
    if isempty(unique_wit_Names), unique_wit_Names = {}; end % Handle case of no unique wit Names
    unique_wit_Names = reshape(unique_wit_Names, 1, []); % Force row column
    fprintf('\nNumber of all unique wit Names = %d\n', numel(unique_wit_Names));
    fprintf('All unique wit Names = %s\n', strjoin(unique_wit_Names, ', '));
    B_diversity_matrix = false(numel(files), numel(unique_wit_Names));
    for ii = 1:numel(unique_wit_Names),
        B_diversity_matrix(:,ii) = cellfun(@(s) any(strcmp(s, unique_wit_Names{ii})), unique_wit_Names_per_file);
    end
end
