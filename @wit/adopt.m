% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Adopts the given wit-class objects under the parent obj.
function adopt(obj, varargin),
    warning('You are using a deprecated version! Use add-function instead.');
    obj.add(varargin{:});
end
