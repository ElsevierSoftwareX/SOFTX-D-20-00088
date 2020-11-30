% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [new_obj, Sum] = filter_sum(obj, varargin),
    fun = @(I, X, dim) sum(I, dim);
    str_fun = 'Sum';
    [new_obj, Sum] = obj.filter_fun(fun, str_fun, varargin{:});
end
