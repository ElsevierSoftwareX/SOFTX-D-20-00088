% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This is a debugging tool to quickly compare wit Tree objects
% side-by-side. The last (optional) input is used to determine the
% recursion limit of the underlying disp-call.
function disp_cmp(varargin), %#ok
    if ~isa(varargin(end), 'WITio.obj.wit'), %#ok % Test if last element is the recursion limit
        max_recursion = varargin{end};
        varargin = varargin(1:end-1);
    end
    strs = cellfun(@(x) disp(x, max_recursion), varargin, 'UniformOutput', false);
    % Append missing lines
    N_lines_max = max(cellfun(@numel, strs));
    N_lines_max_len = zeros(size(varargin));
    for ii = 1:numel(varargin), %#ok
        strs_ii = strs{ii};
        N_lines_max_len(ii) = max(cellfun(@numel, strs_ii));
        [strs_ii{end+1:N_lines_max}] = deal(' ');
        strs{ii} = strs_ii;
    end
    % Make fixed length
    N_lines_max_len_max = max(N_lines_max_len);
    for ii = 1:numel(varargin), %#ok
        strs{ii} = cellfun(@(s) sprintf('%s%s', s(1:end-1), repmat(' ', 1, N_lines_max_len_max-numel(s))), strs{ii}, 'UniformOutput', false);
    end
    % Print fixed length lines
    strs = [strs{:}];
    for ii = 1:size(strs, 1), %#ok
        strs_ii = strs(ii,:);
        if all(strcmp(strs_ii(1), strs_ii(2:end))), fid = 1;
        else, fid = 2; end % Show red text when lines differ
        fprintf(fid, '%s\n', strjoin(strs_ii, ' | '));
    end
end
