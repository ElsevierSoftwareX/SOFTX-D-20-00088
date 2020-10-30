% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Gets class path that can be used to verify its origins.
function path = java_class_path_get(jObjectOrClassname),
    path = ''; % Result if no path is found
    if ischar(jObjectOrClassname),
        jSCL = java.lang.ClassLoader.getSystemClassLoader();
        jClass = java.lang.Class.forName(jObjectOrClassname, 0, jSCL); % Get class
    else,
        jClass = jObjectOrClassname.getClass();
    end
    jURL = jClass.getResource(['/' strrep(char(jClass.getName()), '.', '/') '.class']); % This finds resources in Bootstrap ClassLoader as well
    if ~isempty(jURL), path = char(jURL.toString()); end
end
