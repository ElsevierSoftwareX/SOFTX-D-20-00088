% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Returns the class fields and their type signatures. This allows getting
% non-public fields as well. This does not get inherited fields. If class
% fields are inherited from superclasses, then call this for them instead.
function [fields, signatures] = java_class_fields(classname),
    jSCL = java.lang.ClassLoader.getSystemClassLoader();
    jClass = java.lang.Class.forName(classname, 1, jSCL); % Get class
    jFields = jClass.getDeclaredFields(); % Get its all declared fields
    fields = cell(numel(jFields), 1);
    signatures = cell(numel(jFields), 1);
    for ii = 1:numel(jFields),
        fields{ii} = char(jFields(ii).getName());
        signatures{ii} = char(jFields(ii).getType().getName());
    end
end
