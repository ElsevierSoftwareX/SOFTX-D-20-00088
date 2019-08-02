% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Helper function to parse and return the datas of the given dashed string
% from the given cell array input.

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
% (2) datas: The cell array of the datas of the given dashed string.
% (3) in_wo: Inputs without the given dashed string and its datas

function varargout = varargin_dashed_str_exists_and_datas(varargin),
    [varargout{1:nargout}] = varargin_dashed_str_inds_and_datas(str_wo_dash, in, N);
    if nargout > 0, varargout{1} = ~isempty(varargout{1}); end % Test if exists
end
