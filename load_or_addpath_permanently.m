% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

this_script = [mfilename('fullpath') '.m'];
[root, ~, ~] = fileparts(this_script);
toolbox_path = root; % This if in the same folder as wit_io
addpath(genpath(toolbox_path)); % Add all subfolder dependencies!
savepath; % Permanently save the dependencies
