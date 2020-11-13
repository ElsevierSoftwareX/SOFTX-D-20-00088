% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This is helper function to prevent unintentional mixing of variables.
function tf = wit_io_for_code_ocean_compute_capsule_helper(file),
    try,
        % Use run rather than eval for better safety
        run(file); % Assuming that the called function does not CLEAR ALL, which would stop NON-INTERACTIVE MODE!
        tf = true;
    catch me,
        disp(getReport(me, 'extended', 'hyperlinks', 'on'));
        tf = false;
    end
end
