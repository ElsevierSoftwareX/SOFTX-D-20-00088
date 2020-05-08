% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Make hard copy of the wit-tree and its nodes. Please note that the links
% to the root and the parents are destroyed to keep the trees consistent!
function new = copy(obj),
    new = copy_children(obj, wit.empty); % Define as Root objects
    % Set Root properties
    for jj = 1:numel(obj),
        new(jj).Magic = obj(jj).Magic; % Sufficient but not an exact copy
        new(jj).File = obj(jj).File; % Sufficient but not an exact copy
    end
    function new_children = copy_children(children, Parent),
        new_children = wit.empty; % Return empty if no obj given
        % Using constructor to automatically reset Root and Parent
%         new_children(numel(children)) = wit(); % Causes same-Id-bug when using Octave-compatible NextId-scheme!
        for ii = 1:numel(children),
            obj_ii = children(ii);
            new_ii = wit(); % Avoids same-Id-bug when using Octave-compatible NextId-scheme!
            
            % Set the object itself as its own latest modified object (known beforehand)
            new_ii.ModificationsLatestAt = new_ii;
            
            new_ii.NameNow = obj_ii.NameNow; % Speed-up
            
            new_ii.ParentNow = Parent; % Speed-up
            
            % Test if a data tag or a list of tags
            if isempty(obj_ii.ChildrenNow), % Data
                new_ii.DataNow = obj_ii.DataNow;
                new_ii.ChildrenNow = obj_ii.ChildrenNow;
            else, % Children
                copies = copy_children(obj_ii.ChildrenNow, new_ii);
                new_ii.ChildrenNow = copies;
                new_ii.DataNow = copies;
            end
            new_ii.HasData = obj_ii.HasData;
            
            new_children(ii) = new_ii;
        end
    end
end
