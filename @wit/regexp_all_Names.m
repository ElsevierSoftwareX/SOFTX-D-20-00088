% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function tags = regexp_all_Names(obj, pattern),
    % Finds Tag(s) by specified Name-pattern.
    objs = obj;
    Descendants = [obj.Children];
    while ~isempty(Descendants),
        objs = [objs Descendants];
        Descendants = [Descendants.Children];
    end
    tags = objs(~cellfun(@isempty, regexp({objs.Name}, pattern, 'once'))); % Benefit from cell-array speed-up
end
