% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Helper function to parse and remove the given single-dashed string and
% its datas from the given cell array input. Any multiple-dashed string is
% treated as data (for now) and its first dash is removed. This feature can
% be used to pass such strings to the nested functions, where they may be
% detected as single-dashed strings.

% INPUTS:
% (1) str_wo_dash: A char array for case-insensitive string-to-string
% comparison. The first '-'-character is assumed to be excluded and is
% always added to it prior the search. It must begin with a non-dash char.
%   IF EMPTY: It matches any single-dashed string!
% (2) in: A cell array of some function inputs for parsing. For instance,
% a variable-length input argument list, varargin.
% (3) N = inf (by default): A numeric scalar that limits the number of
% matches. If a finite limit is set, then it keeps first N.
%   IF NEGATIVE: It reverses order of the matches and keeps last N!

% OUTPUTS:
% (1) in_wo: The cell array without the given single-dashed string and its
% datas.

function varargout = varargin_dashed_str_removed(varargin),
    if nargout > 0,
        [~, ~, varargout{1:nargout}] = wit.io.parse.varargin_dashed_str_inds_and_datas(varargin{:});
    end
end
