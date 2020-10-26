% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This is a simple wrapper for wip.read.
function varargout = read(varargin), % For reading WIT-formatted WID-files!
    [varargout{1:nargout}] = wip.read(varargin);
end
