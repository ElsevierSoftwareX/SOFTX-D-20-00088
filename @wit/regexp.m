% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function tags = regexp(obj, pattern, FirstOnly, LayersFurther, PrevFullNames),
    % Finds Tag(s) by specified FullName-pattern, where '<'-characters
    % separate all Names from each other. Returns empty on failure. The
    % search is done layer by layer to ensure the best performance. Set
    % optional FirstOnly flag to true to stop the search! Another optional
    % PrevFullNames char-array is automatically used for the subsequent
    % calls for more speed-up.
    if isempty(obj), tags = wit.empty; return; end
    if nargin < 3, FirstOnly = false; end % By default, return all matches!
    if nargin < 4, LayersFurther = Inf; end % By default, return all matches!
    if nargin < 5, FullNames = {obj.FullName}; % Call FullName only for the first level
    else, FullNames = cellfun(@(x,y) [x '<' y], {obj.Name}, PrevFullNames, 'UniformOutput', false); end % Further sublevel FullName-calls are avoided
    match = ~cellfun(@isempty, regexp(FullNames, pattern, 'once')); % Benefit from cell-array speed-up
    if FirstOnly && any(match), % Special case: Limited matches
        tags = obj(find(match, 1)); % Return only the first match
    elseif LayersFurther < 1, % Special case: Limited search range
        tags = reshape(obj(match), 1, []); % Return all matches
    else,
        subobj = {obj.Children}; % Collect the children
        n = cellfun(@numel, subobj); % Collect the number of children
        ind = cumsum(accumarray(cumsum([1; reshape(n, [], 1)]), 1)); % Simulate repelem of indices for backward compability!
        PrevFullNames = FullNames(ind(1:end-1)); % Collect PrevFullNames for the children
        tags = [reshape(obj(match), 1, []) regexp(horzcat(subobj{:}), pattern, FirstOnly, LayersFurther-1, reshape(PrevFullNames, 1, []))]; % Returns always a row vector
    end
end
