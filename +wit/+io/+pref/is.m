% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Tests if wit_io toolbox preferences exist using built-in ISPREF function.
% This behaves like ISPREF but also treats the struct fieldnames as 'pref'.
function tf = is(pref),
    if nargin == 0, % SPECIAL CASE: no input
        tf = true;
        return;
    elseif isstruct(pref), % SPECIAL CASE: a struct input
        pref = fieldnames(pref);
    end
    tf = ispref('wit_io', pref);
end
