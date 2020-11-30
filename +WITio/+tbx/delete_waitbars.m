% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function delete_waitbars(),
    delete(findobj(allchild(0), 'flat', 'Tag', 'TMWWaitbar')); % Avoids the closing issues with close-function!
end
