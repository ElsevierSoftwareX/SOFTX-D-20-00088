% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Runs all available tests
function tests(),
    WITio.dev.tests.demo;
    WITio.dev.tests.try_catch('dev.tests.wit_bread_bwrite');
end
