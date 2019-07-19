% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Helper function to test the given dashed string exists in the given
% varargin input.
function exists = varargin_dashed_str_exists(str_wo_dash, in),
    if ~iscell(in), in = {in}; end % Always cell
    
    % First find occurences of the given str
    str = ['-' str_wo_dash]; % Add dash to string
    exists = any(strcmpi(in(strncmp(in, '-', 1)), str));
end
