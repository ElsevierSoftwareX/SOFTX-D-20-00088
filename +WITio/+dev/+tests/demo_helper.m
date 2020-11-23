% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This is helper function to prevent unintentional mixing of variables.
function tf = demo_helper(demo_case),
    try,
        % Use run rather than eval for better safety
        WITio.demo.(demo_case); % Assuming that the called function does not CLEAR ALL, which would stop NON-INTERACTIVE MODE!
        tf = true;
    catch me,
        disp(getReport(me, 'extended', 'hyperlinks', 'on'));
        tf = false;
    end
end
