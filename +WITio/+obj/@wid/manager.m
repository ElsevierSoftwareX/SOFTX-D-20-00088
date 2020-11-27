% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% A wrapper method that shows the given objects via Project Manager view.
function varargout = manager(obj, varargin),
    O_wip = unique([obj.Project]); % Get Projects
    [varargout{1:nargout}] = O_wip.manager('-Data', obj, '-all', '-indices', '-nosort', varargin{:});
end
