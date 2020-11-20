% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function tags = search_ancestors(obj, varargin),
    % Finds Tag(s) ANCESTORS by specified Name(s). The last given Name is
    % the search criteria for the given obj. The other Name(s) are
    % recursively matched for the obj ancestors. This is faster than regexp
    % because this uses strcmp (or regexp if input was enclosed by curly
    % {}-brackets) and quits searching from unmatched branches.
    if isempty(obj) || isempty(varargin), tags = obj; return; end % Return obj if empty or no search criteria given
    if ~iscell(varargin{1}), match = strcmp({obj.Name}, varargin{1}); % Use strcmp
    else, match = ~cellfun(@isempty, regexp({obj.Name}, varargin{1}{1}, 'once')); end % Use regexp if enclosed in {}-brackets
    if ~any(match), tags = WITio.core.wit.empty; return; end % Return empty if no matches
    if numel(varargin) == 1, tags = obj(match); % Return matches if no more criteria found
    else, tags = search_ancestors([obj(match).Parent WITio.core.wit.empty], varargin{2:end}); end % Continue search with the matched obj children
end
