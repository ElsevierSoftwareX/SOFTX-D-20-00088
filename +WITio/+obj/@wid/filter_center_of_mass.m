% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [new_obj, CoM] = filter_center_of_mass(obj, varargin),
    fun = @(I, X, dim) sum(bsxfun(@times, I, X), dim)./sum(I, dim);
    str_fun = 'Center of Mass';
    [new_obj, CoM] = obj.filter_fun(fun, str_fun, varargin{:});
end
