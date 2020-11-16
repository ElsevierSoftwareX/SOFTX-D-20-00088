% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Helper function to SET (un)formatted struct-content to wit-tree.
function wid_DataTree_set(obj, in, varargin),
    wit.io.wit.DataTree_set(obj.Tag.Data, in, varargin{:});
end
