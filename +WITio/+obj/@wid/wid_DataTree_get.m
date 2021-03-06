% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Helper function to GET (un)formatted struct-content to wit-tree.
function out = wid_DataTree_get(obj, varargin),
    out = WITio.obj.wit.DataTree_get(obj.Tag.Data, varargin{:});
end
