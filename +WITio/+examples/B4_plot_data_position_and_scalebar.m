% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO EXAMPLE CASE B 4: DATA POSITION AND SCALEBAR PLOTTING
% Simple examples of (B4) data position and scalebar plotting in order to
% see their positions with respect to each other.

WITio.tbx.edit(); % Open this code in Editor
close all; % Close figures

% Example file
pathstr = fullfile(WITio.tbx.path.package, '+examples'); % Get folder of this script
file = fullfile(pathstr, 'A_v5.wip'); % Construct full path of the example file
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
WITio.tbx.license;

h = WITio.tbx.msgbox({'{\bf\fontsize{12}\color{magenta}EXAMPLE CASE B4:}' ...
'{\bf\fontsize{12}DATA POSITION AND SCALEBAR ' ...
'PLOTTING}' ...
'' ...
'\bullet Using ''A\_v5.wip'' WITec Project -file, which has Raman data from exfoliated ' ...
'graphene with 1-, 2- and 3-layer areas on 285 nm SiO2/Si-substrate.'}, '-TextWrapping', false);
WITio.tbx.uiwait(h); % Wait for WITio.tbx.msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
[O_wid, O_wip, O_wid_HtmlNames] = WITio.read(file, '-all'); % Load all the file plottable content

% Get handles to some specific data
O_Bitmap = O_wid(2); % Get object of "Exfoliated graphene (Gr) on SiO2/Si-substrate<Video Image (Data)" at index 2
O_ImageScan = O_wid(3); % Get object of "Reduced<Image Scan 1 (Data)" at index 3
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
[h,b] = WITio.tbx.msgbox({'{\bf\fontsize{12}{\color{magenta}(B4)} Show position of objects on each ' ...
'other and display scalebar:}' ...
'' ...
'{\bf\fontname{Courier}obj.plot(''-position'', obj2, ..., ' ...
'objN, ''-scalebar'');}' ...
'' ...
'\bullet Any Image wid object plotting can be accompanied with {\bf\fontname{Courier}''-position''} ' ...
'and/or {\bf\fontname{Courier}''-scalebar''} options.' ...
'' ...
'\bullet Read the code for more details.' ...
'' ...
'\ldots Close this dialog to plot few examples and END.'}, '-TextWrapping', false);
WITio.tbx.uiwait(h); % Wait for WITio.tbx.msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
figure(1); h1 = O_Bitmap.plot('-position', O_wid([3 16 17]), '-scalebar'); % Show positions AND show default bottom-left auto-length scalebar with text
figure(2); h2 = O_ImageScan.plot('-position', O_wid([2 16 17]), ... % Here ... allows multiline function calls
    '-scalebar', '--NoText', '--Anchor', [1 1], '--PositionRatio', [0.95 0.95]); % Show positions AND show bottom-right auto-length scalebar without text

% Description of the '-position' option above. All the subsequent inputs
% (until the next dashed string beginning with '-') are parsed for the
% Image, Line and Point wid objects. They are then marked on the main Image
% wid object plot view. It accepts the following CASE-INSENSITIVE
% customizations: --markImageFun, --markLineFun and --markPointFun.

% Description of the '-scalebar' option above. Its default scalebar plotter
% function accepts the following CASE-INSENSITIVE customizations:
% '--Color' = [1 1 1]: Overrides white color with the specified color.
% '--Anchor' = [0 1]: Overrides bottom-left corner anchor. Top-left corner
% is [0 0]. Top-right corner is [1 0]. Bottom-right corner is [1 1].
% '--PositionRatio' = [0.05 1-0.05]: Overrides 5% scalebar margins (from
% the anchor). Note: The top-left corner is located at [0 0].
% '--Position': Same as above but specified in dataset point coordinates.
% '--TextSpacingRatio' = 0.025: Overrides 2.5% text spacing margin.
% '--TextSpacing': Same as above but specified in dataset point coordinates.
% '--TextHeightRatio' = 0.05: Overrides 5% text height ratio. This is used
% to calculate the text FontSize-property.
% '--TextHeight': Same as above but specified in dataset point coordinates.
% '--ThicknessRatio' = 0.025: Overrides 2.5% scalebar height ratio.
% '--Thickness': Same as above but specified in dataset point coordinates.
% '--AutoLengthRatio' = 0.5: Overrides 50% scalebar length maximum ratio.
% This is used to calculate the scalebar length, floored to the most
% significant digit.
% '--AutoFloorDigitTo' = [1 2 5]: If not empty, then determine which digits
% are allowed to be used for the scalebar length.
% '--Length': If provided, then disables the automatic scalebar length
% calculation and uses this length value instead.
% '--LengthUnit' = image_standard_units: Determines the standard units of
% the previous length.
% '--LengthFormat' = '%g': Determines the sprintf formatting string in order
% to convert the previous length to text.
% '--PatchVarargin': Any accompanying inputs are provided to the patch
% object.
% '--TextVarargin': Any accompanying inputs are provided to the text object.
% '--NoText': If provided (standalone), then the scalebar is plotted without
% text label.

% Alternatively call plot_position and plot_scalebar separately. Notice
% how plot_scalebar takes in the configuration inputs with a single dash
% '-' instead of two dashes '--' like above. This is because we now call
% it directly, avoiding the plot-function input parser.
h3a = O_Bitmap.plot_position(figure(3), O_wid([3 16 17]));
set(findall(h3a, 'Marker', 'o'), 'Marker', 'x'); % Set point markers from o to x
figure(4); h4a = O_ImageScan.plot_position(O_wid([2 16 17])); % Moved figure(4) outside the function call
set(findall(h4a, 'Type', 'line', 'Marker', 'none'), 'Color', 'white', 'LineWidth', 2); % Set line color to white and its width to 3

h3b = O_Bitmap.plot_scalebar(figure(3), '-NoText', '-Color', [0 0 0]); % Plot customized black scalebar without text
figure(4); h4b = O_ImageScan.plot_scalebar('-Length', 3.5, '-TextHeightRatio', 0.075); % Plot customized scalebar with length of 3.5 um and 50% larger text

% Please note that each of these graphical object arrays h1, h2, h3a, h3b,
% h4a and h4b may be customized by their get/set-functions like shown
% above. These special plot functions generate primitive patch-, line- and
% text-objects [1-3]:
% [1] https://www.mathworks.com/help/matlab/ref/matlab.graphics.primitive.patch-properties.html
% [2] https://www.mathworks.com/help/matlab/ref/matlab.graphics.primitive.line-properties.html
% [3] https://www.mathworks.com/help/matlab/ref/matlab.graphics.primitive.text-properties.html
%-------------------------------------------------------------------------%


