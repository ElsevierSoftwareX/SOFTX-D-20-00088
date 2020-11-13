% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This shows scalebar on any Image wid object.

% The scalebar plotter function can be customized by providing anonymous
% function paired with '-markScalebarFun', which must be as follows:
% gohandles = fun(Ax, image_size, image_size_in_standard_units,
% image_standard_units, varargin), where 'gohandles' is an array of handles
% to the created gobjects, 'Ax' represents the figure axes handle and so on
% and 'varargin' allows further customization of the provided function.

% Default scalebar plotter function 'wid.plot_scalebar_helper' accepts the
% following case-insensitive customizations:
% '-Color' = [1 1 1]: Overrides white color with the specified color.
% '-Anchor' = [0 1]: Overrides bottom-left corner anchor. Top-left corner
% is [0 0]. Top-right corner is [1 0]. Bottom-right corner is [1 1].
% '-PositionRatio' = [0.05 1-0.05]: Overrides 5% scalebar margins (from
% the anchor). Note: The top-left corner is located at [0 0].
% '-Position': Same as above but specified in dataset point coordinates.
% '-TextSpacingRatio' = 0.025: Overrides 2.5% text spacing margin.
% '-TextSpacing': Same as above but specified in dataset point coordinates.
% '-TextHeightRatio' = 0.05: Overrides 5% text height ratio. This is used
% to calculate the text FontSize-property.
% '-TextHeight': Same as above but specified in dataset point coordinates.
% '-ThicknessRatio' = 0.025: Overrides 2.5% scalebar height ratio.
% '-Thickness': Same as above but specified in dataset point coordinates.
% '-AutoLengthRatio' = 0.5: Overrides 50% scalebar length maximum ratio.
% This is used to calculate the scalebar length, floored to the most
% significant digit.
% '-AutoFloorDigitTo' = [1 2 5]: If not empty, then determine which digits
% are allowed to be used for the scalebar length.
% '-Length': If provided, then disables the automatic scalebar length
% calculation and uses this length value instead.
% '-LengthUnit' = image_standard_units: Determines the standard units of
% the previous length.
% '-LengthFormat' = '%g': Determines the sprintf formatting string in order
% to convert the previous length to text.
% '-PatchVarargin': Any accompanying inputs are provided to the patch
% object.
% '-TextVarargin': Any accompanying inputs are provided to the text object.
% '-NoText': If provided (standalone), then the scalebar is plotted without
% text label.
function h_scalebar = plot_scalebar(obj, FigAxNeither, varargin),
    % Empty output by default
    h_scalebar = [];
    
    % Test main object
    if ~strcmp(obj.SubType, 'Image'), return; end % Exit if not an Image
    
    % Check if markScalebarFun was specified
    [datas, varargin] = varargin_dashed_str_datas('markScalebarFun', varargin, -1);
    markScalebar = @wid.plot_scalebar_helper;
    if numel(datas) > 0, markScalebar = datas{1}; end
    
    % Parse FigAxNeither
    if nargin < 2, FigAxNeither = []; end
    Fig = [];
    Ax = [];
    try, % Test if FigAxNeither is Figure or Axes
        type = get(FigAxNeither, 'type'); % Compatible with older versions
        if strcmp(type, 'figure'),
            Fig = FigAxNeither;
            Ax = findobj(Fig, 'Type', 'Axes'); % Find all Axes
        elseif strcmp(type, 'axes'),
            Ax = FigAxNeither;
            Fig = get(Ax, 'Parent');
        else, varargin = [{FigAxNeither} varargin]; end % Add to varargin if neither
    catch, varargin = [{FigAxNeither} varargin]; end % Add to varargin if neither
    % Get current figure if needed
    if isempty(Fig),
        Fig = gcf;
        Ax = findobj(Fig, 'Type', 'Axes'); % Find all Axes
    end
    % Create default axes if needed
    if isempty(Ax),
        Ax = axes('Parent', Fig);
        set(0, 'CurrentFigure', Fig);
        obj.plot;
    end
    % Update only the first axes
    if ~isempty(Ax), Ax = Ax(1); end
    
    % Ensure that the subsequent plots are included into same axes
    hold on;
    
    obj_Info = obj.Info; % Load Info only once
    
    image_size = [obj_Info.XSize obj_Info.YSize];
    image_size_in_standard_units = [obj_Info.XLength obj_Info.YLength];
    image_standard_units = regexprep(obj_Info.XUnit, '^([^\(]*\()(.*)(\)[^\)]*)$', '$2'); % Standard Unit is extracted from between the outermost ()-brackets
    
    h_scalebar = markScalebar(Ax, image_size, image_size_in_standard_units, image_standard_units, varargin{:});
end
