% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function F = fun_lineshape_voigtian(P, X),
    % Voigtian lineshape (https://arxiv.org/abs/0805.2274 and
    % https://arxiv.org/abs/1905.12851)
    % size(F) = [# of dimensions = 1, # of samples]
    % size(X) = [# of points per sample, # of samples]
    % P(1,:) = Intensity
    % P(2,:) = Pos
    % P(3,:) = |Fwhm of Lorentzian contribution|
    % P(4,:) = Offset
    % P(5,:) = |Fwhm of Gaussian contribution|
    B_L = isinf(P(3,:)./P(5,:)); % If pure Lorentzian (because Gaussian contribution is infinitely smaller!)
    B_G = isinf(P(5,:)./P(3,:)); % If pure Gaussian (because Lorentzian contribution is infinitely smaller!)
    B_V = ~B_L & ~B_G; % Not pure Lorentzian nor pure Gaussian
    
    % Center the position data
    X0 = X(:,B_V)-P(2,B_V);
    
    % Convert negative FWHM values to positive to avoid non-Voigt results
    Fwhm_L = abs(P(3,B_V)); % FWHM of Lorentzian = 2.*omega_L
    Fwhm_G = abs(P(5,B_V)); % FWHM of Gaussian = 2.*sqrt(log(2)).*omega_G;
    
    % Generate positions in the complex plane for the Faddeeva function
    Z = 2.*sqrt(log(2)).*bsxfun(@rdivide, bsxfun(@plus, X0, 0.5i.*Fwhm_L), Fwhm_G);
    z = 1i.*sqrt(log(2)).*Fwhm_L./Fwhm_G; % When X0 is zero
    
    % Determine whether or not to use alternative approach
    B_A = Fwhm_G < Fwhm_L;
    B_B = ~B_A;
    
    % Separate the position variables into two cases
    Z_A = Z(:,B_A); % For approach A (= simple-ratio approach)
    Z_B = Z(:,B_B); % For approach B (= modified-ratio approach)
    ratio = zeros(size(Z)); % Preallocate
    
    % Evaluate the real part of the Faddeeva function
    nominator = real(fadf(Z_A)); % Voigtian lineshape profile
    divisor = real(fadf(z)); % Maximum of the Voigtian lineshape profile % = exp(imag(z_max).^2).*erfc(imag(z_max));
    
    % Normalize the Voigtian lineshape profile to [0, 1]
    ratio(:,B_A) = bsxfun(@rdivide, nominator, divisor);
    
    % Utilize sign inversion relation (w(z) = 2.*exp(-z.^2) - w(-z)) to
    % evaluate the case B with better numerical stability.
    nominator_1 = real(2.*exp(-Z_B.^2));
    nominator_2 = real(-fadf(-Z_B));
    
    % Essential derivation:
    % ratio = nominator ./ divisor; % Utilize sign inversion relation here
    % ratio = (nominator_1 + nominator_2) ./ divisor; % Divide by nominator_1
    % ratio = (1 + nominator_2./nominator_1) .* (nominator_1 ./ divisor);
    % ratio = (1 + nominator_2./nominator_1) .* subratio;
    % 
    % subratio = nominator_1 ./ divisor; % Then simplify this relation
    % 
    % nominator_1 = real(2.*exp(-Z.^2)) ...
    % = real(2.*exp(-real(Z).^2+imag(Z).^2-2i.*real(Z).*imag(Z))) ...
    % = 2.*exp(imag(Z).^2-real(Z).^2).*cos(-2.*real(Z).*imag(Z));
    % 
    % divisor = real(fadf(z)) ...
    % = exp(imag(z).^2).*erfc(imag(z));
    % 
    % imag(z) == imag(Z)
    % real(z) == 0
    % 
    % subratio = 2.*exp(imag(Z).^2-real(Z).^2).*cos(-2.*real(Z).*imag(Z)) ./ exp(imag(z).^2)./erfc(imag(z)) ...
    %  = 2.*exp(-real(Z).^2).*cos(-2.*real(Z).*imag(Z))./erfc(imag(z));
    % 
    % Robustness analysis:
    % exp(-real(Z).^2) is always [0, 1]
    % cos(-2.*real(Z).*imag(Z)) is always [-1, 1]
    % erfc(imag(z)) is always [0, 2]
    % 
    % This approach can fail if both nominator_2 and nominator_1 are zeros.
    
    % Use the rewritten robust form of the ratio calculus to avoid nan values
    subratio = bsxfun(@rdivide, 2.*exp(-real(Z_B).^2).*cos(-2.*real(Z_B).*imag(Z_B)), erfc(imag(z)));
    ratio(:,B_B) = bsxfun(@plus, 1, nominator_2./nominator_1) .* subratio;
    
    % Fix all the remaining all-nan cases with zeros
    ratio(repmat(all(isnan(ratio), 1), [size(ratio, 1) 1])) = 0;
    
    % Calculate Voigtian, Lorentzian and Gaussian lineshape profiles
    F = zeros(size(X));
    F(:,B_V) = bsxfun(@plus, bsxfun(@times, P(1,B_V), ratio), P(4,B_V));
    F(:,B_L) = fun_lineshape_lorentzian(P(1:4,B_L), X(:,B_L));
    F(:,B_G) = fun_lineshape_gaussian(P([1:2 5 4],B_G), X(:,B_G));
end
