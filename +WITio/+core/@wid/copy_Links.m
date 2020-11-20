% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function copy_Links(obj),
    warning('You are using a deprecated version! Use copy_LinksToOthers.m instead.');
    obj.copy_LinksToOthers();
end
