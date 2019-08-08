% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [P, R2, SSres, Y_fit, R2_total, SSres_total] = fit_lineshape_voigtian(x, Y, P0, dim, varargin),
    % Parse extra arguments
    
    % Check if Fwhm_G was specified (in order to lock that parameter)
    datas = varargin_dashed_str_datas('Fwhm_G', varargin, -1);
    if numel(datas) > 0,
        Fwhm_G = datas{1};
        Fwhm_G = Fwhm_G(:).'; % Force a row vector
        P0(5,:) = Fwhm_G; % Works if Fwhm_G is a scalar or a same sized matrix
        P0(3,:) = max(P0(3,:)-Fwhm_G, 0); % Remove the Fwhm_G component from a width guess (but mimimum at zero)
        varargin = varargin_dashed_str_removed('Fwhm_G', varargin); % Remove this option from varargin!
        % Add -Locks-parameter, which tells fit_lineshape_arbitrary to keep
        % the 5th parameter (= Fwhm_G) as a constant!
        varargin{end+1} = '-Locks';
        varargin{end+1} = [0 0 0 0 1];
    end
    
    % Voigtian lineshape fitting
    % P(1,:) = Intensity, P(2,:) = Pos, P(3,:) = Fwhm_L, P(4,:) = Offset, P(5,:) = Fwhm_G
    if size(P0, 1) == 4, P0 = [P0; zeros(1, size(P0, 2))]; end % If initial guess does not have Fwhm_G, then add it by guessing it all zeros.
    [P, R2, SSres, Y_fit, R2_total, SSres_total] = fit_lineshape_arbitrary(@fun_lineshape_voigtian, x, Y, P0, dim, varargin{:});
end
