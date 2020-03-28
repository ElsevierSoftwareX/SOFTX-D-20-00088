% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Removes the given wit-class objects from the parent objects.
function remove(obj, varargin),
    if isempty(obj), return; end % Do nothing if no parent objects was given
    for ii = 1:numel(varargin),
        children_ii = varargin{ii};
        if ~isa(children_ii, 'wit'), continue; end % Skip if not potential children
        for jj = 1:numel(children_ii), % Loop through the potential children one by one
            parent_ii_jj = children_ii(jj).Parent;
            if ~isempty(parent_ii_jj) && any(parent_ii_jj == obj), % Test if a potential child has a parent among the parent objects
                children_ii(jj).Parent = wit.empty;
            end
        end
    end
end
