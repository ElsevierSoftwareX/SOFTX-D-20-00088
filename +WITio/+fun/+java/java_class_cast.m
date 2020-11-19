% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Casts input object to the given class or errors.
function jObject_casted = java_class_cast(classname, jObject),
    jSCL = java.lang.ClassLoader.getSystemClassLoader();
    jClass = java.lang.Class.forName(classname, 1, jSCL); % Get class
    jObject_casted = jClass.cast(jObject);
end
