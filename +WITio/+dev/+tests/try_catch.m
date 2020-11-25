% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function prevents unintentional mixing of variables and stops errors
% from haulting the testing process yet displays them in Command Window.
function isPassed = try_catch(WITio_function_or_script),
    try,
        WITio.(WITio_function_or_script);
        isPassed = true;
    catch me,
        disp(getReport(me, 'extended', 'hyperlinks', 'on'));
        isPassed = false;
    end
end
