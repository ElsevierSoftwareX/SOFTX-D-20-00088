% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [A, order_B_to_A] = dim_first_ipermute(B, dim),
    % BENEFIT 1: Code can be made to always operate on first dimension.
    % BENEFIT 2: Code can be made to exploit linear indices.
    
    % Specify order so that selected dim will be first
    order_A_to_B = [dim:max(dim,ndims(B)) 1:dim-1];
    
    % Reverse order
    order_B_to_A(order_A_to_B) = 1:numel(order_A_to_B);
%     order_B_to_A = ndims(B)+[2-dim:0 1-ndims(B):1-dim];

    % Rearrange dimensions of N-D array
    A = permute(B, order_B_to_A); % ipermute(B, order_A_to_B);
end
