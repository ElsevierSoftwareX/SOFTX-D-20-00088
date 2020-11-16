% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Helper function to SET (un)formatted struct-content to wit-tree. This may
% also be useful for debugging purposes. The ordering of format tree is
% followed. The formatting is obeyed regardless of possible conflicts
% between it and the underlying wit-tree. In conflicts, wit-tree content is
% ignored, resulting in formatted tree with empty values. This destroys any
% overridden wit-objects.
function DataTree_set(parent, in, format),
    if numel(parent) > 1, error('Cannot have multiple parents!'); end
    if ~isstruct(in), error('Only a nested struct can be a data tree!'); end
    
    % Initialize empty format properly
    if nargin < 3 || isempty(format), format = cell(0,3); end
    if ~iscell(format), error('Only a nested cell can be a format tree!'); end
    
    % Get UNSORTED format names, fields and values AND obey its ordering (PRIMARY)
    predefined_names = format(:,1);
    [predefined_names_sorted, ind_predefined_sorted] = sort(predefined_names);
    predefined_fields_sorted = get_valid_and_unique_names(predefined_names_sorted);
    predefined_fields(ind_predefined_sorted) = predefined_fields_sorted; % Unsort
%     predefined_isVisible = format(:,2); % IGNORED
    predefined_values = format(:,3);

    % Get UNSORTED children names
    children = reshape([parent.Children wit.io.wit.empty], [], 1); % Force column
    children_names = reshape({children.Name}, [], 1); % Force column

    % Get UNSORTED in-struct fields and values AND obey its ordering (SECONDARY)
    in_fields = fieldnames(in);
    in_values = struct2cell(in);

    % Match predefined names with children names and in-struct field
    ind_to_P_from_C = zeros(size(children_names));
    ind_to_C_from_P = zeros(size(predefined_names));
    ind_to_I_from_P = zeros(size(predefined_fields));
    ind_to_P_from_I = zeros(size(in_fields));
    for ii = 1:numel(predefined_names),
        name = predefined_names{ii};
        field = predefined_fields{ii};
        value = predefined_values{ii};

        % Match with the first child
        for jj = 1:numel(children),
            if ~ind_to_P_from_C(jj) && strcmp(name, children_names(jj)), % Test for match
                ind_to_P_from_C(jj) = ii;
                ind_to_C_from_P(ii) = jj;
                break;
            end
        end

        % Match with the first in-struct field
        for jj = 1:numel(in_fields),
            if ~ind_to_P_from_I(jj) && strcmp(field, in_fields(jj)), % Test for match
                ind_to_P_from_I(jj) = ii;
                ind_to_I_from_P(ii) = jj;
                break;
            end
        end

        % Create a child if not found
        if ind_to_C_from_P(ii),
            child = children(ind_to_C_from_P(ii));
        else, % No child was found,
            child = wit.io.wit(parent, name); % Append new child to the WIT-tree
        end

        if isempty(value) || size(value, 2) == 3, % CASE: empty OR YES subformat
            % If formatting is given, then obey it and ignore the underlying wit-tree if needed.
            if ind_to_I_from_P(ii), % CASE: YES found in-struct field
                wit.io.wit.DataTree_set(child, in_values{ind_to_I_from_P(ii)}, value);
            else, % CASE: NO found in-struct field
                wit.io.wit.DataTree_set(child, struct(), value);
            end
        else, % CASE: YES parser
            % If formatting is given, then obey it and ignore the underlying wit-tree if needed.
            parser_write = value{1}; % Write-parser
            parser_read = value{2}; % Read-parser
            empty_default_value = parser_read([]); % Get write-compatible but empty default value
            if ind_to_I_from_P(ii), % CASE: YES found in-struct field
                delete(child.Children); % Destroy the underlying wit-tree
                % Try to apply parser to in-struct value
                try, child.Data = parser_write(in_values{ind_to_I_from_P(ii)});
                catch, child.Data = parser_write(empty_default_value); end
            elseif ~ind_to_C_from_P(ii), % CASE: NO found in-struct field
                delete(child.Children); % Destroy the underlying wit-tree
                child.Data = parser_write(empty_default_value);
            end
        end
    end
    
    % Sort ALL non-linked children names (regardless of isVisible-state)
    children_no_link = children(~ind_to_P_from_C);
    children_names_no_link = children_names(~ind_to_P_from_C);
    [children_names_no_link_sorted, ind_sort_non_linked_children] = sort(children_names_no_link);
    children_no_link_sorted = children_no_link(ind_sort_non_linked_children);
    
    % Construct valid field names, preferring first the predefined name
    % ordering, then the non-linked children name ordering. This becomes
    % important when generated field names begin to overlap each other and
    % we need to ensure that results of predefined names remain unchanged.
    all_fields = get_valid_and_unique_names([predefined_fields_sorted; children_names_no_link_sorted]);
    children_fields_no_link_sorted = all_fields(numel(predefined_names_sorted)+1:end);
    
    % Loop through non-linked fields
    in_fields = in_fields(~ind_to_P_from_I);
    in_values = in_values(~ind_to_P_from_I);
    ind_to_I_from_C = zeros(size(children_fields_no_link_sorted));
    ind_to_C_from_I = zeros(size(in_fields));
    for ii = 1:numel(in_fields),
        field = in_fields{ii};
        value = in_values{ii};

        % Match with the first non-linked child
        for jj = 1:numel(children_no_link_sorted),
            if ~ind_to_I_from_C(jj) && strcmp(field, children_fields_no_link_sorted(jj)), % Test for match
                ind_to_I_from_C(jj) = ii;
                ind_to_C_from_I(ii) = jj;
                break;
            end
        end

        % Create a child if not found
        if ind_to_C_from_I(ii),
            child = children_no_link_sorted(ind_to_C_from_I(ii));
        else, % No child was found,
            child = wit.io.wit(parent, field); % Non-linked in-struct field string is name
        end

        if isstruct(value),
            wit.io.wit.DataTree_set(child, value, {});
        else,
            delete(child.Children); % Destroy the underlying wit-tree
            child.Data = value;
        end
    end
end
