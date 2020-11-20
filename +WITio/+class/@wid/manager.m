% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% A wrapper method that shows the given objects via Project Manager view.
function varargout = manager(obj, varargin),
    if isempty(obj), O_wip = WITio.class.wip.empty; % If no Data, then no Project
    else, O_wip = obj(1).Project; end % Use Project of first Data object
    [varargout{1:nargout}] = O_wip.manager('-Data', obj, '-all', '-indices', '-nosort', varargin{:});
end
