% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Disp-method for wit Tree objects, enriched with html-links when possible.
% Optional 2nd input determines the maximum depth of recursion into the
% given wit Tree array structure. (Optional 3rd input is used internally.)
% By default, no recursion is used, and tooltips are shown only once per
% MATLAB instance. This function can optionally output to a cell of char
% arrays instead of Command Window.
function out = disp(obj, max_recursion, forceTooltip), %#ok
    if nargin < 2, max_recursion = 0; end % Default value
    if nargin < 3, forceTooltip = false; end % Default value
    persistent showTooltip;
    if forceTooltip, showTooltip = []; end
    
    % Determine whether or not to use html links (when no output arguments)
    substruct = '';
    useHtmlLinks = ~nargout & usejava('desktop'); % The html links are possible only if MATLAB is running in Desktop-mode
    if useHtmlLinks, %#ok
        inputname_1 = inputname(1);
        if isempty(inputname_1), useHtmlLinks = false; end % Html cannot be used, because the input variable is not known
    end
    
    % Generate lines
    lines = {sprintf('%s:\n', array_size_and_class_to_str(obj, 0))};
    disp_recursion(obj, 0);
    
    % Determine whether or not to output lines to Command Window
    if nargout, out = lines;
    else, fprintf([lines{:}]); end
    
    % Show tooltip once
    if nargout == 0,
        if isempty(showTooltip), %#ok
            fprintf('\n?: (Index of nested array) Name of tag = Data of tag\n');
            fprintf('!: Run ''disp(O_wit, N);'' to show all nested wit Tree objects up to N (= 0 by default) recursions.\n');
            showTooltip = false;
        elseif useHtmlLinks,
            fprintf('\n<a href="matlab:clc;disp(%s,%d,1);">?!</a>\n', inputname_1, max_recursion);
        end
    end
    
    % Helper function that keeps track of the recursion depth
    function disp_recursion(obj, depth), %#ok
        Names = {obj.NameNow};
        Datas = {obj.DataNow};
        substruct_old = substruct;
        for ii = 1:numel(obj), %#ok
            substruct = sprintf('%s(%d)', substruct_old, ii);
            Data_ii = Datas{ii};
            if ischar(Data_ii) && numel(Data_ii) <= 80, %#ok % Show (short) char array
                if isrow(Data_ii), str_ii = ['''' Data_ii ''''];
                else, str_ii = ['''' reshape(Data_ii, 1, []) '''.''']; end
            elseif (islogical(Data_ii) || isnumeric(Data_ii)) && numel(Data_ii) <= 10, %#ok % Short (short) logical or numeric array)
                str_ii = array_values_to_str(Data_ii, depth+1);
            else, %#ok % Show only array size and class
                str_ii = array_size_and_class_to_str(Data_ii, depth+1);
            end
            nested_call = isa(Data_ii, 'WITio.obj.wit') & depth < max_recursion;
            if nested_call, str_ii = [str_ii ':']; end %#ok
            
            % Print to a cell array
            if useHtmlLinks, %#ok % Show link to parent
                if depth == 0 && ~isempty(obj(ii).ParentNow), indent = sprintf('%s<a href="matlab:clc;ans=%s%s.Parent;disp(ans,1);">^</a>', repmat(' ', 1, depth), inputname_1, substruct);
                else, indent = repmat(' ', 1, depth+1); end
                lines{end+1,1} = sprintf('%s(<a href="matlab:clc;ans=%s%s;disp(ans,%d);">%d</a>) %s = %s\n', indent, inputname_1, substruct, ~(max_recursion >= depth+1), ii, Names{ii}, str_ii); %#ok
            else, %#ok
                lines{end+1,1} = sprintf('%s(%d) %s = %s\n', repmat(' ', 1, depth+1), ii, Names{ii}, str_ii); %#ok
            end
            
            if nested_call, %#ok % Show subsequent wit Tree objects
                substruct = sprintf('%s.Data', substruct);
                disp_recursion(Data_ii, depth+1);
            end
        end
    end

    % Helper function that converts logical/numeric array into char array
    function str = array_values_to_str(arr, depth), %#ok
        if isempty(arr) || isvector(arr), %#ok
            if isinteger(arr), fmt = '%d';
            else, fmt = '%.4g'; end
            if iscolumn(arr), fmt = [fmt ';'];
            else, fmt = [fmt ',']; end
            str = sprintf(fmt, arr);
            str = str(1:end-1); % Remove the extra delimeter from the end
            if numel(arr) ~= 1, str = sprintf('[%s]', str); end
            if ~isa(arr, 'double'), str = sprintf('%s(%s)', class(arr), str); end
        else, str = array_size_and_class_to_str(arr, depth); end
    end

    % Helper function that converts array size and class into char array
    function str = array_size_and_class_to_str(arr, depth), %#ok
        str = sprintf('%dx', size(arr));
        if isa(arr, 'WITio.obj.wit'), %#ok
            if useHtmlLinks,  str = sprintf('<a href="matlab:clc;ans=%s%s;disp(ans,%d);">%s wit</a>', inputname_1, substruct, ~(max_recursion >= depth), str(1:end-1));
            else, str = sprintf('%s wit', str(1:end-1)); end
        else, str = sprintf('%s %s', str(1:end-1), class(arr)); end
    end
end
