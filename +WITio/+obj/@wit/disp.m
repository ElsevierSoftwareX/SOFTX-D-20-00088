% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Disp-method for wit Tree objects. Second input is optional and determines
% the maximum depth of recursion into the given wit Tree array structure.
% By default, only one recursion is performed (and tooltips are shown).
% This function can optionally output to a cell of char arrays.
function out = disp(obj, max_recursion), %#ok
    if nargin < 2, %#ok
        max_recursion = 1; % Default value
        if nargout == 0, %#ok
            C = onCleanup(@disp_tooltips); % Show tooltips even when user interrupts
        end
    end
    
    % Determine whether to print to screen or cell array
    isdefined_out = nargout ~= 0;
    if isdefined_out, %#ok
        out_line = 1;
        out = {sprintf('%s:\n', array_size_and_class_to_str(obj))};
    else, fprintf('%s:\n', array_size_and_class_to_str(obj)); end
    
    % Start recursion
    disp_recursion(obj, 0);
    
    % Helper function to show tooltips
    function disp_tooltips(), %#ok
        fprintf('\n*. How to read: (Index of nested array) Name of tag = Data of tag\n');
        fprintf('**. Tip: Run ''disp(O_wit, N);'' to show all nested wit Tree objects up to N (= 1 by default) recursions.\n');
    end
    
    % Helper function that keeps track of the recursion depth
    function disp_recursion(obj, depth), %#ok
        if isdefined_out, out{end+numel(obj),1} = []; end % Preallocate lines for each object
        Names = {obj.NameNow};
        Datas = {obj.DataNow};
        for ii = 1:numel(obj), %#ok
            Data_ii = Datas{ii};
            if ischar(Data_ii) && numel(Data_ii) <= 80, %#ok % Show (short) char array
                if isrow(Data_ii), str_ii = ['''' Data_ii ''''];
                else, str_ii = ['''' reshape(Data_ii, 1, []) '''.''']; end
            elseif (islogical(Data_ii) || isnumeric(Data_ii)) && numel(Data_ii) <= 10, %#ok % Short (short) logical or numeric array)
                str_ii = array_values_to_str(Data_ii);
            else, %#ok % Show only array size and class
                str_ii = array_size_and_class_to_str(Data_ii);
            end
            nested_call = isa(Data_ii, 'WITio.obj.wit') & depth < max_recursion;
            if nested_call, str_ii = [str_ii ':']; end %#ok
            
            % Determine whether to print to screen or cell array
            if isdefined_out, %#ok
                out_line = out_line+1;
                out{out_line,1} = sprintf('%s(%d) %s = %s\n', repmat(' ', 1, depth), ii, Names{ii}, str_ii);
            else, fprintf('%s(%d) %s = %s\n', repmat(' ', 1, depth), ii, Names{ii}, str_ii); end
            
            if nested_call, disp_recursion(Data_ii, depth+1); end % Show subsequent wit Tree objects
        end
    end

    % Helper function that converts logical/numeric array into char array
    function str = array_values_to_str(arr), %#ok
        if isempty(arr) || isvector(arr), %#ok
            if isinteger(arr), fmt = '%d';
            else, fmt = '%.4g'; end
            if iscolumn(arr), fmt = [fmt ';'];
            else, fmt = [fmt ',']; end
            str = sprintf(fmt, arr);
            str = str(1:end-1); % Remove the extra delimeter from the end
            if numel(arr) ~= 1, str = sprintf('[%s]', str); end
            if ~isa(arr, 'double'), str = sprintf('%s(%s)', class(arr), str); end
        else, str = array_size_and_class_to_str(arr); end
    end

    % Helper function that converts array size and class into char array
    function str = array_size_and_class_to_str(arr), %#ok
        str = sprintf('%dx', size(arr));
        if isa(arr, 'WITio.obj.wit'), str = sprintf('%s wit', str(1:end-1));
        else, str = sprintf('%s %s', str(1:end-1), class(arr)); end
    end
end
