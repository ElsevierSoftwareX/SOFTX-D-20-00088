% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Inverse of java_objects_from_varargin.
function varargout = java_objects_to_varargout(jObjects),
    % A java.lang.Object array to varargout
    for ii = numel(jObjects):-1:1,
        varargout{ii} = jObjects(ii); % Benefit from Java's unboxing feature!
    end
end
