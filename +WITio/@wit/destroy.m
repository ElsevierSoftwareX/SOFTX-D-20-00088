% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function destroy(obj),
    warning('You are using a deprecated version! Use delete-function instead.');
    delete(obj);
end
