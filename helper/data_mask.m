% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [Data_masked, Data_NaN_masked] = data_mask(Data, Mask),
    [D, M] = dim_size_consistent_repmat(Data, Mask); % Repmat consistently to permit masking
    Size_Diff = size(M) - [size(Mask) ones(1, ndims(M)-ndims(Mask))] + 1; % Find changes in mask dimensions
    ind_1st_singleton = find(Size_Diff == 1, 1, 'first'); % Find 1st singleton change
    Size_Diff(ind_1st_singleton) = sum(Mask(:) == 1); % Account for the number of masked elements
    Data_masked = reshape(D(M == 1), Size_Diff); % Get masked data and reshape accordingly
    if nargout > 1, % Get NaN masked data
        Data_NaN_masked = double(D);
        Data_NaN_masked(M ~= 1) = NaN;
    end
end
