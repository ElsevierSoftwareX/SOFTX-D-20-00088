% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Mimics matlab.lang.makeValidName(strs) behaviour, missing before R2014a.
function strs = get_valid_names(strs)
%     strs = regexprep(strs, '\s+(.)', '${upper($1)}'); % Deletes any whitespace characters before replacing any characters. If a whitespace character is followed by a lowercase letter, converts the letter to the corresponding uppercase character.
    strs = regexprep(strs, '[^A-Za-z0-9_]', '_'); % A valid MATLAB identifier is a character vector of alphanumerics (AZ, az, 09) and underscores.
    strs = regexprep(strs, '^([^A-Za-z])', 'x$1'); % Such that the first character is a letter.
    if iscell(strs), [strs{cellfun(@isempty, strs)}] = deal('x'); % Such that the first character is a letter.
    elseif isempty(strs), strs = 'x'; end % Such that the first character is a letter.
    strs = regexprep(strs, sprintf('^(.{0,%d}).*$', namelengthmax), '$1'); % The length of the character vector is less than or equal to namelengthmax.
end
