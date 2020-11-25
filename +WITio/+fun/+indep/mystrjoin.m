% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Mimics strjoin in order to remove dependency on R2013b or newer.
function str = mystrjoin(C, delimeter),
    if nargin < 2, delimeter = ' '; end
    C = reshape(C, 1, []);
    C(2,:) = repmat({delimeter}, size(C));
    str = [C{:}];
    str = str(1:end-1); % Remove extra delimeter in the end
end
