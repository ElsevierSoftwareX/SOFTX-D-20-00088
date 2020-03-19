% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Tests whether the code is ran under Octave or not.
function tf = is_octave(),
    persistent is_octave;
    if isempty(is_octave), is_octave = exist('OCTAVE_VERSION', 'builtin') == 5; end
    tf = is_octave;
end
