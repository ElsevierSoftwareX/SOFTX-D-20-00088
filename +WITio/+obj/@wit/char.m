% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function converts the given (possibly nested) wit objects into a
% cell of char arrays, for much easier and faster vectorizable form. If you
% need to sort or unique the object array, then instead call the member
% methods sort_by_Name_Data or unique_by_Name_Data, which are optimized.
function strs = char(obj), %#ok
    % Handle the nested wit objects, logicals and chars first and then typecast
    strs = cell(size(obj));
    Names = {obj.NameNow}; % This is faster than direct indexing of objects
    Datas = {obj.DataNow}; % This is faster than direct indexing of objects
    for ii = 1:numel(obj), %#ok
        Data_ii = Datas{ii};
        Numel_ii = numel(Data_ii);
        Class_ii = class(Data_ii);
        if strcmp(Class_ii, 'WITio.obj.wit'), %#ok
            Data_ii = char(Data_ii);
            Data_ii = [Data_ii{:}]; % Merge together
        else, %#ok
            Data_ii = to_char_array(Data_ii);
        end
        strs{ii} = [Names{ii} Class_ii char(typecast(Numel_ii, 'uint16')) Data_ii];
    end
    
    function str = to_char_array(input), %#ok
        if islogical(input), %#ok % Handle casting of logicals
            str = reshape(input, 1, []);
            if mod(numel(input), 2), str(end+1) = false; end % Append false if odd length
            str = char(typecast(uint8(str), 'uint16'));
        elseif iscell(input), %#ok
            str = cellfun(@to_char_array, reshape(input, 1, []), 'UniformOutput', false);
            str = [cellfun(@(x) char(typecast(numel(x), 'uint16')), str, 'UniformOutput', false); str]; % Append typecasted numels as delimeters with no risk of false positives
%             str(2,:) = {char(0)}; % Append (unlikely) 0-characters as delimeters with small risk of false positives
            str = [str{:}]; % Merge together
        elseif ischar(input), str = reshape(input, 1, []);
        elseif isa(input, 'uint8') || isa(input, 'int8'), %#ok % Handle casting of int8/uint8
            str = reshape(input, 1, []);
            if mod(numel(input), 2), str(end+1) = 0; end % Append 0 if odd length
            str = char(typecast(str, 'uint16'));
        else, str = char(typecast(reshape(input, 1, []), 'uint16')); end
    end
end
