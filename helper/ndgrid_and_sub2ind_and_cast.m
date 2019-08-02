% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Generates <class>-type indices in MEMORY CONSERVATIVE way using bsxfun,
% avoiding calls to built-in 'ndgrid' and 'sub2ind' and 'cast' functions.
% The indices are directly calculated as <class>, which is optionally given
% as a char array along the other inputs. If not specified, then <class> is
% 'double' by default.

% * The numeric array inputs are taken as subindices.
% * If '-replace' is found, then replace all (or the boolean array
% specified selection) of the out-of-bound subindices by nan (or zero).
% * If '-value' is found, then the replacement value above is changed to
% the specified value.
% * If '-truncate' is found, then truncate all (or the boolean array
% specified selection) of the out-of-bound subindices.
% * If '-circulate' is found, then circulate all (or the boolean array
% specified selection) of the out-of-bound subindices.
% * If '-matrix' is found, then do not force-to-column-and-permute all (or
% the boolean array specified selection) of the subindices.
% * The last char array input is taken as new class, overwriting 'double'.
% * Any unspecified array dimension size is assumed to be 1.
% * Any unspecified subindices are assumed to be empty.
function [ind, isAnyAtClassMax, isAtClassMax] = ndgrid_and_sub2ind_and_cast(arraySize, varargin),
    % Check if any of the special dashed strings were specified
    [doReplace, datas] = varargin_dashed_str_exists_and_datas('replace', varargin, -1);
    if doReplace && numel(datas) > 0, doReplace = logical(datas{1}); end
    
    datas = varargin_dashed_str_datas('value', varargin, -1);
    value = NaN; % Default replacement value
    if numel(datas) > 0, value = datas{1}; end
    
    [doTruncate, datas] = varargin_dashed_str_exists_and_datas('truncate', varargin, -1);
    if doTruncate && numel(datas) > 0, doTruncate = logical(datas{1}); end
    
    [doCirculate, datas] = varargin_dashed_str_exists_and_datas('circulate', varargin, -1);
    if doCirculate && numel(datas) > 0, doCirculate = logical(datas{1}); end
    
    [isMatrix, datas] = varargin_dashed_str_exists_and_datas('matrix', varargin, -1);
    if isMatrix && numel(datas) > 0, isMatrix = logical(datas{1}); end
    
    % Remove any dashed strings and their datas
    varargin = varargin_dashed_str_removed('', varargin);
    
    % Parse the cast class
    newclass = 'double'; % Default <class> if not specified
    B_char = cellfun(@ischar, varargin); % Find the char array inputs
    newclasses = varargin(B_char); % Only the char array inputs
    if numel(newclasses) > 0, newclass = newclasses{end}; end % Use the last char array input if given
    varargin = varargin(~B_char); % Discard the char array inputs
    
    % Parse the subindices
    B_numeric = cellfun(@isnumeric, varargin); % Find the numeric array inputs
    varargin = varargin(B_numeric); % Only the numeric array inputs
    
    % Append the missing dimensions
    D = max(numel(varargin), numel(arraySize)); % Maximum number of dimensions
    [varargin{end+1:D}] = deal([]);
    arraySize(end+1:D) = 1;
    
    % Convert scalar to array
    if numel(doReplace) == 1, doReplace = repmat(doReplace, 1, D); end
    if numel(doTruncate) == 1, doTruncate = repmat(doTruncate, 1, D); end
    if numel(doCirculate) == 1, doCirculate = repmat(doCirculate, 1, D); end
    if numel(isMatrix) == 1, isMatrix = repmat(isMatrix, 1, D); end
    
    % Generate indices
    arraySize = double(arraySize);
    offset = cast(cumprod([1 arraySize(1:end-1)]), newclass); % Cast to <class>
    if any(doReplace), B_replace = false; end % Initial value
    ind = cast(1, newclass); % Initial value and cast to <class>
    for ii = 1:D, % Loop each dimension
        subind_ii = double(varargin{ii}-1); % Get the ii'th dimension subindices as double and substract by 1
        if ~isMatrix(ii), subind_ii = permute(subind_ii(:), [2:ii 1 ii+1]); end % Permute subind to its own dimension
        if doReplace(ii), B_replace = bsxfun(@or, B_replace, subind_ii < 0 | subind_ii > arraySize(ii)-1); end
        if doTruncate(ii), subind_ii = min(max(0, subind_ii), arraySize(ii)-1); end
        if doCirculate(ii), subind_ii = mod(subind_ii, arraySize(ii)); end
        subind_ii = cast(subind_ii, newclass); % Cast to <class>
        ind_ii = subind_ii.*offset(ii);
        ind = bsxfun(@plus, ind, ind_ii); % Grow ind
    end
    if any(doReplace), ind(B_replace) = value; end % Replace some out-of-bound values
    
    % Test the indices (only if requested)
    if nargout > 1,
        if isfloat(ind), isAtClassMax = ind == realmax(newclass);
        else, isAtClassMax = ind == intmax(newclass); end
        isAnyAtClassMax = any(isAtClassMax(:));
    end
end
