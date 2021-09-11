% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Sets WITio toolbox preferences using built-in SETPREF function. This
% behaves like SETPREF but also (1) converts a struct 'pref' to 'pref'-
% 'value' pairs, and (2) initializes 'value' with []'s if it was not given.
% If 'resetOnCleanup' is stored to a variable, then all changes are ONLY
% TEMPORARY until the variable is cleared.
function resetOnCleanup = set(pref, value),
    if nargin > 0,
        if isstruct(pref), % SPECIAL CASE: a struct input
            if nargin == 1, value = struct2cell(pref); end
            pref = fieldnames(pref);
        elseif nargin == 1,
            if ischar(pref), value = [];
            else, value = cell(size(pref)); end
        end
        if nargout > 0, % TEMPORARY SETPREF
            B_old = ispref('WITio', pref);
            if ischar(pref), % SPECIAL CASE: a char input
                if B_old,
                    value_old = getpref('WITio', pref);
                    resetOnCleanup{1} = onCleanup(@() setpref('WITio', pref, value_old)); % Reset original value to preference
                else,
                    resetOnCleanup{1} = onCleanup(@() rmpref('WITio', pref)); % Remove originally nonexistent preference
                end
            else,
                if any(B_old), % Avoid next line's unexpected error in R2016a!
                    value_old = getpref('WITio', pref(B_old));
                    resetOnCleanup{1} = onCleanup(@() setpref('WITio', pref(B_old), value_old)); % Reset original values to preferences
                    resetOnCleanup{2} = onCleanup(@() rmpref('WITio', pref(~B_old))); % Remove originally nonexistent preferences
                else,
                    resetOnCleanup{1} = onCleanup(@() rmpref('WITio', pref(~B_old))); % Remove originally nonexistent preferences
                end
            end
        end
        setpref('WITio', pref, value);
    elseif nargout > 0,
        resetOnCleanup = [];
    end
end
