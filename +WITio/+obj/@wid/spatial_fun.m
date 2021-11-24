% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Evaluates the given function spatially for the given object (be it TDBitmap,
% TDGraph or TDImage). If fun is an anonymous function, then it must accept
% a 2-D matrix, where the 2nd dimension contains the spatial data of
% possibly NaN values. The varargin is directly passed on as inputs to fun.
% If fun is a char array, then it can be any of the following special case:
% 'min', 'max', 'mean', 'median', 'std', 'pstd', 'var', 'pvar',
% 'cmin', 'cmax', 'cmean', 'cmedian', 'cstd', 'cpstd', 'cvar', 'cpvar'.
function [obj, Fun] = spatial_fun(obj, fun, str_fun, varargin), % Copy the object if permitted
    if nargin < 3 || isempty(str_fun), str_fun = 'Spatial Fun'; end
    if ischar(fun),
        fun_char = fun;
        fun = @fun_special;
    end

    if WITio.tbx.pref.get('wip_AutoCopyObj', true), obj = obj.copy(); end
    
    % Change matrix dimensions so that the 3rd spectral dimension becomes first and the other spatial dimensions become the rest.
    Data = permute(obj.Data, [3 1 2 4]); % [x y s z] -> [s x y z]
    Data_2D = Data(:,:); % [s x y z] -> [s x*y*z]
    
    % Evaluate the given function spatially
    Fun = reshape(fun(Data_2D, varargin{:}), 1, 1, [], 1); % Restore the spectrum
    
    % Modify the object (or its copy) if permitted
    if WITio.tbx.pref.get('wip_AutoModifyObj', true),
        obj.Data = Fun;
        obj.Name = sprintf('%s<%s', str_fun, obj.Name);
        obj.SubType = 'Point'; % Only relevant if Type == TDGraph
        
        % Load the object info once
        Info = obj.Info;
        
        T = Info.XTransformation; % Get the space transformation object
        if ~isempty(T) && strcmp(T.Type, 'TDSpaceTransformation'), % Continue only if there is transformation
            T_Data = T.Data; % Get its data
            T_Data.TDSpaceTransformation.ViewPort3D.ModelOrigin(1) = T_Data.TDSpaceTransformation.ViewPort3D.ModelOrigin(1) - (Info.XSize-1)/2;
            T_Data.TDSpaceTransformation.ViewPort3D.ModelOrigin(2) = T_Data.TDSpaceTransformation.ViewPort3D.ModelOrigin(2) - (Info.YSize-1)/2;
            T_Data.TDSpaceTransformation.ViewPort3D.ModelOrigin(3) = T_Data.TDSpaceTransformation.ViewPort3D.ModelOrigin(3) - (Info.ZSize-1)/2;
            T.Data = T_Data; % Write all changes at once
        end
    end

    function x = fun_special(X, varargin),
        if numel(varargin) == 0,
            if fun_char(1) == 'c', varargin = {4}; % Default input to clever functions
            else, varargin = {'omitnan'}; end % Default input to non-clever functions
        end
        switch(fun_char),
            case 'min', % Calculates minimum
                x = min(X, [], 2, varargin{:});
            case 'max', % Calculates maximum
                x = max(X, [], 2, varargin{:});
            case 'mean', % Calculates mean
                x = mean(X, 2, varargin{:});
            case 'median', % Calculates median
                x = median(X, 2, varargin{:});
            case 'std', % Calculates sample-based standard deviation
                x = std(X, 0, 2, varargin{:});
            case 'pstd', % Calculates population-based standard deviation
                x = std(X, 1, 2, varargin{:});
            case 'var', % Calculates sample-based variance
                x = var(X, 0, 2, varargin{:});
            case 'pvar', % Calculates population-based variance
                x = var(X, 1, 2, varargin{:});
            case 'cmin', % Calculates clever minimum
                [~, ~, ~, ~, ~, x, ~, ~] = WITio.fun.clever_statistics_and_outliers(X, 2, varargin{:});
            case 'cmax', % Calculates clever maximum
                [~, ~, ~, ~, ~, ~, x, ~] = WITio.fun.clever_statistics_and_outliers(X, 2, varargin{:});
            case 'cmean', % Calculates clever mean
                [~, x, ~, ~, ~, ~, ~, ~] = WITio.fun.clever_statistics_and_outliers(X, 2, varargin{:});
            case 'cmedian', % Calculates clever median
                [~, ~, ~, ~, x, ~, ~, ~] = WITio.fun.clever_statistics_and_outliers(X, 2, varargin{:});
            case 'cstd', % Calculates clever sample-based standard deviation
                [~, ~, ~, x, ~, ~, ~, ~] = WITio.fun.clever_statistics_and_outliers(X, 2, varargin{:});
            case 'cpstd', % Calculates clever population-based standard deviation
                [isOutlier, ~, ~, x] = WITio.fun.clever_statistics_and_outliers(X, 2, varargin{:});
                N_samples = sum(~isOutlier,2);
                N_samples(N_samples == 0) = NaN; % Store NaN when 0 samples
                x = sqrt(1-1./N_samples).*x; % Convert from sample-based to population-based
            case 'cvar', % Calculates clever sample-based variance
                [~, ~, x, ~, ~, ~, ~, ~] = WITio.fun.clever_statistics_and_outliers(X, 2, varargin{:});
            case 'cpvar', % Calculates clever population-based variance
                [isOutlier, ~, ~, x, ~, ~, ~, ~] = WITio.fun.clever_statistics_and_outliers(X, 2, varargin{:});
                N_samples = sum(~isOutlier,2);
                N_samples(N_samples == 0) = NaN; % Store NaN when 0 samples
                x = (1-1./N_samples).*x; % Convert from sample-based to population-based
            otherwise, error('Unimplemented special function, %s!', fun_char);
        end
    end
end
