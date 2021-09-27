% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Quickly get all the unique wit-class Types in the files. If no 'files'
% are given, then it opens a folder selection dialog box. It also returns
% a 2-D boolean matrix, in which columns represent files and rows represent
% all the unique wit-class Types. This can be used to find certain kinds of
% files quickly among hundreds of files.
function [unique_wit_Types, B_diversity_matrix, versions, files] = get_unique_wit_Types(files),
    if nargin == 0, files = WITio.dev.tools.get_dir_files_recursively(); end
    
    % Keep only *.wip and *.wid files
    [~, ~, ext] = cellfun(@fileparts, files, 'UniformOutput', false);
    B_wit = strcmpi(ext, '.wip') | strcmpi(ext, '.wid');
    files = files(B_wit);
    
    % Open such files and collect Type-statistics
    unique_wit_Types_per_file = cell(size(files));
    versions = nan(size(files));
    for ii = 1:numel(files),
        fprintf('\nFile %d/%d OR %s:\n', ii, numel(files), files{ii});
        O_wit = WITio.obj.wit.read(files{ii}, 4096, @(O_wit) O_wit.Type ~= 0); % This skip Data criteria enables much faster file reading!
        Version = WITio.obj.wip.get_Root_Version(O_wit);
        if ~isempty(Version), versions(ii) = Version; end
        Descendants = O_wit;
        Types = [O_wit.Type];
        while ~isempty(Descendants),
            Types = [Types Descendants.Type];
            Descendants = [Descendants.Children];
        end
        unique_wit_Types_per_file{ii} = unique(Types);
        fprintf('Number of unique wit Types = %d\n', numel(unique_wit_Types_per_file{ii}));
        fprintf('Unique wit Types = %s\n', WITio.fun.indep.mystrjoin(arrayfun(@(t) sprintf('%d', t), unique_wit_Types_per_file{ii}, 'UniformOutput', false), ', '));
    end
    
    % Generate the diversity matrix
    unique_wit_Types = unique([unique_wit_Types_per_file{:}]);
    if isempty(unique_wit_Types), unique_wit_Types = {}; end % Handle case of no unique wit Types
    unique_wit_Types = reshape(unique_wit_Types, 1, []); % Force row column
    fprintf('\nNumber of all unique wit Types = %d\n', numel(unique_wit_Types));
    fprintf('All unique wit Types = %s\n', WITio.fun.indep.mystrjoin(arrayfun(@(t) sprintf('%d', t), unique_wit_Types, 'UniformOutput', false), ', '));
    B_diversity_matrix = false(numel(files), numel(unique_wit_Types));
    for ii = 1:numel(unique_wit_Types),
        B_diversity_matrix(:,ii) = cellfun(@(s) any(s == unique_wit_Types(ii)), unique_wit_Types_per_file);
    end
end
