% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Finds matching children by the specified names (= varargin). This can be
% chained and can be much faster than .search or .regexp.
function varargout = search_children(obj, varargin),
    N_varargin = numel(varargin); % Number of inputs
    varargout(1:N_varargin) = {wit.empty}; % Initialize outputs
    if isempty(obj), return; end % Stop if obj is empty
    [varargin, ii2ind] = sort(varargin);
    Children = obj.Children;
    N_Children = numel(Children);
    [Names_sorted, jj2ind] = sort({Children.Name});
    jj_begin = 1;
    for ii = 1:N_varargin,
        name = varargin{ii};
        match_found = false;
        for jj = jj_begin:N_Children,
            if strcmp(name, Names_sorted{jj}),
                varargout{ii2ind(ii)} = Children(jj2ind(jj));
                match_found = true;
                jj_begin = jj+1;
                break;
            end
        end
        if ~match_found, break; end % Stop because no more matches exist
    end
end
