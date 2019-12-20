% Generalizes built-in trapz to N-D matrices of X and Y. They must be sized
% consistently in a way that they can be repmat'ed into same size.
function Z = mtrapz(X, Y, dim),
    % Permute the dim'th dimension to the 1st dimension
    ndims_max = max(ndims(X), ndims(Y));
    perm_dim_to_1 = [dim:ndims_max 1:dim-1];
    X = permute(X, perm_dim_to_1); % Can be an N-D matrix
    Y = permute(Y, perm_dim_to_1); % Can be an N-D matrix
    
    % Make X and Y equivalent in size.
    [X, Y] = dim_size_consistent_repmat(X, Y);
    
    % Store the output size
    SZ = size(Y);
    SZ(1) = 1;
    
    % Trapezoid sum using column width and height information
    H = (Y(1:end-1,:) + Y(2:end,:))./2; % Column width (from N-D to 2-D)
    W = X(2:end,:) - X(1:end-1,:); % Average column height (from N-D to 2-D)
    A = W.*H; % Column area
    Z = sum(A, 1); % Total column area
    
    % Further performance boost may be achieved through use of sparse
    % matrices if they can be constructed cheaply.
    
    % Restore the original shape
    Z = ipermute(reshape(Z, SZ), perm_dim_to_1);
end
