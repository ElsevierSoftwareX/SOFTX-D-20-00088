% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Helper function to parse and return the indices of the given dashed
% string in the given cell array input.

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
% (1) inds: The indices of the given dashed string.
% (2) in_wo: Inputs without the given dashed string and its datas

function varargout = varargin_dashed_str_inds(varargin),
    if nargout == 1,
        varargout{1} = varargin_dashed_str_inds_and_datas(varargin{:});
    elseif nargout > 1,
        [varargout{1}, ~, varargout{2:nargout}] = varargin_dashed_str_inds_and_datas(varargin{:});
    end
end
