% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This is a simple wrapper for WITio.wip.read.
function varargout = read(varargin), % For reading WIT-formatted WID-files!
    [varargout{1:nargout}] = WITio.read(varargin);
end
