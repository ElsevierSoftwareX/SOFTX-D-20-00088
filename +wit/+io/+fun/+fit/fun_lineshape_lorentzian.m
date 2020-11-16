% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function F = fun_lineshape_lorentzian(P, X),
    % Lorentzian lineshape
    % size(F) = [# of dimensions = 1, # of samples]
    % size(X) = [# of points per sample, # of samples]
    % P(1,:) = Intensity
    % P(2,:) = Pos
    % P(3,:) = Fwhm
    % P(4,:) = Offset
    % P(1,:).*P(3,:).*pi./2 = Area
    F = bsxfun(@plus, bsxfun(@rdivide, P(1,:), (1 + bsxfun(@rdivide, 2.*bsxfun(@minus, X, P(2,:)), P(3,:)).^2)), P(4,:));
end
