% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Either calls class field get (if getValue is requested), getting its
% value, or set (if setValue is given), setting its value. When providing
% classname be aware that some class methods are inherited from superclass.
function getValue = java_class_field_call(classname, fieldname, jObj, setValue),
    jClass = java.lang.Class.forName(classname, 0, java.lang.ClassLoader.getSystemClassLoader());
    jField = jClass.getDeclaredField(fieldname); % Get the sought field
    % Then either get or set the sought field value
    if nargout == 1, getValue = jField.get(jObj);
    elseif nargin == 4, jField.set(jObj, setValue); end
end
