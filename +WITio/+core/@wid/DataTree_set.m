% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Helper function to SET (un)formatted struct-content to wit-tree. This may
% also be useful for debugging purposes.
function DataTree_set(parent, in, format),
    % Initialize empty format properly
    if nargin < 3 || isempty(format), format = cell(0,2); end
    
    % Test if parent has children
    parent_Data = parent.Data;
    if ~isa(parent_Data, 'WITio.core.wit'), parent_Data = WITio.core.wit.empty; end % No children
    
    % Sort format fields and values by names
    [predefined_names, ind_predefined_sorted] = sort(format(:,1));
    predefined_fields = WITio.fun.get_valid_and_unique_names(predefined_names);
    predefined_values = format(ind_predefined_sorted,2);

    % Sort children by names
    children = parent_Data;
    [children_names, ind_children_sorted] = sort({children.Name});
    children = children(ind_children_sorted);

    % Get in-struct fields and values
    in_fields = fieldnames(in);
    in_values = struct2cell(in);

    % Match predefined names with children names and in-struct field
    ind_child = zeros(size(predefined_names));
    bw_match_children = false(size(children_names));
    ind_in = zeros(size(predefined_fields));
    bw_match_in = false(size(in_fields));
    for ii = 1:numel(predefined_names),
        name = predefined_names{ii};
        field = predefined_fields{ii};
        value = predefined_values{ii};

        % Match with the first child
        for jj = 1:numel(children),
            if ~bw_match_children(jj) && strcmp(name, children_names(jj)), % Test for match
                bw_match_children(jj) = true;
                ind_child(ii) = jj;
                break;
            end
        end

        % Match with the first in-struct field
        for jj = 1:numel(in_fields),
            if ~bw_match_in(jj) && strcmp(field, in_fields(jj)), % Test for match
                bw_match_in(jj) = true;
                ind_in(ii) = jj;
                break;
            end
        end

        % Create a child if not found
        if ind_child(ii),
            child = children(ind_child(ii));
        else, % No child was found,
            child = WITio.core.wit(name);
            parent_Data = [parent_Data child];
            parent.Data = parent_Data; % Add it to the WIT-tree
        end

        if isempty(value) || size(value, 2) == 2, % Nested call for subformat
            if ind_in(ii),
                wid.DataTree_set(child, in_values{ind_in(ii)}, value);
            else,
                wid.DataTree_set(child, struct(), value); % Missing field
            end
        else, % Otherwise, set to a child
            parser_write = value{2};
            if ind_in(ii), % Parse and set found input field
                child.Data = parser_write(in_values{ind_in(ii)});
            elseif ~ind_child(ii), % Set empty ONLY for CREATED child
                child.Data = parser_write([]);
            end
        end
    end

    % Get MATLAB-compatible fields of all existing children (including the
    % missing children). Predefined names are converted first in order to
    % retain self-consistency of generated fields in case of duplicates.
    bw_children = [ind_child(:)~=0; true(sum(~bw_match_children), 1)];
    all_existing_fields = WITio.fun.get_valid_and_unique_names([predefined_names(:).' children_names(~bw_match_children)]);
    ind = [reshape(ind_child(ind_child~=0), [], 1); find(~bw_match_children(:))];
    children_fields(ind) = all_existing_fields(bw_children);

    % Handle unused fields
    in_fields = in_fields(~bw_match_in);
    in_values = in_values(~bw_match_in);
    for ii = 1:numel(in_fields),
        field = in_fields{ii};
        name = field;
        value = in_values{ii};
        ind_child = 0;

        % Match with the first child
        for jj = 1:numel(children),
            if ~bw_match_children(jj) && strcmp(field, children_fields(jj)), % Test for match
                bw_match_children(jj) = true;
                ind_child = jj;
                break;
            end
        end

        % Create a child if not found
        if ind_child,
            child = children(ind_child);
        else, % No child was found,
            child = WITio.core.wit(name);
            parent_Data = [parent_Data child];
            parent.Data = parent_Data; % Add it to the WIT-tree
        end

        child.Data = value;
    end
end
