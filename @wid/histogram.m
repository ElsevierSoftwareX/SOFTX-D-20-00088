% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [new_obj, Bin_Counts, Bin_Centers] = histogram(obj, N_bins, lower_quantile, upper_quantile, range_scaling)
    % Updated 4.3.2019 by Joonas T. Holmi
    % Accepts inputs like in WITec Project 2.10
    if nargin < 5, range_scaling = 2; end % 200%
    if nargin < 4, upper_quantile = 0.95; end % 95%
    if nargin < 3, lower_quantile = 0.05; end % 5%
    if nargin < 2, N_bins = 'Freedman-Diaconis'; end
    
    if ~strcmp(obj.Type, 'TDImage'),
        error('Invalid Type! Histogram generation is only for TDImage. ABORTING...');
    end
    
    new_obj = wid.Empty;
    
    Data = obj.Data(:);
    Method_bins = '';
    if numel(Data) > 1,
%         [~, ~, ~, ~, ~, cmin, cmax] = clever_statistics_and_outliers(Data, [], 4);
%         Data_lower_quantile = interp1([0 1], [cmin cmax], lower_quantile, 'linear'); % Approximate lower quantile
%         Data_upper_quantile = interp1([0 1], [cmin cmax], upper_quantile, 'linear'); % Approximate upper quantile
        Data_lower_quantile = vector_quantile(Data, lower_quantile);
        Data_upper_quantile = vector_quantile(Data, upper_quantile);
        Data_extra = (Data_upper_quantile-Data_lower_quantile)/2*(range_scaling-1);
        if ischar(N_bins), % If a method is specified
            Method_bins = [N_bins ': '];
            N_samples = sum(~isnan(Data));
            switch(N_bins),
                case 'Freedman-Diaconis',
                    IQ = vector_quantile(Data, [0.25 0.75]);
                    IQR = IQ(2) - IQ(1);
                    h = 2 .* IQR .* N_samples.^(-1./3);
                    N_bins = ceil((Data_upper_quantile - Data_lower_quantile + 2.*Data_extra)./h);
                case 'Rice',
                    N_bins = ceil(2 .* N_samples.^(1./3));
                case 'Sqrt',
                    N_bins = ceil(sqrt(N_samples));
                case 'Sturges',
                    N_bins = ceil(log2(N_samples)) + 1;
            end
        end
        Bin_Edges = linspace(Data_lower_quantile-Data_extra, Data_upper_quantile+Data_extra, N_bins+1);
        Bin_Counts = histc(obj.Data(:), Bin_Edges);
        Bin_Centers = reshape((Bin_Edges(1:end-1)+Bin_Edges(2:end))./2, [], 1); % Get Bin Centers because wid.plot uses built-in bar-function
        Bin_Counts = reshape(Bin_Counts(1:end-1), [], 1); % Discard last one
    else,
        Bin_Counts = ones(size(Data));
        Bin_Centers = Data;
    end
    
    % Create a new TDGraph object for histogram
    
    % Create new object if permitted
    if obj.Project.popAutoCreateObj, % Get the latest value (may be temporary or permanent or default)
        new_obj = wid.new_Graph(obj.Tag.Root); % This does not add newly created object to Project yet!
        new_obj.Name = sprintf('Histogram[%s%d bins]<%s', Method_bins, N_bins, obj.Name); % Generate new name
        new_obj.Data = reshape(Bin_Counts, 1, 1, []);
        new_obj.SubType = 'Histogram';

        new_TLUT = wid.new_Transformation_LUT(obj.Tag.Root, numel(Bin_Centers)); % This does not add newly created object to Project yet!
        new_TLUT_Data = new_TLUT.Data; % Get formatted struct once to speed-up
        new_TLUT_Data.TDLUTTransformation.LUT = Bin_Centers;
        new_TLUT_Data.TDLUTTransformation.LUTSize = numel(Bin_Centers); % Ignored by wit_io, but used in WITec software
        new_TLUT_Data.TDLUTTransformation.LUTIsIncreasing = true; % Ignored by wit_io, but used in WITec software
        new_TLUT.Data = new_TLUT_Data; % Save all changes once

        new_ILUT = wid.new_Interpretation_Z(obj.Tag.Root); % This does not add newly created object to Project yet!
        new_ILUT.Data.TDZInterpretation.UnitName = obj.Info.DataUnit;

        new_obj.Tag.Data.regexp('^XTransformationID<TDGraph<', true).Data = new_TLUT.Id; % Must be int32!
        new_obj.Tag.Data.regexp('^XInterpretationID<TDGraph<', true).Data = new_ILUT.Id; % Must be int32!

        % Add new object to current Project, modifying its Project-property.
        if ~isempty(obj.Project),
            obj.Project.Data = [obj.Project.Data; new_obj; new_TLUT; new_ILUT];
        end
    end
end
