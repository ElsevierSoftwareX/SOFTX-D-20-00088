% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Helper function to parse and test existance of the given dashed string
% in the given cell array input.

% INPUTS:
% (1) str_wo_dash: A char array for case-insensitive string-to-string
% comparison. The first '-'-character is assumed to be missing and is
% always added to it prior the search.
%   IF EMPTY: It matches any dashed string!
% (2) in: A cell array of some function inputs for parsing. For instance,
% a variable-length input argument list, varargin.
% (3) N = inf (by default): A numeric scalar that limits the number of
% matches. If a finite limit is set, then it keeps first N.
%   IF NEGATIVE: It reverses order of the matches and keeps last N!

% OUTPUTS:
% (1) exists: Whether or not the given dashed string exists.

function exists = varargin_dashed_str_exists(str_wo_dash, in, N),
    if nargin < 3, exists = any(varargin_dashed_str(str_wo_dash, in));
    else, exists = any(varargin_dashed_str(str_wo_dash, in, N)); end
end
