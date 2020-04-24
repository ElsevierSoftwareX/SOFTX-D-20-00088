% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Gets class path that can be used to verify its origins.
function path = java_class_path_get(classname),
    path = ''; % Result if no path is found
    jSCL = java.lang.ClassLoader.getSystemClassLoader();
    jClass = java.lang.Class.forName(classname, 0, jSCL); % Get class
    jURL = jClass.getResource([char(jClass.getSimpleName()) '.class']); % This finds resources in Bootstrap ClassLoader as well
    if ~isempty(jURL), path = char(jURL.toString()); end
end
