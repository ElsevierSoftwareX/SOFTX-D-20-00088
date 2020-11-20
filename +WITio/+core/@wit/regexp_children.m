% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Finds matching children by the specified name patterns (= varargin). This
% can be chained and can be much faster than .search or .regexp.
function varargout = regexp_children(obj, varargin),
    % Get wit Tree object Children and their Names
    Children = [obj.Children];
    if isempty(Children), Children = WITio.core.wit.empty; end
    Names = {Children.Name};
    % Loop to match them
    varargout = cell(size(varargin));
    for ii = 1:numel(varargin),
        varargout{ii} = Children(~cellfun(@isempty, regexp(Names, varargin{ii}, 'once')));
    end
end
