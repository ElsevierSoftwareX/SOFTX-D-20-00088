% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Cleanup bad fitting results
function B_fit_valid = mask_bad_results_and_noise(Data, Graph, Range_fit, I_fit, Pos_fit),
    % Remove dark count offset if present
    Data = Data - min(Data(:));
    
    % Crop Data within Range_fit without background removal (to preserve the shot noise)
    Data_fit = wit.io.wid.crop_Graph_with_bg_helper(Data, Graph, Range_fit, 0, 0);

    % Find average fluctuations (or shot noise)
    [~, ~, cvar, ~, ~, cmin, cmax] = wit.io.fun.clever_statistics_and_outliers(sqrt(double(Data_fit)), -3, 4); % Sqrt in order to estimate shot noise by variances!
    cstd = sqrt(mean(cvar)).^2; % Take mean of variances and evaluate std
    cmin = min(cmin.^2);
    cmax = max(cmax.^2);

    % Discard bad fitting results
    B_fit_valid = I_fit > 2.*cstd & ... % Require that the fitted peak intensity is above shot noise!
        Pos_fit >= Range_fit(1) & Pos_fit <= Range_fit(2) & ... % Require that the fitted peak position is within the data range!
        I_fit > 0 & I_fit <= 2.*(cmax-cmin); % Require that the fitted peak intensity is within the data range!
end
