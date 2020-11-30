% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Returns class superclasses.
function superclasses = java_class_superclasses(classname),
    jSCL = java.lang.ClassLoader.getSystemClassLoader();
    jClass = java.lang.Class.forName(classname, 1, jSCL); % Get class
    jCurrentClass = jClass;
    superclasses = {};
    while true,
        jSuperClass = jCurrentClass.getSuperclass();
        if isempty(jSuperClass), break; end
        jCurrentClass = jSuperClass;
        superclasses{end+1,1} = char(jSuperClass.getName());
    end
end
