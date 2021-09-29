% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Finds matching children by the specified names (= varargin). This can be
% chained and can be much faster than .search or .regexp.
function varargout = search_children(obj, varargin), %#ok
    % Preallocate outputs
    varargout = cell(size(varargin));
    % Get wit Tree object Children
    Children = [obj.ChildrenNow];
    if isempty(Children), Children = WITio.obj.wit.empty; end
    % Sort both children and input Name strings
    [Names_sorted, jj2ind] = sort({Children.NameNow});
    [varargin, ii2ind] = sort(varargin);
    % Loop to match them
    jj = 1;
    N_Children = numel(Children);
    B_matches = false(size(Children));
    for ii = 1:numel(varargin), %#ok
        while jj <= N_Children, %#ok
            if strcmp(varargin{ii}, Names_sorted{jj}), %#ok
                B_matches(jj2ind(jj)) = true;
            elseif any(B_matches), break; end
            jj = jj + 1;
        end
        varargout{ii2ind(ii)} = Children(B_matches);
        B_matches(B_matches) = false; % Reset boolean map
    end
end
