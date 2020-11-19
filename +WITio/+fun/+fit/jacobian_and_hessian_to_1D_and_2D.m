% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [J, H] = jacobian_and_hessian_to_1D_and_2D(bw, J, H),
    % This function converts problem with SD datasets and SP unknowns to
    % one (1) dataset and SD*SP unknowns, what is useful for lineshape fitting.
    % Implemented 21.8.2018 by Joonas T. Holmi
    
    SD = size(J, 1); % Number of datasets or independent samples
    SP = size(J, 2); % Number of parameters or dependent variables
    SP2 = size(H, 2); % Previous squared
    SDP = SD.*SP;
    
    if isempty(bw), bw = true(SD, 1); end % By default, use all datasets
    
    % Make Jacobian a 1-D column vector
    J = reshape(J.', [], 1);
    
    % Make Hessian a 2-D square matrix
    H = H(bw,:).';
    % Indices required for sparse matrix construction.
    % if SP = 4, then indices I, J become:
    % SUB1 = 1234 1234 1234 1234 5678 5678 5678 5678 ....
    % SUB2 = 1111 2222 3333 4444 5555 6666 7777 8888 ....
    kk = reshape(1:SD*SP2, [SP2 SD]);
    kk = kk(:,bw);
    SUB1 = mod(kk-1, SP)+1+floor((kk-1)/SP2)*SP;
    SUB2 = floor((kk-1)/SP)+1;
    H = sparse(SUB1(:), SUB2(:), H(:), SDP, SDP); % Allows fitting of all objective functions at once
end
