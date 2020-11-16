% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Returns the class constructor or method signatures. This allows getting
% non-public constructor or method signatures as well. The class
% constructor signatures are returned when methodname is omitted.
function signatures = java_class_signatures(classname, methodname),
    jSCL = java.lang.ClassLoader.getSystemClassLoader();
    jClass = java.lang.Class.forName(classname, 1, jSCL); % Get class
    if nargin == 2, jCorM = jClass.getDeclaredMethods(); % Get its all declared methods
    else, jCorM = jClass.getDeclaredConstructors(); end % Get its all declared constructors
    signatures = {};
    for ii = 1:numel(jCorM), % Loop until match is found
        jCorM_ii = jCorM(ii);
        % If method, then test if it has the correct name
        if nargin == 2 && ~strcmp(char(jCorM_ii.getName()), methodname),
            continue; % Skip to next method
        end
        % Collect the signatures
        jCorM_ii_params = jCorM_ii.getParameterTypes();
        signatures_ii = cell(numel(jCorM_ii_params), 1);
        for jj = 1:numel(jCorM_ii_params),
            signatures_ii{jj} = char(jCorM_ii_params(jj).getName());
        end
        signatures{end+1,1} = signatures_ii;
    end
end
