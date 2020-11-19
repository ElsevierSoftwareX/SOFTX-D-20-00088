% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Calls class method with the specified signature (= varargin) and returns
% its possible output value. If method is static, then set jObj to empty
% []. All present input arrays are also returned as outputs, because the
% method may have modified their content. When providing classname be aware
% that some class methods are inherited from superclass.
% EXAMPLE:
% jFIS = java.io.FileInputStream('file.txt');
% buffer = zeros(1024.^2, 1, 'int8'); % 1 MB buffer
% [N_read, buffer] = WITio.fun.java.java_class_method_call('java.io.InputStream', 'read', jFIS, buffer, int32(0), int32(numel(buffer)); % This indirect call updates buffer but direct call to N_read = jFIS.read(buffer, 0, numel(buffer)); will not.
function varargout = java_class_method_call(classname, methodname, jObj, varargin),
    % Convert varargin to a java.lang.Object array via java.util.ArrayList
    [jObjects, jClasses] = WITio.fun.java.java_objects_from_varargin(varargin{:});
    % Then get the method with the matching signature
    jClass = java.lang.Class.forName(classname, 0, java.lang.ClassLoader.getSystemClassLoader());
    jMethod = jClass.getDeclaredMethod(methodname, jClasses); % Get the sought method
    N_output = ~strcmp(char(jMethod.getReturnType().getName()), 'void');
    % Then evaluate the sought method
    if N_output == 0,
        jMethod.invoke(jObj, jObjects); % This can modify arrays unlike direct call!
    else,
        varargout{1} = jMethod.invoke(jObj, jObjects); % This can modify arrays unlike direct call!
    end
    % Return possibly method-modified input arrays!
    for ii = 1:numel(varargin),
        % Append ii'th input to output if it was an array that may have
        % been modified by the called method
        if jClasses(ii).isArray(), 
            varargout{end+1} = jObjects(ii); % Benefit from Java's unboxing feature!
        end
    end
end
