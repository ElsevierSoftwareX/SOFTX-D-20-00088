% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Returns class constructor with the specified signature (= varargin).
% Each extra input defines a parameter class name of the sought
% constructor. This allows calling non-public constructors as well. For
% help, call first java_class_signatures first to find all available
% constructor signatures.
function fun = java_class_constructor(classname, varargin),
    jSCL = java.lang.ClassLoader.getSystemClassLoader();
    jClass = java.lang.Class.forName(classname, 1, jSCL);
    jConstructors = jClass.getDeclaredConstructors(); % Get its all declared constructors
    for ii = 1:numel(jConstructors), % Loop through the methods until match is found
        % Test if constructor has correct number of params
        if ~wit.io.fun.java.java_class_signature_test(jConstructors(ii).getParameterTypes(), varargin{:}),
            continue; % Skip to next method
        end
        jConstructors(ii).setAccessible(1); % Set public
        fun = @fun_constructor_helper; % Does not work if MATLAB does not recognize classname
        return;
    end
    error('No constructor ''%s'' with matching signature found.', classname);
    function varargout = fun_constructor_helper(varargin),
        if numel(varargin) == 0, [varargout{1:nargout}] = jConstructors(ii).newInstance([]);
        else, [varargout{1:nargout}] = jConstructors(ii).newInstance(varargin{:}); end
    end
end
