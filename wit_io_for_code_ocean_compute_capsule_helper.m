% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This is helper function to prevent unintentional mixing of variables.
function wit_io_for_code_ocean_compute_capsule_helper(name),
    feval(name); % Assuming that the called function does not CLEAR ALL, which would stop NON-INTERACTIVE MODE!
end
