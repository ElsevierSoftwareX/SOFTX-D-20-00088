% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Make hard copy of the wid and all its linked objects and append to wip.
function new = copy(obj),
    new = wid(size(obj)); % Return empty if no obj given
    for ii = 1:numel(obj),
        if ~obj(ii).isvalid, continue; end % Skip deleted
        new(ii).Project = obj(ii).Project; % Calls wid()-constructor!
        % Copy the tags
        obj_ii_Tag = obj(ii).Tag;
        if ~isempty(obj_ii_Tag),
            new_ii_Tag = struct;
            [new_ii_Tag.Root, Tags] = wit.io.wip.append(obj_ii_Tag.Root, {[obj_ii_Tag.DataClassName obj_ii_Tag.Data]}); % Append the root (ENCLOSED BY {} TO AVOID TOUCHING THE LINKED IDS)
            new_ii_Tag.RootVersion = new_ii_Tag.Root.search_children('Version'); % Update RootVersion-tag
            new_ii_Tag.Parent = Tags(2).Parent;
            new_ii_Tag.DataClassName = Tags(1);
            new_ii_Tag.Data = Tags(2);
            [new_ii_Tag.Caption, new_ii_Tag.Id, new_ii_Tag.ImageIndex] = Tags(2).search_children('TData').search_children('Caption', 'ID', 'ImageIndex');
            new(ii).Tag = new_ii_Tag;
        end
        % Copy the linked objects AFTER the tags have been copied!
        new(ii).copy_LinksToOthers();
        % These were AUTOMATICALLY added to the wip Project object!
    end
end
