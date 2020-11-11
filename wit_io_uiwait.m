% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function is intended replace use of uiwait within wit_io toolbox,
% because it allows non-interactive mode to kick in on demand.
function wit_io_uiwait(h),
    if ishandle(h),
        AutoCloseInSeconds = wit_io_pref_get('AutoCloseInSeconds', Inf);
        figure(h);
        if isinf(AutoCloseInSeconds),
            uiwait(h);
        else,
            uiwait(h, AutoCloseInSeconds);
            delete(h); % Ensure deletion!
        end
    end
end
