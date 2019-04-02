% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [new_obj, Min] = filter_min(obj, varargin)
    fun = @(I, X, dim) min(I, [], dim);
    str_fun = 'Min';
    [new_obj, Min] = obj.filter_fun(fun, str_fun, varargin{:});
end
