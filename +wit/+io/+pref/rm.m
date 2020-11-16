% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Removes wit_io toolbox preferences (effectively restoring the
% corresponding default values) using built-in RMPREF function. This
% behaves like RMPREF but does not error if group or pref do not exist.
function rm(pref),
    if nargin == 0, % If no input, then remove all the preferences
        if ispref('wit_io'), rmpref('wit_io'); end
    elseif ischar(pref), % If a char input, then remove the specified preference
        if ispref('wit_io', pref), rmpref('wit_io', pref); end
    else, % Otherwise, remove the specified multiple preferences
        if isstruct(pref), pref = fieldnames(pref); end % SPECIAL CASE: a struct input
        rmpref('wit_io', pref(ispref('wit_io', pref)));
    end
end
