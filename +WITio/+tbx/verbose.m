% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function tests whether or not the toolbox is set to verbose mode for
% more verbose output. This is used to enable faster non-interactive mode
% with the demo cases.
function tf = verbose(),
    tf = WITio.tbx.pref.get('Verbose', true);
end
