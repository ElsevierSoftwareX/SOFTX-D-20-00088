% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Returns class field get and set functions. This allows accessing
% non-public fields as well. For help, call first java_class_fields first
% to find all available fields. This does not get inherited fields. If
% class fields are inherited from superclasses, then call this for them
% instead. For help, call first java_class_fields first to find all
% available fields.
function [fun_get, fun_set] = java_class_field(classname, fieldname),
    jSCL = java.lang.ClassLoader.getSystemClassLoader();
    jClass = java.lang.Class.forName(classname, 1, jSCL); % Get class
    jFields = jClass.getDeclaredFields(); % Get its all declared fields
    for ii = 1:numel(jFields), % Loop through the fields until match is found
        % Test if ii'th method has the correct name
        if ~strcmp(char(jFields(ii).getName()), fieldname),
            continue; % Skip to next method
        end
        jFields(ii).setAccessible(1); % Set public
        fun_get = @fun_field_get_helper; % Does not work if MATLAB does not recognize classname
        fun_set = @fun_field_set_helper; % Does not work if MATLAB does not recognize classname
        return;
    end
    error('No field %s exists for class %s.', fieldname, classname);
    function value = fun_field_get_helper(jObj),
        value = jFields(ii).get(jObj);
    end
    function fun_field_set_helper(jObj, value),
        jFields(ii).set(jObj, value);
    end
end
