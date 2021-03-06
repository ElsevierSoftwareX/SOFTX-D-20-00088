% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% List the path content using clickable html links. All but MATLAB m-files
% are colored in red for visual contrast. The file extensions can be
% filtered by the providing char array as 2nd input (i.e. 'm;mat' for *.m
% and *.mat files). Either omit 2nd input or provide [] for no filtering.
% All inputs are optional. If MATLAB is not running in Desktop-mode, then
% this will not show any links.
function href_dir(path, exts, fun_prior),
    if nargin < 1 || isempty(path), path = '.'; end % Browse the current folder by default
    if nargin < 2, exts = []; end % No filtering by default
    if nargin < 3, fun_prior = []; end % No default prior function call
    S = dir(path);
    if isempty(S), return; end % Do nothing if empty struct
    
    % Try to get full path from relative path.
    old_path = cd(path);
    path = cd(old_path);
    
    % Parse optional input
    nofiltering = ~ischar(exts);
    
    % Generate eval string to this call and its optional 2nd input
    str_this = m_file_eval_str([mfilename('fullpath') '.m']);
    
    % Determine whether or not to use html links
    isDesktop = usejava('desktop'); % The html links are possible only if MATLAB is running in Desktop-mode
    
    % Clear Command Window and fprintf the content
    clc;
    if isa(fun_prior, 'function_handle'), fun_prior(); end % Call prior function if given
    if isDesktop,
        if nofiltering, fprintf('Folders and files in <a href="matlab:cd(''%s'')">%s</a>:\n', path, path); 
        else, fprintf('Folders and files (ext=''%s'') in <a href="matlab:cd(''%s'')">%s</a>:\n', exts, path, path); end
    else,
        if nofiltering, fprintf('Folders and files in %s:\n', path); 
        else, fprintf('Folders and files (ext=''%s'') in %s:\n', exts, path); end
    end
    
    % First, show the folders
    if isDesktop,
        if nofiltering, fprintf('<a href="matlab:%s(''%s'')">%s..</a>', str_this, fullfile(path, '..'), filesep); % Display link
        else, fprintf('<a href="matlab:%s(''%s'', ''%s'')">%s..</a>', str_this, fullfile(path, '..'), exts, filesep); end % Display link
    else,
        fprintf('%s..', filesep);
    end
    isDir = [S.isdir];
    S_folders = S(isDir);
    for ii = 1:numel(S_folders),
        name_ii = S_folders(ii).name;
        if S(ii).isdir && ~strcmp(name_ii, '.') && ~strcmp(name_ii, '..'),
            folder_ii = fullfile(path, name_ii);
            if isDesktop,
                if nofiltering, fprintf(' <a href="matlab:%s(''%s'')">%s%s</a>', str_this, folder_ii, filesep, name_ii); % Display link
                else, fprintf(' <a href="matlab:%s(''%s'', ''%s'')">%s%s</a>', str_this, folder_ii, exts, filesep, name_ii); end % Display link
            else,
                fprintf(' %s%s', filesep, name_ii);
            end
        end
    end
    fprintf('\n');
    
    % Process imformats
    S_show = imformats;
    exts_show = [S_show.ext];
    
    % Then, show the files
    N_truncate = 75; % Maximum displayed with
    if ~nofiltering, exts = regexp(exts, ';', 'split'); end
    S_files = S(~isDir);
    ext_valid = {};
    files_valid = {};
    names_valid = {};
    for ii = 1:numel(S_files),
        name_ii = S_files(ii).name;
        file_ii = fullfile(path, name_ii);
        [~, name_ii, ext_ii] = fileparts(file_ii);
        ext_ii = ext_ii(2:end); % Exclude . in the beginning
        if nofiltering || any(strcmpi(exts, ext_ii)),
            ext_valid{end+1} = ext_ii;
            files_valid{end+1} = file_ii;
            if strcmpi(ext_ii, 'm'),
                names_valid{end+1} = m_file_eval_str(file_ii); % Command to the ith m-file
            else,
                if isempty(ext_ii), names_valid{end+1} = name_ii(1:min(numel(name_ii),N_truncate));
                else, names_valid{end+1} = [name_ii(1:min(numel(name_ii),N_truncate)) '.' ext_ii]; end
            end
        end
    end
    N_len = cellfun(@numel, names_valid);
    N_max_len = max(N_len);
    for ii = 1:numel(ext_valid),
        str_spaces = repmat(' ', [1 N_max_len-N_len(ii)+1]);
        switch lower(ext_valid{ii}),
            case 'm',
                if isDesktop,
                    fprintf('<a href="matlab:%s;" style="font-weight:bold">%s</a>%s(<a href="matlab:%s;" style="font-weight:bold">run</a> or <a href="matlab:edit(''%s'');">edit</a>)\n', names_valid{ii}, names_valid{ii}, str_spaces, names_valid{ii}, files_valid{ii}); % Display blue link
                else,
                    fprintf('%s%s(run or edit)\n', names_valid{ii}, str_spaces);
                end
            case 'mat',
                if isDesktop,
                    fprintf(2, '<a href="matlab:load(''%s'');">%s</a>%s', files_valid{ii}, names_valid{ii}, str_spaces); % Display red link (stderr)
                    fprintf('(');
                    fprintf(2, '<a href="matlab:load(''%s'');" style="font-weight:bold">load</a> ', files_valid{ii}); % Display red link (stderr)
                    fprintf('\b)\n');
                else,
                    fprintf('%s%s(load)\n', names_valid{ii}, str_spaces);
                end
            case {'wid', 'wip'},
                if isDesktop,
                    fprintf(2, '<a href="matlab:[O_wid,O_wip,O_wit]=WITio.read(''%s'');">%s</a>%s', files_valid{ii}, names_valid{ii}, str_spaces); % Display red link (stderr)
                    fprintf('(');
                    fprintf(2, '<a href="matlab:[O_wid,O_wip,O_wit]=WITio.read(''%s'');" style="font-weight:bold">with manager</a> ', files_valid{ii}); % Display red link (stderr)
                    fprintf('or ');
                    fprintf(2, '<a href="matlab:[O_wid,O_wip,O_wit]=WITio.read(''%s'', ''-all'');">without</a> ', files_valid{ii}); % Display red link (stderr)
                    fprintf('\b)\n');
                else,
                    fprintf('%s%s(with manager or without)\n', names_valid{ii}, str_spaces);
                end
            case exts_show,
                if isDesktop,
                    fprintf(2, '<a href="matlab:figure;imshow(imread(''%s''));">%s</a>%s', files_valid{ii}, names_valid{ii}, str_spaces); % Display red link (stderr)
                    fprintf('(');
                    fprintf(2, '<a href="matlab:figure;imshow(imread(''%s''));" style="font-weight:bold">show</a> ', files_valid{ii}); % Display red link (stderr)
                    fprintf('\b)\n');
                else,
                    fprintf('%s%s(show)\n', names_valid{ii}, str_spaces);
                end
            otherwise,
                if isDesktop,
                    fprintf(2, '<a href="matlab:edit(''%s'');">%s</a>%s', files_valid{ii}, names_valid{ii}, str_spaces); % Display red link (stderr)
                    fprintf('(');
                    fprintf(2, '<a href="matlab:edit(''%s'')" style="font-weight:bold">edit</a> ', files_valid{ii}); % Display red link (stderr)
                    fprintf('\b)\n');
                else,
                    fprintf('%s%s(edit)\n', names_valid{ii}, str_spaces);
                end
        end
    end
    
    function str_eval = m_file_eval_str(m_file),
        % Resolve if m-file is within package
        m_file_split = regexp(m_file, filesep, 'split'); % Split by the file separator
        bw_pkg = strncmp(m_file_split(1:end-1), '+', 1); % Find possible package folders
        m_file_split(bw_pkg) = cellfun(@(str) str(2:end), m_file_split(bw_pkg), 'UniformOutput', false); % Remove first +
        bw_pkg(bw_pkg) = cellfun(@isvarname, m_file_split(bw_pkg)); % Keep only valid package folders
        ind_pkg_begin = find(~bw_pkg, 1, 'last')+1; % First index of first package folder
        pkgs = m_file_split(ind_pkg_begin:end-1); % Package folders
        [~, m] = fileparts(m_file);
        str_eval = WITio.fun.indep.mystrjoin([pkgs {m}], '.'); % Command to the m-file
    end
end
