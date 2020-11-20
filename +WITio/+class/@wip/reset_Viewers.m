% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function reset_Viewers(obj),
    warning('You are using a deprecated version! Use destroy_all_Viewers.m instead.');
    obj.destroy_all_Viewers;
end
