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
% (1) out: The cell array of the datas of the given dashed string.
% (2) in_wo: Inputs without the given dashed string and its datas

function [out, in_wo] = varargin_dashed_str_datas(str_wo_dash, in, N),
    if nargin < 3,
        [~, ind_dashed_begin, ind_dashed_end] = varargin_dashed_str(str_wo_dash, in);
        if nargout > 1, in_wo = varargin_dashed_str_removed(str_wo_dash, in); end
    else,
        [~, ind_dashed_begin, ind_dashed_end] = varargin_dashed_str(str_wo_dash, in, N);
        if nargout > 1, in_wo = varargin_dashed_str_removed(str_wo_dash, in, N); end
    end
    
    % Then combine all data related to the given str
    B_out = false(size(in));
    for ii = 1:numel(ind_dashed_begin),
        inds = ind_dashed_begin(ii)+1:ind_dashed_end(ii);
        B_out(inds) = true;
    end
    out = in(B_out);
end
