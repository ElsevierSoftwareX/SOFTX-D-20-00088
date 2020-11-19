% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Class signature tester against the provided cell array of char arrays.
function tf = java_class_signature_test(jClassSignatures, varargin),
    tf = false;
    % Test if constructor/method has correct number of params
    if numel(jClassSignatures) ~= numel(varargin),
        return;
    end
    % Test if constructor/method params match with the provided classname names
    for ii = 1:numel(varargin),
        if ~strcmp(char(jClassSignatures(ii).getName()), varargin{ii}),
            return;
        end
    end
    tf = true;
end
