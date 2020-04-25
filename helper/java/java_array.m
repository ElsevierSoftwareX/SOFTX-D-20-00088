% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This uses java.lang.reflect.Array to construct a multi-dimensional Java
% array. Its class is either like the given value or the given class name.
% Its dimensions are provided as extra inputs and can also be zeros.
function jArray = java_array(LikeValueOrClassname, varargin),
    if numel(varargin) == 0,
        error('Not enough input arguments.');
    end
    if ischar(LikeValueOrClassname),
        jC_Array = java.lang.Class.forName(LikeValueOrClassname);
    else,
        [~, jClasses] = java_objects_from_varargin(LikeValueOrClassname);
        jC_Array = jClasses(1);
    end
    % Remove class array wrapping
    while jC_Array.isArray(),
        jC_Array = jC_Array.getComponentType();
    end
    % Construct Java array. This is backward-compatible and can also
    % initialize zero length array unlike javaArray of older MATLAB
    % versions.
    jArray = java.lang.reflect.Array.newInstance(jC_Array, [varargin{:}]);
end
