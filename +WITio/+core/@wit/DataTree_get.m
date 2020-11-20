% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Helper function to GET (un)formatted struct-content to wit-tree. This may
% also be useful for debugging purposes. (Un)formatted DataTree struct
% field ordering is that of the given wit tree, where available. If not
% available, then it is appended to the end of the struct and the ordering
% of format tree is followed. The formatting is obeyed regardless of
% possible conflicts between it and the underlying wit-tree. In conflicts,
% wit-tree content is ignored, resulting in formatted tree with empty
% structs. The generated field names obey first the sorted format names,
% then the sorted unformatted wit-tree node names.
function out = DataTree_get(parent, format),
    if numel(parent) > 1, error('Cannot have multiple parents!'); end
    
    % Initialize empty format properly
    if nargin < 2 || isempty(format), format = cell(0,3); end
    if ~iscell(format), error('Only a nested cell can be a format tree!'); end

    % Get UNSORTED format names and values AND obey its ordering (SECONDARY)
    predefined_names = format(:,1);
    predefined_isVisible = format(:,2);
    predefined_values = format(:,3);

    % Get UNSORTED children names AND obey the wit tree ordering (PRIMARY)
    children = reshape([parent.Children WITio.core.wit.empty], [], 1); % Force column
    children_names = reshape({children.Name}, [], 1); % Force column

    % Match children names with predefined names
    out_names = cell(size(children));
    out_values = cell(size(children));
    ind_to_P_from_C = zeros(size(children_names));
    ind_to_C_from_P = zeros(size(predefined_names));
    for ii = 1:numel(children_names),
        child = children(ii);
        name = children_names{ii};
%         isVisible = isempty(format); % Only if no match is found
        isVisible = true; % Only if no match is found
        value = {}; % Only if no match is found

        % Match with the first predefined
        for jj = 1:numel(predefined_names),
            if ~ind_to_C_from_P(jj) && strcmp(name, predefined_names{jj}), % Test for match
                ind_to_P_from_C(ii) = jj;
                ind_to_C_from_P(jj) = ii;
                isVisible = predefined_isVisible{jj};
                value = predefined_values{jj};
                break;
            end
        end
        
        [out_names{ii}, out_values{ii}] = ...
            DataTree_get_helper(child, name, isVisible, value);
    end
    
    % Keep nonempty
    bw_nonempty = ~cellfun(@isempty, out_names);
    
    % Loop through non-linked predefined_names
    predefined_names_no_link = predefined_names(~ind_to_C_from_P);
    predefined_isVisible_no_link = predefined_isVisible(~ind_to_C_from_P);
    predefined_values_no_link = predefined_values(~ind_to_C_from_P);
    out_default_names = cell(size(predefined_names_no_link));
    out_default_values = cell(size(predefined_names_no_link));
    for ii = 1:numel(predefined_names_no_link),
        name = predefined_names_no_link{ii};
        isVisible = predefined_isVisible_no_link{ii};
        value = predefined_values_no_link{ii};
        [out_default_names{ii}, out_default_values{ii}] = ...
            DataTree_get_helper(WITio.core.wit.empty, name, isVisible, value);
    end
    
    % Keep nonempty
    bw_remaining_nonempty = ~cellfun(@isempty, out_default_names);
    
    % Sort ALL predefined names (regardless of isVisible-state)
    [predefined_names_sorted, ind_sort_predefined] = sort(predefined_names);
    ind_to_C_from_P_sorted = ind_to_C_from_P(ind_sort_predefined); % Sort
    
    % Sort ALL non-linked children names (regardless of isVisible-state)
    ind_non_linked_children = find(~ind_to_P_from_C);
    children_names_no_link = children_names(~ind_to_P_from_C);
    [children_names_no_link_sorted, ind_sort_non_linked_children] = sort(children_names_no_link);
    ind_non_linked_children_sorted = ind_non_linked_children(ind_sort_non_linked_children);
    
    % Construct valid field names, preferring first the predefined name
    % ordering, then the non-linked children name ordering. This becomes
    % important when generated field names begin to overlap each other and
    % we need to ensure that results of predefined names remain unchanged.
    all_names = [predefined_names_sorted; children_names_no_link_sorted];
    all_fields = WITio.fun.indep.get_valid_and_unique_names(all_names); % Performance bottleneck is here in the underlying MATLAB built-in functions!
    
    % Generate UNSORTED indices to predefined names or P and children names or C
    ind_P = 1:numel(predefined_names_sorted); % Indices to sorted predefined names
    ind_C(ind_to_C_from_P_sorted(~~ind_to_C_from_P_sorted)) = ind_P(~~ind_to_C_from_P_sorted); % Link children to sorted predefined names
    ind_C(ind_non_linked_children_sorted) = numel(predefined_names)+1:numel(all_fields); % Indices to sorted non-linked children
    ind_P_no_link = find(~ind_to_C_from_P_sorted); % Keep only the non-linked indices
    
    % Unwinding the results using the indices above
    out_fields = [all_fields(ind_C(bw_nonempty)); all_fields(ind_P_no_link(bw_remaining_nonempty))]; % [children_names(bw_nonempty) predefined_names_no_link(bw_remaining_nonempty)]
    out_values = [out_values(bw_nonempty); out_default_values(bw_remaining_nonempty)];
    
    out = cell2struct(out_values, out_fields, 1);
    
    function [out_name, out_value] = DataTree_get_helper(child, name, isVisible, value),
        % Reload Data if not yet loaded
        if isempty([child.Data]), child.reload(); end 
        
        out_name = ''; % Result upon failure
        out_value = []; % Result upon failure
        if isVisible, % CASE: YES visible
            if (isempty(value) && isa([child.Data], 'WITio.core.wit')) ... % CASE: NO subformat AND child has YES children
                    || size(value, 2) == 3, % OR CASE: YES subformat
                % If formatting is given, then obey it and ignore the underlying wit-tree if needed.
                out_name = name;
                out_value = WITio.core.wit.DataTree_get(child, value);
            elseif (isempty(value) && ~isa([child.Data], 'WITio.core.wit')) ... % CASE: NO parser AND child has NO children
                    || size(value, 1) == 2, % OR CASE: YES parser
                % If formatting is given, then obey it and ignore the underlying wit-tree if needed.
                out_name = name;
                if isempty(value), % CASE: No parser
                     out_value = [child.Data];
                else, % CASE: Parser
                    parser_read = value{2}; % Read-parser
                    % Try to apply parser to child's Data.
                    try, out_value = parser_read([child.Data]);
                    catch, out_value = parser_read([]); end
                end
            end
        end
    end
end
