% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Returns valid and unique names from the given strings by keeping
% alphanumerics [A-Za-z0-9] and converting all else to underscores. Also,
% any whitespace is replaced with underscore and prefix is always added if
% specified. This utilizes built-in makeValidName and makeUniqueStrings.

% This is needed when i.e. generating valid field names to structs!
function strs = get_valid_and_unique_names(strs, prefix),
    strs = regexprep(strs, '\s', '_'); % Replace any whitespace with _
    if nargin > 1, % Always add prefix if specified
        strs = regexprep(strs, '^(.*)$', sprintf('%s$1', prefix));
    end
    strs = WITio.fun.get_valid_names(strs); % Truncates to namelengthmax
%     strs = matlab.lang.makeValidName(strs); % Truncates to namelengthmax
    if iscell(strs), % Test uniqueness only if multiple strings was given
        strs = WITio.fun.get_unique_names(strs);
%         strs = matlab.lang.makeUniqueStrings(strs, true(size(strs)), namelengthmax);
    end
end
