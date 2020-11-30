% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Mimics strjoin with char array input in order to remove dependency on
% R2013a or newer.
function str = mystrjoin(C, delimeter),
    if nargin < 2, delimeter = ' '; end % By default, space delimeter
    % Parse delimeter for special escape sequences like strjoin
    delimeter = regexprep(delimeter, '(\\[0\\abfnrtv])', '${sprintf($1)}'); % Interpret special escape sequences
    % Utilize repmat and matrix reshaping and concatenation to add delimeters
    C = reshape(C, 1, []); % Force row vector
    C(2,:) = repmat({delimeter}, size(C));
    str = [C{:}];
    str = str(1:end-1); % Remove extra delimeter in the end
end
