% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Helper function to GET (un)formatted struct-content to wit-tree. This may
% also be useful for debugging purposes. (Un)formatted DataTree struct
% field ordering is that of the given wit tree, where available. If not
% available, then it is appended and the ordering of format tree is
% followed.
function out = DataTree_get(parent, format),
    out = struct();
    
    % Initialize empty format properly
    if nargin < 2 || isempty(format), format = cell(0,2); end

    % Test if parent has children
    parent_Data = parent.Data;
    if ~isa(parent_Data, 'WITio.obj.wit'), parent_Data = WITio.obj.wit.empty; end

    % Get unsorted format names and values and obey its ordering
    predefined_names = format(:,1);
    predefined_values = format(:,2);

    % Get unsorted children names and obey the wit tree ordering
    children = parent_Data;
    children_names = {children.Name};

    % Match children names with predefined names
    out_names = cell(1,numel(children));
    out_values = cell(1,numel(children));
    ind_predefined = zeros(size(children_names));
    bw_match_predefined = false(size(predefined_names));
    for ii = 1:numel(children_names),
        child = children(ii);
        name = children_names{ii};
        value = {}; % Only if no match is found

        % Match with the first predefined
        for jj = 1:numel(predefined_names),
            if ~bw_match_predefined(jj) && strcmp(name, predefined_names{jj}), % Test for match
                bw_match_predefined(jj) = true;
                ind_predefined(ii) = jj;
                value = predefined_values{jj};
                break;
            end
        end
        
        [out_names{ii}, out_values{ii}] = ...
            DataTree_get_helper(child, name, value);
    end
    
    % Keep nonempty
    bw_nonempty = ~cellfun(@isempty, out_names);
    out_names = out_names(bw_nonempty);
    out_values = out_values(bw_nonempty);

    % Also get mismatched predefined_names
    predefined_names = predefined_names(~bw_match_predefined);
    predefined_values = predefined_values(~bw_match_predefined);
    out_default_names = cell(1,numel(predefined_names));
    out_default_values = cell(1,numel(predefined_names));
    for ii = 1:numel(predefined_names),
        name = predefined_names{ii};
        value = predefined_values{ii};
        [out_default_names{ii}, out_default_values{ii}] = ...
            DataTree_get_helper(WITio.obj.wit.empty, name, value);
    end
    
    % Keep nonempty
    bw_default_nonempty = ~cellfun(@isempty, out_default_names);
    out_default_names = out_default_names(bw_default_nonempty);
    out_default_values = out_default_values(bw_default_nonempty);
    
    % Sort predefined first, then unmatched children names. Find INDICES...
%     [predefined_names,ind_sort_predefined] = sort(predefined_names);
%     [children_names,ind_sort_children] = sort(children_names(~ind_predefined));
%     [predefined_names sort(children_names(~ind_predefined))]
    
    % Get MATLAB-compatible fields of all existing children (including the
    % missing children). Predefined names are converted first in order to
    % retain self-consistency of generated fields in case of duplicates.
    [out_names, ind_sort] = sort([out_names out_default_names]);
    out_values = [out_values out_default_values]; % Unsorted
    out_fields = WITio.fun.indep.get_valid_and_unique_names(out_names); % Sorted
    out_fields(ind_sort) = out_fields; % Unsorted
    
    if ~isempty(out_fields),
        out = cell2struct(out_values, out_fields, 2);
    end
    
    function [out_name, out_value] = DataTree_get_helper(child, name, value),
        out_name = '';
        out_value = [];
        if isempty(value) || size(value, 2) == 2, % Nested call for subformat
            subout = wid.DataTree_get(child, value);
            if ~isempty(fieldnames(subout)), % Get if visible
                out_name = name;
                out_value = subout;
            end
        elseif value{1}, % Otherwise, get from a child (if visible)
            parser_read = value{3};
            if isempty([child.Data]), child.reload(); end % Reload Data if not yet loaded
            out_name = name;
            out_value = parser_read([child.Data]);
        end
    end
end
