% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Helper function to get the given dashed string indices in the given
% varargin input.
function ind = varargin_dashed_str_inds(str_wo_dash, in, FirstOnly),
    if nargin < 3, FirstOnly = false; end % By default, merge all
    if ~iscell(in), in = {in}; end % Always cell
    
    % Find occurences of the given str
    str = ['-' str_wo_dash]; % Add dash to string
    if FirstOnly, ind = find(strcmpi(in(strncmp(in, '-', 1)), str), 1, 'first');
    else, ind = find(strcmpi(in(strncmp(in, '-', 1)), str)); end
end
