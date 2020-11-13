% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function tests whether or not the toolbox is set to verbose mode for
% more verbose output. This is used to enable faster non-interactive mode
% with the example cases.
function tf = wit_io_verbose(),
    tf = wit_io_pref_get('Verbose', true);
end
