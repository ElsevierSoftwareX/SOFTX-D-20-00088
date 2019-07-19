% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Helper function to get the given dashed string datas in the given
% varargin input.
function out = varargin_dashed_str_datas(str_wo_dash, in, FirstOnly),
    if nargin < 3, FirstOnly = false; end % By default, merge all
    if ~iscell(in), in = {in}; end % Always cell
    ind_extra_begin = find(strncmp(in, '-', 1));
    ind_extra_end = [ind_extra_begin(2:end)-1 numel(in)];
    
    % First find occurences of the given str
    str = ['-' str_wo_dash]; % Add dash to string
    if FirstOnly, ind_str = find(strcmpi(in(ind_extra_begin), str), 1, 'first');
    else, ind_str = find(strcmpi(in(ind_extra_begin), str)); end
    
    % Then combine all data related to the given str
    B_out = false(size(in));
    for ii = 1:numel(ind_str),
        inds = ind_extra_begin(ind_str(ii))+1:ind_extra_end(ind_str(ii));
        B_out(inds) = true;
    end
    out = in(B_out);
end
