% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Removes WITio toolbox preferences (effectively restoring the
% corresponding default values) using built-in RMPREF function. This
% behaves like RMPREF but does not error if group or pref do not exist.
function rm(pref),
    if ~ispref('WITio'), return; end % Do nothing if the group does not exist
    if nargin == 0, % If no input, then remove all the preferences
        rmpref('WITio');
    elseif ischar(pref), % If a char input, then remove the specified preference
        if ispref('WITio', pref), rmpref('WITio', pref); end
    else, % Otherwise, remove the specified multiple preferences
        if isstruct(pref), pref = fieldnames(pref); end % SPECIAL CASE: a struct input
        rmpref('WITio', pref(ispref('WITio', pref)));
    end
end
