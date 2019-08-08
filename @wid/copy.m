% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Make hard copy of the wid and all its linked objects and append to wip.
function new = copy(obj),
    new = wid.Empty; % Return empty if no obj given
    for ii = numel(obj):-1:1,
        if ~obj(ii).isvalid, continue; end % Skip deleted
        new(ii).Project = obj(ii).Project; % Calls wid()-constructor!
        % Copy the tags
        Tag_ii = obj(ii).Tag;
        if ~isempty(Tag_ii),
%             old_datas = Tag_ii.Data.Parent.Children;
            [new(ii).Tag(1).Root, Tags] = wip.append(Tag_ii.Root, {[Tag_ii.DataClassName Tag_ii.Data]}); % Append the root (ENCLOSED BY {} TO AVOID TOUCHING THE LINKED IDS)
            new(ii).Tag(1).RootVersion = new(ii).Tag(1).Root.search('Version', {'WITec (Project|Data)'}); % Update RootVersion-tag
            Tag_1 = Tags(1);
            Tag_2 = Tags(2);
%             new_datas = Tag_ii.Data.Parent.Children;
%             Tags = new_datas(~any(repmat(new_datas(:), [1 numel(old_datas)]) == repmat(old_datas(:)', [numel(new_datas) 1]), 2)); % Find the appended copies % MAJOR BOTTLENECK!
%             bw = strncmp({Tags.Name}, 'DataClassName', 13); % Find DataClassName-tag
%             Tag_1 = Tags(bw);
%             Tag_2 = Tags(~bw); % Other tag is assumed to be Data-tag
            new(ii).Tag(1).DataClassName = Tag_1;
            new(ii).Tag(1).Data = Tag_2;
            new(ii).Tag(1).Caption = Tag_2.search('Caption', 'TData', {'^Data \d+$'});
            new(ii).Tag(1).Id = Tag_2.search('ID', 'TData', {'^Data \d+$'});
            new(ii).Tag(1).ImageIndex = Tag_2.search('ImageIndex', 'TData', {'^Data \d+$'});
        end
        % Copy the linked objects AFTER the tags have been copied!
        new(ii).copy_Links();
        % Add copied object to the project
        if ~isempty(new(ii).Project), new(ii).Project.Data = [new(ii).Project.Data; new(ii)]; end
    end
end
