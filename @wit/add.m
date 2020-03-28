% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Adopts the given wit-class objects under the parent obj.
function add(obj, varargin),
    if numel(obj) > 1, error('A tag cannot have more than one parent!'); % Error if more than one parent!
    elseif numel(obj) == 0, return; end % Do nothing if no parents
    children = obj.Children;
    N_children = numel(children);
    for ii = 1:numel(varargin),
        children_ii = varargin{ii};
        if isa(children_ii, 'wit'),
            children = [children reshape(children_ii, 1, [])];
        end
    end
    if numel(children) ~= N_children, % Update obj.Data only if a change happened
        obj.Data = children;
    end
end
