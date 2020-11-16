% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% FAST helper function to parse and test existance of any single-dashed
% string in the given cell array input. Any multiple-dashed string is
% treated as data (for now) and its first dash is removed. This feature can
% be used to pass such strings to the nested functions, where they may be
% detected as single-dashed strings.

% INPUTS:
% (1) in: A cell array of some function inputs for parsing. For instance,
% a variable-length input argument list, varargin.

% OUTPUTS:
% (1) exists: Whether or not any single-dashed string exists.

function exists = varargin_dashed_str_any_exists(in),
    % Treat those containing two or more subsequent dashes as datas
    exists = any(strncmp(in, '-', 1) & ~strncmp(in, '--', 2));
end
