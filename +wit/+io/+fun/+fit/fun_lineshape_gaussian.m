% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function F = fun_lineshape_gaussian(P, X),
    % Gaussian lineshape
    % size(F) = [# of dimensions = 1, # of samples]
    % size(X) = [# of points per sample, # of samples]
    % P(1,:) = Intensity
    % P(2,:) = Pos
    % P(3,:) = Fwhm
    % P(4,:) = Offset
    % P(1,:).*P(3,:).*sqrt(pi./log(2))./2 = Area
    F = bsxfun(@plus, bsxfun(@times, P(1,:), exp(-log(2).*bsxfun(@rdivide, 2.*bsxfun(@minus, X, P(2,:)), P(3,:)).^2)), P(4,:));
end
