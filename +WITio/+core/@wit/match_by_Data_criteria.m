% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function tags = match_by_Data_criteria(obj, test_fun),
    % Keeps the Tag(s), of which Data pass the test_fun logical test.
    % Warning is given if (1) test_fun is not applicable to some Data OR
    % (2) test_fun result cannot be converted to boolean values.
    % *USAGE EXAMPLE: Combine this call with either regexp or search and
    % then keep only the interesting. For example, can be used to find the
    % file format version changes by testing the Version-tag values.
    for ii = numel(obj):-1:1,
        bw(ii) = false; % Discard the object if not stated otherwise later.
        try, bw(ii) = logical(test_fun(obj(ii).Data));
        catch, warning('Failed to apply test_fun on Data of an object with index %d and convert result to logical. Skipping it.', ii); end
    end
    if isempty(obj), tags = obj; % Do this if obj is empty
    else, tags = obj(bw); end
end
