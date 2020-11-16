% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [B, order_A_to_B] = dim_first_permute(A, dim),
    % BENEFIT 1: Code can be made to always operate on first dimension.
    % BENEFIT 2: Code can be made to exploit linear indices.

    % Specify order so that selected dim will be first
    order_A_to_B = [dim:ndims(A) 1:dim-1];

    % Rearrange dimensions of N-D array
    B = permute(A, order_A_to_B);
end
