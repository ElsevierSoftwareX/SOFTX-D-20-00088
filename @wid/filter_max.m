% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [new_obj, Max] = filter_max(obj, varargin)
    fun = @(I, X, dim) max(I, [], dim);
    str_fun = 'Max';
    [new_obj, Max] = obj.filter_fun(fun, str_fun, varargin{:});
end
