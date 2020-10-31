% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function tags = regexp_all_Names(obj, pattern),
    % Finds Tag(s) by specified Name-pattern.
    tags = obj(~cellfun(@isempty, regexp({obj.Name}, pattern, 'once'))); % Benefit from cell-array speed-up
    Descendants = [obj.Children];
    while ~isempty(Descendants),
        tags = [tags Descendants(~cellfun(@isempty, regexp({Descendants.Name}, pattern, 'once')))]; % Benefit from cell-array speed-up];
        Descendants = [Descendants.Children];
    end
end
