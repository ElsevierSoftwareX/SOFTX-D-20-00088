% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Gets wit_io toolbox preferences using built-in GETPREF function. This
% behaves like GETPREF but also uses optional default 'value' input (set to
% [] if not given) when no 'pref' is found. Any missing 'pref' is added.
function value = get(pref, value),
    if nargin == 0, % If no input, then get all the preferences
        value = getpref('wit_io');
    elseif ischar(pref), % If a char input, then get the specified preference
        if nargin == 1, value = []; end
        if ispref('wit_io', pref), value = getpref('wit_io', pref);
        else, setpref('wit_io', pref, value); end
    else, % Otherwise, get the specified multiple preferences
        if isstruct(pref), % SPECIAL CASE: a struct input
            if nargin == 1, value = struct2cell(pref); end
            pref = fieldnames(pref);
        elseif nargin == 1, value = cell(size(pref)); end
        B_get = ispref('wit_io', pref);
        value(B_get) = getpref('wit_io', pref(B_get));
        setpref('wit_io', pref(~B_get), value(~B_get));
    end
end
