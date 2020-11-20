% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function varargout = data_true_and_nan_collective_hole_reduction(varargin),
    % This collectively reduces holes in invalid regions (= true and NaN
    % input values). Inputs are assumed to be different maps of the same
    % spatial location.
    
    % For example, holes can appear due to imperfect noisy data fitting,
    % where true and NaN values have a meaning of failed fitting. These
    % tiny holes appear as noise. With this the tiny holes are removed,
    % allowing visually better removal of invalid data regions.
    
    varargout = varargin; % Default output
    if nargin == 0, return; end % Abort if no input
    
    % Obtain collective true (if logical) / NaN (if otherwise) map
    bw = varargin{1}; % Set first input as ref.
    if ~islogical(bw), bw = isnan(bw); end % If not logical, then treat NaN as true
    % Loop through further input
    for ii = 2:nargin,
        bw_ii = varargin{ii};
        if ~islogical(bw_ii), bw_ii = isnan(bw_ii); end % If not logical, then treat NaN as true
        bw = bw | bw_ii; % Obtain collective boolean map
    end
    
    % Distance to the nearest nonzero
    D = WITio.fun.lib.bwdistsc2d.bwdistsc2d(bw); % Get the Euclidean distance
    
    % Near-safely remove the one-pixel noise. This attempts to avoid
    % eroding away wider one-pixel thick connected regions with Area >= 4
    D_nearby = WITio.fun.indep.mynanmaxfilt2(D, 3); % Get maximum of 4-conn neighbours
%     D_nearby = ordfilt2(D, 9, ones(3)); % Same as above
    bw_erode = D_nearby <= 1;
    
    % Restore the areas with the maximum distance >= 2 or areas >= 6
    try, % Test if Image Processing Toolbox is available
        L = bwlabel(~bw, 4);
    catch, % Otherwise use third party function
        DBWnot = double(~bw);
        DBWnot(bw) = NaN;
        L = WITio.fun.lib.label.label(DBWnot, 4);
        clear DBWnot; % Free memory!
    end
    stats = WITio.fun.indep.myregionprops(L);
    PixelIdxList = {stats.PixelIdxList};
    Area = cellfun(@numel, PixelIdxList);
    MaxIntensity = cellfun(@(pil) max(D(pil)), PixelIdxList);
    for kk = 1:numel(stats),
        if MaxIntensity(kk) >= 2 || Area(kk) >= 6,
            bw_erode(PixelIdxList{kk}) = false;
        end
    end
    
    % Remove the one-pixel noise (that are surrounded by one-pixel noise)
    bw(bw_erode) = true;
    
    % Update the data
    for kk = 1:numel(varargout),
        if islogical(varargout{kk}), varargout{kk}(bw) = true;
        else, varargout{kk}(bw) = NaN; end
    end
end
