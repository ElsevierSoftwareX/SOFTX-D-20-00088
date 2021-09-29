% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function tags = regexp_all_Names(obj, pattern), %#ok
    % Finds Tag(s) by specified Name-pattern.
    tags = obj(~cellfun(@isempty, regexp({obj.NameNow}, pattern, 'once'))); % Benefit from cell-array speed-up
    Descendants = [obj.ChildrenNow];
    while ~isempty(Descendants), %#ok
        tags = [tags Descendants(~cellfun(@isempty, regexp({Descendants.NameNow}, pattern, 'once')))]; %#ok % Benefit from cell-array speed-up];
        Descendants = [Descendants.ChildrenNow];
    end
end
