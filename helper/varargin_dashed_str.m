% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Helper function to parse and locate the given dashed string (and its
% datas) in the given cell array input.

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
% (1) B_dashed: Boolean map of the search string matches returned as a
% row vector.
% (2-3) ind_dashed_begin, ind_dashed_end: Bounding indices of the dashed
% content (including the search string itself) returned as row vectors.

function [B_dashed, ind_dashed_begin, ind_dashed_end] = varargin_dashed_str(str_wo_dash, in, N),
    % By default, no limit to the number of matches
    if nargin < 3, N = inf; end
    
    % Test input or error
    if ~ischar(str_wo_dash), error('Input ''str_wo_dash'' must be a char array!'); end
    if ~iscell(in), error('Input ''in'' must be a cell array!'); end
    if ~isnumeric(N) || numel(N) > 1, error('Input ''N'' must be a numeric scalar!'); end
    
    % Treat input
    str_wo_dash = reshape(str_wo_dash, 1, []); % Force row vector
    in = reshape(in, 1, []); % Force row vector
    N = double(N); % Force double
    
    % First find all dashed strings, their beginnings and endings
    B_dashed = strncmp(in, '-', 1);
    ind_dashed_begin = find(B_dashed);
    ind_dashed_end = [ind_dashed_begin(2:end)-1 numel(in)];
    
    % Then find occurrences of the given string (unless SPECIAL CASE)
    if ~isempty(str_wo_dash), % COMMON CASE: Non-empty string
        str = ['-' str_wo_dash]; % Add dash to the given string
        
        % Discard invalid matches
        B_valid = strcmpi(in(B_dashed), str); % Narrow down the range
        ind_dashed_begin = ind_dashed_begin(B_valid);
        ind_dashed_end = ind_dashed_end(B_valid);
        B_dashed(B_dashed) = B_valid;
    end
    
    % SPECIAL CASE: Interpred negative N as reversing the order
    if N < 0, % Reverse the order making first last and last first
        ind_dashed_begin = flip(ind_dashed_begin);
        ind_dashed_end = flip(ind_dashed_end);
        N = abs(N); % Remove negative
    end
    
    % Keep only the first (or last if reversed) N if requested
    B_dashed(ind_dashed_begin(min(N,end)+1:end)) = false;
    ind_dashed_begin = ind_dashed_begin(1:min(N,end));
    ind_dashed_end = ind_dashed_end(1:min(N,end));
end
