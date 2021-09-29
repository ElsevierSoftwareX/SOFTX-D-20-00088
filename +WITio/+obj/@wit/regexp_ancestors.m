% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function tags = regexp_ancestors(obj, pattern, FirstOnly, LayersFurther), %#ok
    % Finds Tag(s) ANCESTORS by specified FullName-pattern, where
    % '<'-characters separate all Names from each other. Returns empty on
    % failure. The search is done layer by layer to ensure the best
    % performance. Set optional FirstOnly flag to true to stop the search!
    % Another optional PrevFullNames char-array is automatically used for
    % the subsequent calls for more speed-up.
    if isempty(obj), tags = WITio.obj.wit.empty; return; end
    if nargin < 3, FirstOnly = false; end % By default, return all matches!
    if nargin < 4, LayersFurther = Inf; end % By default, return all matches!
    FullNames = {obj.FullName};
    match = ~cellfun(@isempty, regexp(FullNames, pattern, 'once')); % Benefit from cell-array speed-up
    if FirstOnly && any(match), %#ok % Special case: Limited matches
        tags = obj(find(match, 1)); % Return only the first match
    elseif LayersFurther < 1, %#ok % Special case: Limited search range
        tags = reshape(obj(match), 1, []); % Return all matches
    else, %#ok
        superobj = {obj.ParentNow}; % Collect the parents
        tags = [reshape(obj(match), 1, []) regexp_ancestors([superobj{:} WITio.obj.wit.empty], pattern, FirstOnly, LayersFurther-1)]; % Returns always a row vector
    end
end
