% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function converts the given (possibly nested) wit objects into
% 64-bit XXH3 hash values, for easier and faster (vectorized) comparison.
function bytes = hash(obj), %#ok
    bytes = zeros(size(obj), 'uint64');
    for ii = 1:numel(obj), %#ok
        bytes(ii) = WITio.obj.wit.xxh3_64(char(obj(ii)));
    end
end
