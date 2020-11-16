% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Returns the class methods and their output and input signatures and
% whether or not method accepts variable number of input. This allows
% getting non-public methods as well. This does not get inherited methods.
% If class methods are inherited from superclasses, then call this for them
% instead.
function [methods, returnsignatures, signatures, isVarArgs] = java_class_methods(classname),
    jSCL = java.lang.ClassLoader.getSystemClassLoader();
    jClass = java.lang.Class.forName(classname, 1, jSCL); % Get class
    jMethods = jClass.getDeclaredMethods(); % Get its all declared methods
    methods = cell(numel(jMethods), 1);
    returnsignatures = cell(numel(jMethods), 1);
    signatures = cell(numel(jMethods), 1);
    isVarArgs = false(numel(jMethods), 1);
    for ii = 1:numel(jMethods),
        methods{ii} = char(jMethods(ii).getName());
        returnsignatures(ii) = (jMethods(ii).getReturnType().getName());
        isVarArgs(ii) = jMethods(ii).isVarArgs();
        % Collect the parameter signatures
        params_ii = jMethods(ii).getParameterTypes();
        signatures_ii = cell(numel(params_ii), 1);
        for jj = 1:numel(params_ii),
            signatures_ii{jj} = char(params_ii(jj).getName());
        end
        signatures{ii} = signatures_ii;
    end
end
