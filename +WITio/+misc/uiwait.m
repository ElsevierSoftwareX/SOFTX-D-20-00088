% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function is intended replace use of uiwait within WITio toolbox,
% because it allows non-interactive mode to kick in on demand.
function uiwait(h),
    if ishandle(h),
        AutoCloseInSeconds = WITio.misc.pref.get('AutoCloseInSeconds', Inf);
        figure(h);
        if isinf(AutoCloseInSeconds),
            uiwait(h);
        else,
            uiwait(h, AutoCloseInSeconds);
            delete(h); % Ensure deletion!
        end
        drawnow; pause(0.1); % Reduce hang issues with old MATLAB versions like R2011a (https://undocumentedmatlab.com/articles/solving-a-matlab-hang-problem)
    end
end
