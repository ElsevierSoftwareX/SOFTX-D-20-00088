% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% StandardUnit is a search string for wip.FullStandardUnits, where it is
% seen in the ()-brackets. Please note that this will automatically add
% ()-brackets for the searching purposes! If StandardUnit is NOT found,
% then this will return it without modifications.
function ValueUnit = interpret_StandardUnit(StandardUnit)
    ValueUnit = StandardUnit; % Unmodified output for no match
    bw_match = ~cellfun(@isempty, strfind(wip.FullStandardUnits, ['(' StandardUnit ')']));
    if sum(bw_match) == 1, % Continue only if one match was found
        ValueUnit = wip.FullStandardUnits{bw_match}; % Modified output
    end
end
