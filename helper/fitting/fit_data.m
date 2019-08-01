% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [P, R2, SSres, Y_fit, R2_total, SSres_total] = fit_data(x, Y, x_Data, y_Data, order, dim, fitMany),
    % N'th order fitting of Data to the data in Y, for which the dim'th
    % dimension is interpreted as the data dimension. Other dimensions are
    % interpreted as datasets. By default, order == 1 and dim == 1. Outputs
    % have the same dimensionality as Y (except in the dim'th dimension).
    % NOTE: Treats NaNs as missing data in x and Y.
    % *Concerning fitMany:
    % true: Many Datas are fitted (one per dataset in Y). (DEFAULT)
    % false: One Data is fitted (using all datasets in Y).
    if nargin < 5, order = 1; end
    if nargin < 6, dim = 1; end
    if nargin < 7, fitMany = true; end
    
    % Remove nans in Data
    isvalid = ~isnan(x_Data);
    x_Data = x_Data(isvalid);
    y_Data = y_Data(isvalid);
    
    % Interpolate
    y_Data_at_x = interp1(x_Data, y_Data, x, 'linear', NaN);
    
    % Fit Data using linear polynomial relation
    [P, R2, SSres, Y_fit, R2_total, SSres_total] = fit_polynomial(y_Data_at_x, Y, order, dim, fitMany);
end
