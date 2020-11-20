% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Helper function to parse and return the datas of the given single-dashed
% string from the given cell array input. Any multiple-dashed string is
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
% (1) inds: The indices of the given single-dashed string.
% (2) datas: The cell array of the datas of the given single-dashed string.
% (3) in_wo: Inputs without the given single-dashed string and its datas.

function [inds, datas, in_wo] = inds_and_datas(str_wo_dash, in, N),
    if nargin < 3, [~, ind_dashed_begin, ind_dashed_end] = WITio.misc.varargin_dashed_str(str_wo_dash, in);
    else, [~, ind_dashed_begin, ind_dashed_end] = WITio.misc.varargin_dashed_str(str_wo_dash, in, N); end
    
    % Determine if the given single-dashed string exists
    inds = ind_dashed_begin;
    
    % Get its datas
    if nargout > 1,
        % Combine all data related to the given str
        B_datas = false(size(in));
        for ii = 1:numel(ind_dashed_begin),
            inds_ii = ind_dashed_begin(ii)+1:ind_dashed_end(ii);
            B_datas(inds_ii) = true;
        end
        datas = in(B_datas);
        % Consume the first dash in those datas containing two or more
        % subsequent dashes in the beginning.
        for ii = 1:numel(datas),
            if ischar(datas{ii}) && strncmp(datas{ii}, '-', 1),
                datas{ii} = datas{ii}(2:end); % Remove the first dash
            end
        end
    end
    
    % Get in without the given single-dashed string and its datas
    if nargout > 2,
        % Combine all data related to the given str
        B_in = true(size(in));
        for ii = 1:numel(ind_dashed_begin),
            inds_ii = ind_dashed_begin(ii):ind_dashed_end(ii);
            B_in(inds_ii) = false;
        end
        in_wo = in(B_in);
    end
end
