% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This wraps built-in waitbar but gives no waitbar if -nodesktop.
function varargout = waitbar(varargin),
    % Determine whether or not to show waitbar
    isDesktop = usejava('desktop'); % Test if MATLAB is running in Desktop-mode
    if isDesktop, [varargout{1:nargout}] = waitbar(varargin{:});
    else, [varargout{1:nargout}] = deal([]); end
end
