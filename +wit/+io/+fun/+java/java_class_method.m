% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Returns class method with the specified signature (= varargin). Each
% extra input defines a parameter class name of the sought method. This
% allows calling non-public methods as well. If class methods are inherited
% from superclass, then call this for it instead. For help, call first
% java_class_signatures first to find all available method signatures.
function fun = java_class_method(classname, methodname, varargin),
    jSCL = java.lang.ClassLoader.getSystemClassLoader();
    jClass = java.lang.Class.forName(classname, 1, jSCL); % Get class
    jMethods = jClass.getDeclaredMethods(); % Get its all declared methods
    for ii = 1:numel(jMethods), % Loop through the methods until match is found
        % Test if ii'th method has the correct name
        if ~strcmp(char(jMethods(ii).getName()), methodname),
            continue; % Skip to next method
        end
        % Test if method has correct signature
        if ~wit.io.fun.java.java_class_signature_test(jMethods(ii).getParameterTypes(), varargin{:}),
            continue; % Skip to next method
        end
        jMethods(ii).setAccessible(1); % Set public
        fun = @fun_method_helper; % Does not work if MATLAB does not recognize classname
        return;
    end
    error('No method ''%s'' with matching signature found for class ''%s''.', methodname, classname);
    function varargout = fun_method_helper(jObj, varargin),
        if numel(varargin) == 0, [varargout{1:nargout}] = jMethods(ii).invoke(jObj, []);
        else, [varargout{1:nargout}] = jMethods(ii).invoke(jObj, varargin{:}); end
    end
end
