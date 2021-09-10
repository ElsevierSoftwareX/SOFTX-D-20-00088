% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Make hard copy of the wit-tree and its nodes. Please note that the links
% to the root and the parents are destroyed to keep the trees consistent!
function new = copy(obj), %#ok
    new = copy_children(obj, WITio.obj.wit.empty); % Define as Root objects
    % Set Root properties
    for jj = 1:numel(obj), %#ok
        new(jj).OrdinalNumber = 1;
        new(jj).Magic = obj(jj).Magic; % Sufficient but not an exact copy
        new(jj).File = obj(jj).File; % Sufficient but not an exact copy
    end
    function new_children = copy_children(children, Parent), %#ok
        new_children = WITio.obj.wit.empty; % Return empty if no obj given
        % Using constructor to automatically reset Root and Parent
%         new_children(numel(children)) = WITio.obj.wit(); % Causes same-Id-bug when using Octave-compatible NextId-scheme!
        for ii = 1:numel(children), %#ok
            obj_ii = children(ii);
            new_ii = WITio.obj.wit(); % Avoids same-Id-bug when using Octave-compatible NextId-scheme!
            
            new_ii.NameNow = obj_ii.NameNow; % Speed-up
            
            new_ii.ParentNow = Parent; % Speed-up
            
            % Test if a data tag or a list of tags
            if isempty(obj_ii.ChildrenNow), %#ok % Data
                new_ii.DataNow = obj_ii.DataNow;
                new_ii.ChildrenNow = obj_ii.ChildrenNow;
            else, %#ok % Children
                copies = copy_children(obj_ii.ChildrenNow, new_ii);
                new_ii.ChildrenNow = copies;
                new_ii.DataNow = copies;
                for kk = 1:numel(copies), %#ok
                    copies(kk).OrdinalNumber = kk;
                end
            end
            new_ii.HasData = obj_ii.HasData;
            
            new_children(ii) = new_ii;
        end
    end
end
