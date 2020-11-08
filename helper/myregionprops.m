% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Mimics stats = regionprops(L, 'PixelIdxList'); in order to remove
% dependency on Image Processing Toolbox. Other properties are derivations
% from this and can be calculated elsewhere. For instance, 'Area' is
% Area = cellfun(@numel, {stats.PixelIdxList}, 'UniformOutput', false);

% Used by data_true_and_nan_collective_hole_reduction.m
function stats = myregionprops(L),
    L_unique = unique(L); % Get region labels
    L_unique = L_unique(L_unique ~= 0); % Remove zero label region
    PixelIdxList = arrayfun(@(l) find(L == l), L_unique, 'UniformOutput', false);
    stats = struct('PixelIdxList', PixelIdxList);
end
