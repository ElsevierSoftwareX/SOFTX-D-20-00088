% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% The helper function for the DDEEXEC commands. This is needed to reduce
% the number of the ''-quotation enclosed texts to one per DDEEXEC command,
% because MATLAB messes up and only looks for the outermost ''-quotation
% marks when parsing the DDEEXEC command.
function [file, O_wid, O_wip, O_wit] = wip_wid_context_menus_cmd(file),
    cd(fileparts(file));
    [O_wid, O_wip, O_wit] = WITio.read(file, '-ifall');
end
