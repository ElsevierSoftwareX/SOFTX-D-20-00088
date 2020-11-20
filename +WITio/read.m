% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This is a simple wrapper for WITio.core.wip.read.
function varargout = read(varargin), % For reading WIT-formatted files!
    [varargout{1:nargout}] = WITio.core.wip.read(varargin{:});
end
