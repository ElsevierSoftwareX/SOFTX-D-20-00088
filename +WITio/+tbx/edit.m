% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function is intended replace use of edit within WITio toolbox,
% because it allows non-interactive mode to kick in on demand.
function edit(file),
    if nargin == 0,
        S = dbstack('-completenames'); % Find out what function called this
        if numel(S) < 2, return; end % Stop if nothing to find
        file = S(2).file;
    end
    if ~WITio.tbx.pref.get('AutoStopEdit', false),
        edit(file);
    end
end
