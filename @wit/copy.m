% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Make hard copy of the wit-tree and its nodes. Please note that the links
% to the root and the parents are destroyed to keep the trees consistent!
function new = copy(obj),
    new = copy_children(obj, wit.empty);
    function new_children = copy_children(children, Parent),
        new_children = wit.empty; % Return empty if no obj given
        % Using constructor to automatically reset Root and Parent
%         new_children(numel(children)) = wit(); % Causes same-Id-bug when using Octave-compatible NextId-scheme!
        for ii = 1:numel(children),
            obj_ii = children(ii);
            
            new_ii = wit(); % Avoids same-Id-bug when using Octave-compatible NextId-scheme!
            
            % Set the object itself as its own latest modified object (known beforehand)
            new_ii.ModificationsLatestAt = new_ii;
            
            new_ii.skipRedundant = true; % Speed-up set.Name
            new_ii.Name = obj_ii.Name;
            
            if isempty(Parent),
                new_ii.Magic = obj_ii.Magic; % Sufficient but not an exact copy
                new_ii.File = obj_ii.File; % Sufficient but not an exact copy
            end

            % But do not copy Parent in order to preserve the tree
            % consistency!
            new_ii.skipRedundant = true; % Speed-up set.Parent
            new_ii.Parent = Parent;

            % Test if a data tag or a list of tags
            new_ii.skipRedundant = true; % Speed-up set.Data
            if ~isa(obj_ii.Data, 'wit'), new_ii.Data = obj_ii.Data; % Data
            else, new_ii.Data = copy_children(obj_ii.Data, new_ii); end % Children

            % Finally, update HasData because it is set false when setting empty Data
            new_ii.HasData = obj_ii.HasData;
            new_children(ii) = new_ii;
        end
    end
end
