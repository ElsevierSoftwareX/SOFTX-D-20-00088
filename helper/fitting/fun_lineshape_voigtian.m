% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function F = fun_lineshape_voigtian(P,X)
    % Voigtian lineshape (https://arxiv.org/abs/0805.2274)
    % size(F) = [# of dimensions = 1, # of samples]
    % size(X) = [# of points per sample, # of samples]
    % P(1,:) = Intensity
    % P(2,:) = Pos
    % P(3,:) = Fwhm of Lorentzian contribution
    % P(4,:) = Offset
    % P(5,:) = Fwhm of Gaussian contribution
    bw_L = P(5,:) == 0; % If pure Lorentzian (because Gaussian is zero!)
    bw_G = P(3,:) == 0; % If pure Gaussian (because Lorentzian is zero!)
    bw = ~bw_L & ~bw_G; % Not pure Lorentzian nor pure Gaussian
    
    Fwhm_L = P(3,bw); % FWHM of Lorentzian = 2.*omega_L
    Fwhm_G = P(5,bw); % FWHM of Gaussian = 2.*sqrt(log(2)).*omega_G
    X0 = X(:,bw)-P(2,bw); % Recentered position data
    Z = bsxfun(@rdivide, 4.*sqrt(log(2)).*bsxfun(@plus, 0.5.*Fwhm_L, 1i.*X0), Fwhm_G);
    
    F = zeros(size(X));
    nominator = real(fadf(0.5i.*Z));
    divisor = real(fadf(1i.*sqrt(log(2)).*Fwhm_L./Fwhm_G));
    F(:,bw) = bsxfun(@plus, bsxfun(@times, P(1,bw), bsxfun(@rdivide, nominator, divisor)), P(4,bw));
    F(:,bw_L) = fun_lineshape_lorentzian(P(1:4,bw_L), X(:,bw_L));
    F(:,bw_G) = fun_lineshape_gaussian(P([1:3 5],bw_G), X(:,bw_G));
end
