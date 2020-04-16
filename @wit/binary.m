% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function was implemented to provide CONSIDERABLE SPEED-UP when
% writing to file, because we can call EXPENSIVE fwrite only once.
function buffer = binary(obj, swapEndianess),
    if nargin < 2, swapEndianess = false; end % By default: Binary with little endianess
    warning('You are using a deprecated version! Use bwrite-function instead.');
    buffer = obj.bwrite(swapEndianess);
end
