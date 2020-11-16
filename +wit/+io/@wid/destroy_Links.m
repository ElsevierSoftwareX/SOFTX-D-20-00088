% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function destroy_Links(obj),
    warning('You are using a deprecated version! Use destroy_LinksToOthers.m instead.');
    obj.destroy_LinksToOthers();
end
