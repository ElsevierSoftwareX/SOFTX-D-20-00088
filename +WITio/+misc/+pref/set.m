% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Sets WITio toolbox preferences using built-in SETPREF function. This
% behaves like SETPREF but also (1) converts a struct 'pref' to 'pref'-
% 'value' pairs, and (2) initializes 'value' with []'s if it was not given.
function set(pref, value),
    if nargin > 0,
        if isstruct(pref), % SPECIAL CASE: a struct input
            if nargin == 1, value = struct2cell(pref); end
            pref = fieldnames(pref);
        elseif nargin == 1,
            if ischar(pref), value = [];
            else, value = cell(size(pref)); end
        end
        setpref('WITio', pref, value);
    end
end
