% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This uses java.util.ArrayList to convert varargin to (1) java.lang.Object
% array, and (2) java.lang.Class array. Output (1) can be used i.e. as
% second input to the Java method's invoke-call. It is noteworthy that this
% way any modifications to its arrays, i.e. primitive type arrays, can be
% collected and used at the MATLAB side after the invoke-call! Output (2)
% can be used i.e. to find a method with the matching signature! Output (3)
% can be used i.e. to quickly inspect what class types Java side has
% obtained in human-readable form. Read the reference [1] to understand how
% MATLAB types are mapped to Java types. Idea for this code was inspired by
% the reference [2].
% [1] https://www.mathworks.com/help/matlab/matlab_external/passing-data-to-java-methods.html
% [2] https://www.mathworks.com/matlabcentral/answers/66227-syntax-for-call-to-java-library-function-with-byte-reference-parameter#answer_416021
function [jObjects, jClasses, classnames] = java_objects_from_varargin(varargin),
    % Convert varargin to a java.lang.Object array via java.util.ArrayList
    jArrayList = java.util.ArrayList();
    for ii = 1:nargin,
        jArrayList.add(varargin{ii}); % Benefit from Java's autoboxing feature!
    end
    jObjects = jArrayList.toArray(); % Get constructed java.lang.Object array
    
    % Exit here if second or higher outputs are not used
    if nargout < 2, return; end
    % Get varargin classes by reflecting getClass-method of java.lang.Class
    % in order to force java.lang.Object. Direct call to getClass will fail
    % for primitive types.
    jC_Class = java.lang.Class.forName('java.lang.Class');
    jM_getClass = jC_Class.getMethod('getClass', []);
    jClasses = java.lang.reflect.Array.newInstance(jC_Class, nargin); % Backward-compatible, because javaArray cannot initialize zero length array in older MATLAB versions.
    for ii = 1:nargin,
        if ~isempty(jObjects(ii)), % Continue if not null
            % Although SCALAR primitive types (byte, short, int, long,
            % float, double, boolean, char in Java) are correctly autoboxed
            % by their corresponding Java object wrappers on the creation
            % of java.util.ArrayList, their classes cannot be reliably
            % obtained due subsequent unboxing/autoboxing and MATLAB
            % interference. Their classes must be manually set.
            if numel(varargin{ii}) == 1, % Continue only if scalar value
                matlab_class = {'logical', 'char', 'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', 'int64', 'uint64', 'single', 'double'};
                java_class = {'Boolean', 'Character', 'Byte', 'Byte', 'Short', 'Short', 'Integer', 'Integer', 'Long', 'Long', 'Float', 'Double'};
                B_match = strcmp(matlab_class, class(varargin{ii}));
                if any(B_match),
                    java_wrapper_classname = ['java.lang.' java_class{B_match}];
                    jClasses(ii) = eval([java_wrapper_classname '.TYPE']); % Call wrapper's static TYPE field
                    continue; % Done
                end
            end
            % Arrays of primitive types require indirect call to getClass()
            jClasses(ii) = jM_getClass.invoke(jObjects(ii), []); % Subsequent unboxing/autoboxing event
        end
    end
    
    % Exit here if third or higher outputs are not used
    if nargout < 3, return; end
    classnames = cell(nargin, 1);
    for ii = 1:nargin,
        if ~isempty(jClasses(ii)), % Continue if not null
            classnames{ii} = char(jClasses(ii).getName());
        end
    end
end
