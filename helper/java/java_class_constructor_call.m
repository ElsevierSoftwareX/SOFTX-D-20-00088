% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Calls class constructor with the specified signature (= varargin) and
% returns its output value. All present input arrays are also returned as
% outputs, because the constructor may have modified their content.
function varargout = java_class_constructor_call(classname, varargin),
    % Convert varargin to a java.lang.Object array via java.util.ArrayList
    [jObjects, jClasses] = java_objects_from_varargin(varargin{:});
    % Then get the constructor with the matching signature
    jClass = java.lang.Class.forName(classname, 0, java.lang.ClassLoader.getSystemClassLoader());
    jConstructor = jClass.getDeclaredConstructor(jClasses); % Get the sought constructor
    % Then evaluate the sought constructor
    varargout{1} = jConstructor.newInstance(jObjects); % This can modify arrays unlike direct call!
    % Return possibly constructor-modified input arrays!
    for ii = 1:numel(varargin),
        % Append ii'th input to output if it was an array that may have
        % been modified by the called constructor
        if jClasses(ii).isArray(), 
            varargout{end+1} = jObjects(ii); % Benefit from Java's unboxing feature!
        end
    end
end
