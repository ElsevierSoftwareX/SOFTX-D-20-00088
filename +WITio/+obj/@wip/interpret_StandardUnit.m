% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% StandardUnit is a search string for WITio.obj.wip.FullStandardUnits, where it is
% seen in the ()-brackets. Please note that this will automatically add
% ()-brackets for the searching purposes! If StandardUnit is NOT found,
% then this will return it without modifications.

% SPECIAL CASES: Due to use of some non-ASCII characters in the units, such
% as �'s (U+00C5) and �'s (U+00B5), a secondary search string is
% automatically generated by replacing A's with �'s (U+00C5) and u's with
% �'s (U+00B5) and searching again. For instance, a search string 'um' will
% generate same result as '�m'.
function ValueUnit = interpret_StandardUnit(StandardUnit),
    ValueUnit = StandardUnit; % Unmodified output for no match
    StandardUnit_known_specials = regexprep(regexprep(StandardUnit, 'A', '\xC5'), 'u', '\xB5'); % Replace A's with �'s and u's with �'s ...
    bw_match = ~cellfun(@isempty, strfind(WITio.obj.wip.FullStandardUnits, ['(' StandardUnit ')'])) | ...
        ~cellfun(@isempty, strfind(WITio.obj.wip.FullStandardUnits, ['(' StandardUnit_known_specials ')']));
    if sum(bw_match) == 1, % Continue only if one match was found
        ValueUnit = WITio.obj.wip.FullStandardUnits{bw_match}; % Modified output
    end
end