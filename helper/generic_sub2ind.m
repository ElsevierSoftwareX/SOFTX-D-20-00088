% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Generates <class>-type indices in MEMORY CONSERVATIVE way using bsxfun,
% avoiding calls to built-in 'ndgrid' and 'sub2ind' and 'cast' functions.
% The indices are directly calculated as <class>, which is optionally given
% as a char array along the other inputs. If not specified, then <class> is
% 'double' by default.

% Input interpretations:
% * Any nan array dimension size is replaced by the related subindices max.
% * If arraySize is a scalar nan, then treat all dimension sizes like nan.
% * Any unspecified array dimension size is assumed to be 1.
% * The numeric array inputs are taken as subindices.
% * Any unspecified subindices are assumed to be empty.
% * The last char array input is taken as new class, overwriting 'double'.
% * If '-isarray' is found, then do not force-to-column-and-permute all (or
% the boolean array specified selection) of the subindices.

% Other special dashed string inputs and their interpretations:
% * '-truncate': Truncates the out-of-bound subindices to the bound limits.
% * '-replace': Replaces the out-of-bound subindices by nan (= zero if
% integer) or by the '-value' specified replacement value.
% * '-mirror': Mirrors periodically the out-of-bound subindices.
% * '-circulate': Circulates periodically the out-of-bound subindices.
% * They are applied to the subindices in the order specified above.
% * ALSO, they can be provided with an extra input (= any numeric or
% logical scalar, vector or 2-by-N matrix values), which set the behaviour
% ON or OFF for each dimension and lower or upper out-of-bound subindices:
% ** Any scalar is replicated to form a 2-by-N matrix.
% ** Any vector of length N is made a 1-by-N row vector and is replicated
% to form a 2-by-N matrix.
% ** If N < number of dimensions, D: Expand any 2-by-N matrix to 2-by-D
% matrix by filling-in the expanded region with false.
% ** For any 2-by-D matrix, the 1st and the 2nd row set the behaviour ON or
% OFF for each dimension for the lower and upper out-of-bound subindices,
% respectively.

