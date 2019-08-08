% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% FAST helper function to parse and test existance of any dashed string
% in the given cell array input.

% INPUTS:
% (1) in: A cell array of some function inputs for parsing. For instance,
% a variable-length input argument list, varargin.

% OUTPUTS:
% (1) exists: Whether or not any dashed string exists.

function exists = varargin_dashed_str_any_exists(in),
    exists = any(strncmp(in, '-', 1));
end