% OPTIMIZATIONS: The execution performance has been optimized for multiple
% consecutive calls, for instance, due to loops (although it will greatly
% degrade when using the dashed string inputs). The performance drawback of
% using the dashed string inputs may be fixed if requested.
function [ind, isAnyAtClassMax, isAtClassMax] = generic_sub2ind(arraySize, varargin),
    % Check if any of the special dashed strings were specified
    if any(strncmp(varargin, '-', 1)), % Parse ONLY IF exists (for speed-up!) % Call to varargin_dashed_str_any_exists(varargin) avoided for slight speed-up
        [isArray, datas] = varargin_dashed_str_exists_and_datas('isarray', varargin, -1);
        if isArray && numel(datas) > 0, isArray = logical(datas{1}); end

        [doTruncate, datas] = varargin_dashed_str_exists_and_datas('truncate', varargin, -1);
        if doTruncate && numel(datas) > 0, doTruncate = logical(datas{1}); end

        [doReplace, datas] = varargin_dashed_str_exists_and_datas('replace', varargin, -1);
        if doReplace && numel(datas) > 0, doReplace = logical(datas{1}); end

        datas = varargin_dashed_str_datas('value', varargin, -1);
        value = NaN; % Default replacement value
        if numel(datas) > 0, value = datas{1}; end

        [doMirror, datas] = varargin_dashed_str_exists_and_datas('mirror', varargin, -1);
        if doMirror && numel(datas) > 0, doMirror = logical(datas{1}); end

        [doCirculate, datas] = varargin_dashed_str_exists_and_datas('circulate', varargin, -1);
        if doCirculate && numel(datas) > 0, doCirculate = logical(datas{1}); end

        % Remove any dashed strings and their datas
        varargin = varargin_dashed_str_removed('', varargin);
    else,
        isArray = false;
        doTruncate = false;
        doReplace = false;
        value = NaN;
        doMirror = false;
        doCirculate = false;
    end
    
    % Parse the cast class and the subindices
    newclass = 'double'; % Default <class> if not specified
    N_numeric = 0;
    B_numeric = false(size(varargin));
    for ii = 1:numel(varargin),
        entry_ii = varargin{ii};
        if isnumeric(entry_ii), B_numeric(ii) = true; N_numeric = N_numeric+1;
        elseif ischar(entry_ii), newclass = entry_ii; end % Use the last char array input if given
    end
    ind_numeric = find(B_numeric); % Much faster than preallocating the varargin
    
    % Maximum number of dimensions
    N_arraySize = numel(arraySize);
    D = max(N_numeric, N_arraySize);
    if N_arraySize == 1, arraySize = repmat(arraySize, 1, D);
    else, arraySize(end+1:D) = 1; end
    
    % Convert vector of length N to 2-by-N matrix
    if sum(size(doTruncate) ~= 1) == 1, doTruncate = repmat(reshape(doTruncate, 1, []), 2, 1); end
    if sum(size(doReplace) ~= 1) == 1, doReplace = repmat(reshape(doReplace, 1, []), 2, 1); end
    if sum(size(doMirror) ~= 1) == 1, doMirror = repmat(reshape(doMirror, 1, []), 2, 1); end
    if sum(size(doCirculate) ~= 1) == 1, doCirculate = repmat(reshape(doCirculate, 1, []), 2, 1); end
    
    % Get numels
    N_isArray = numel(isArray);
    N_doTruncate = numel(doTruncate);
    N_doReplace = numel(doReplace);
    N_doMirror = numel(doMirror);
    N_doCirculate = numel(doCirculate);
    
    % Append the missing dimensions
    if N_isArray > 1, isArray(end+1:D) = false; end
    if N_doTruncate > 1, doTruncate(:,end+1:D) = false; end
    if N_doReplace > 1, doReplace(:,end+1:D) = false; end
    if N_doMirror > 1, doMirror(:,end+1:D) = false; end
    if N_doCirculate > 1, doCirculate(:,end+1:D) = false; end
    
    % Replace the ii'th nan in arraySize by ii'th dimension subindices max
    for ii = 1:D,
        if isnan(arraySize(ii)),
            if ii <= N_numeric,
                arraySize(ii) = max(varargin{ind_numeric(ii)}(:));
            else, % Or else zero
                arraySize(ii) = 0;
            end
        end
    end
    
    % Generate indices
    arraySize = double(arraySize);
    offset = 1; % Initial offset (to be updated)
    if any(doReplace), B_replace = false; end % Initial value
    ind = cast(1, newclass); % Initial value and cast to <class>
    for ii = 1:D, % Loop each dimension
        % Update the offset (except for the first)
        if ii > 1, offset = offset .* arraySize(ii-1); end
        
        % Get the ii'th dimension subindices as 'double' and substract by 1
        if ii <= N_numeric, % Use the remaining numeric varargin inputs
            subind_ii = double(varargin{ind_numeric(ii)}-1);
        else, % Or else empty
            subind_ii = [];
        end
        
        % Force column and permute to its own dimension (unless an array)
        if (N_isArray == 1 && ~isArray) || (N_isArray > 1 && ~isArray(ii)),
            subind_ii = permute(subind_ii(:), [2:ii 1 ii+1]);
        end
        
        % Separate the lower and upper out-of-bound subindices
        B_lower = subind_ii < 0;
        B_upper = subind_ii > arraySize(ii)-1;
        subind_ii_lower = subind_ii(B_lower);
        subind_ii_upper = subind_ii(B_upper);
        
        % Treat the lower out-of-bound subindices
        if any(B_lower(:)),
            if (N_doTruncate == 1 && doTruncate) || (N_doTruncate > 1 && doTruncate(1,ii)),
                subind_ii_lower(:) = 0;
            elseif (N_doReplace == 1 && doReplace) || (N_doReplace > 1 && doReplace(1,ii)),
                B_replace = bsxfun(@or, B_replace, B_lower);
            elseif (N_doMirror == 1 && doMirror) || (N_doMirror > 1 && doMirror(1,ii)),
                subind_ii_lower = mod(subind_ii_lower, 2.*arraySize(ii)) - 2.*mod(subind_ii_lower, arraySize(ii)).*(mod(subind_ii_lower, 2.*arraySize(ii))>=arraySize(ii));
            elseif (N_doCirculate == 1 && doCirculate) || (N_doCirculate > 1 && doCirculate(1,ii)),
                subind_ii_lower = mod(subind_ii_lower, arraySize(ii));
            end
        end
        
        % Treat the upper out-of-bound subindices
        if any(B_upper(:)),
            if (N_doTruncate == 1 && doTruncate) || (N_doTruncate > 1 && doTruncate(2,ii)),
                subind_ii_upper(:) = arraySize(ii)-1;
            elseif (N_doReplace == 1 && doReplace) || (N_doReplace > 1 && doReplace(2,ii)),
                B_replace = bsxfun(@or, B_replace, B_upper);
            elseif (N_doMirror == 1 && doMirror) || (N_doMirror > 1 && doMirror(2,ii)),
                subind_ii_upper = mod(subind_ii_upper, 2.*arraySize(ii)) - 2.*mod(subind_ii_upper, arraySize(ii)).*(mod(subind_ii_upper, 2.*arraySize(ii))>=arraySize(ii));
            elseif (N_doCirculate == 1 && doCirculate) || (N_doCirculate > 1 && doCirculate(2,ii)),
                subind_ii_upper = mod(subind_ii_upper, arraySize(ii));
            end
        end
        
        % Store the results for the lower and upper out-of-bound subindices
        subind_ii(B_lower) = subind_ii_lower;
        subind_ii(B_upper) = subind_ii_upper;
        
        % Shift the subindices to the true indices
        ind_ii = subind_ii.*offset; % Decided to utilize more generic 'double' although 'uint64' or 'int64' represent integers exactly beyond 2^53.
        
        % Automatic casting to minimal class (in terms of the memory usage,
        % while still being numerically exact) may be achieved via use of
        % built-in real/int min/max and related comparisons, but due to the
        % apparent implementation complexity, this feature was not
        % implemented.
        ind_ii = cast(ind_ii, newclass); % Cast to <class>
        ind = bsxfun(@plus, ind, ind_ii); % Grow ind
    end
    
    % Replace some out-of-bound values by the specified value
    if any(doReplace), ind(B_replace) = value; end
    
    % Test the indices (only if requested)
    if nargout > 1,
        if isfloat(ind), isAtClassMax = ind == realmax(newclass);
        else, isAtClassMax = ind == intmax(newclass); end
        isAnyAtClassMax = any(isAtClassMax(:));
    end
end
