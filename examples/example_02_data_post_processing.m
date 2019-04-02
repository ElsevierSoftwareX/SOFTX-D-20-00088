% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO EXAMPLE 2: DATA POST PROCESSING
% Simple examples of data post processing like (1) filtering, (2) fitting,
% (3) masking, (4) spatial averaging and (5) plotting.

clear all; % Clear workspace
close all; % Close figures

% Example file
pathstr = fileparts([mfilename('fullpath') '.m']); % Get folder of this script
file = fullfile(pathstr, 'example_v5.wip'); % Construct full path of the example file
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'EXAMPLE 2: DATA POST PROCESSING' ...
    '' ...
    '* Using ''example_v5.wip'' WITec Project -file, which has Raman data from exfoliated graphene with 1-, 2- and 3-layer areas on 285 nm SiO2/Si-substrate.' ...
    '' ...
    '* Please note that MOST of this ''wit_io'' code is OPEN-SOURCED under simple and permissive BSD 3-Clause License and is FREE-TO-USE like described in LICENSE.txt!'});
if ishandle(h), figure(h); uiwait(h); end % Wait for helpdlg to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
[C_wid, C_wip, HtmlNames] = wip.read(file, '-all', '-SpectralUnit', '(rel. 1/cm)'); % Load all the file plottable content

% Get handles to some specific data
C_Text = C_wid(1); % Get object of "Global (Calibration Information)" at index 1
C_Bitmap = C_wid(2); % Get object of "Exfoliated graphene (Gr) on SiO2/Si-substrate<Video Image (Data)" at index 2
C_ImageScan = C_wid(3); % Get object of "Reduced<Image Scan 1 (Data)" at index 3
C_Mask = C_wid(6); % Get object of "1-layer Gr<Mask 2" at index 6
C_Point = C_wid(17); % Get object of "1-layer Gr<Point Scan 1 (Data)" at index 17
% To see these names, double-click HtmlNames-variable under your Workspace!

% Alternative way to get these handles is by use of manager without GUI and
% with a little prior knowledge of the file contents
C_ImageScans = C_wip.manager('-nomanager', '-Type', 'TDGraph', '-SubType', 'Image');
C_ImageScan = C_ImageScans(1); % Get the first Image<TDGraph in the file
C_Images = C_wip.manager('-nomanager', '-Type', 'TDImage');
C_Mask = C_Images(2); % Get the second TDImage in the file
C_Points = C_wip.manager('-nomanager', '-Type', 'TDGraph', '-SubType', 'Point');
C_Point = C_Points(end); % Get the last TDGraph Point in the file
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'!!! (1) Applying filters on the Raman D-, G- and 2D-peaks:' ...
    '' ...
    '* Please read the code that applies Sum and Center of Mass -filters over the specified ranges.' ...
    '' ...
    '* Click and see the newly processed data in the opened Project Manager before closing this help dialog. Please note that you may also use arrow keys to move in images.'});
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Determine project parameters (but not needed because AutoCreateObj,
% AutoCopyObj and AutoModifyObj are true by default).
% oldState = C_wip.storeState(); % Store the original Project state
% C_wip.AutoCreateObj = true; % If wid-class functions should create new object
% C_wip.AutoCopyObj = true; % If wid-class functions should copy object
% C_wip.AutoModifyObj = true; % If wid-class functions should modify object

% Specify the spectral ranges for the Raman D, G and 2D-peaks of graphene
Range_D = [1300 1400];
Range_G = [1540 1640];
Range_2D = [2600 2800];

% Manually use wid-class filter_bg-function to calculate the D-peak sum
% [~, ~] = C_ImageScan.filter_bg(D, 4, 4); % Like in the software, use 4-pixels lower and upper background averaging. Set 0 and 0 to disable it.
[C_ImageScan_D, Data_D] = C_ImageScan.filter_bg(Range_D); % Same as above, because the 4-pixels lower and upper background averaging is enabled by default.
Sum_D = sum(Data_D, 3);

% Or evaluate sum, center of mass with one function call.
[C_Sum_G, Sum_G] = C_ImageScan.filter_sum(Range_G); % Sum filtering after removal of linear background (using filter_bg)
[C_Sum_2D, Sum_2D] = C_ImageScan.filter_sum(Range_2D); % Sum filtering after removal of linear background (using filter_bg)
[C_CoM_G, CoM_G] = C_ImageScan.filter_center_of_mass(Range_G); % Center of mass filtering after removal of linear background (using filter_bg)
[C_CoM_2D, CoM_2D] = C_ImageScan.filter_center_of_mass(Range_2D); % Center of mass filtering after removal of linear background (using filter_bg)
% Other implemented filter types can be found in wit_io\@wid-folder
% starting with 'filter_'. You can also write your own custom filter by
% utilizing a generic filter_fun (under @wid) like filter_sum and others.

C_wip.manager;
if ishandle(h), figure(h); uiwait(h); end
close all; % Close Project Manager
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'!!! (2) Applying lineshape-fitting filters on the Raman 0-, D-, G- and 2D-peaks:' ...
    '' ...
    '* Please read the code that applies Gaussian and Voigtian -filters over the specified ranges.' ...
    '' ...
    '* See the fitting result in the opened figure before closing this help dialog.'});
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
Range_0 = [-25 25]; % The spectral range of Rayleigh-peak (laser line) at (supposedly) zero
% First fit Gaussian to Rayleigh-peak in order to find instrument-induced Fwhm_G (needed for Voigtian-fitting)
[C_Point_0, ~, ~, Point_Fwhm_G] = C_Point.filter_gaussian(Range_0); % Gauss filtering after removal of linear background (using filter_bg)
% Then fit Voigtian to D-, G- and 2D-peaks, but Lock 'Fwhm_G' parameter to previously experimental value in order to retain physical meaning!
C_Point_D = C_Point.filter_voigtian({'-Fwhm_G', Point_Fwhm_G}, Range_D); % Voigt filtering after removal of linear background (using filter_bg)
C_Point_G = C_Point.filter_voigtian({'-Fwhm_G', Point_Fwhm_G}, Range_G); % Voigt filtering after removal of linear background (using filter_bg)
C_Point_2D = C_Point.filter_voigtian({'-Fwhm_G', Point_Fwhm_G}, Range_2D); % Voigt filtering after removal of linear background (using filter_bg)
% Compare the experimental data with the fitting result using '-compare'-feature of obj.plot
figure; C_Point.plot('-compare', C_Point_0(end), C_Point_D(end), C_Point_G(end), C_Point_2D(end)); % Show fitting results % Image<TDGraph with sidebar
if ishandle(h), figure(h); uiwait(h); end
close all; % Close the plot
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'!!! (3) Masking of the ImageScan data:' ...
    '' ...
    '* This example uses "1-layer Gr<Mask 2"-mask on "Reduced<Image Scan 1 (Data)"-data.' ...
    '' ...
    '(A) Plot can temporarily mask data with ''-mask''-option.' ...
    '(B) Object can be masked using image_mask-function.' ...
    '(C) Masks can be created/edited using image_mask_editor. ' ...
    '' ...
    '* Please read the code that demonstrates the masking. Only case (C) above is executed. Others have been commented in the code.' ...
    '' ...
    '* Close the Mask Editor -window to continue...'});
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% CASE (A):
% figure; C_ImageScan.plot('-mask', C_Mask); % Show NaN-masked Image<TDGraph with sidebar

% CASE (B):
C_masked = C_ImageScan.image_mask(C_Mask); % Mask data (second input is mask)
% figure; C_masked.plot(); % GraphLine with sidebar

% CASE (C):
% C_mask = C_ImageScan.image_mask_editor(); % Create a new mask using C_ImageScan as background!
obj.Project.AutoCreateObj = false; % Avoid creating a new mask object
[~, C_Mask.Data] = C_ImageScan.image_mask_editor(C_Mask.Data); % Edit mask C_mask using C_ImageScan as background!
obj.Project.AutoCreateObj = true;
close all; % Close the plot
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'!!! (4) Getting spatial average of the previously masked data.' ...
    '' ...
    '* Close this to continue.'});
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
C_avg = C_masked.spatial_average();
figure; C_avg.plot; % Point<TDGraph with sidebar
if ishandle(h), figure(h); uiwait(h); end
close all; % Close the plot
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'!!! (5) Plotting objects:' ...
    '' ...
    '* All WITec Project/Data (*.wip/*.wid) data types can be plotted using plot-function.' ...
    '' ...
    '* Four most common objects (TDBitmap, TDGraph, TDImage and TDText) have their own plotting styles. Uncommon objects (like transformations and interpretations) are plotted like TDText after converting their possibly formatted DataTree to text.' ...
    '' ...
    '* By default, a sidebar is shown for each plot, but it can be disabled using ''-nosidebar''-option.' ...
    '' ...
    '* Close this to END by automatically closing the opened figures.'});
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
figure; C_Text.plot(); % Text with sidebar
figure; C_Bitmap.plot(); % Bitmap with sidebar
figure; C_Bitmap.Info.XTransformation.plot(); % Bitmap's TDSpaceTransformation with sidebar
figure; C_Mask.plot('-nosidebar'); % Image WITHOUT SIDEBAR
if ishandle(h), figure(h); uiwait(h); end
close all; % Close the plot
%-------------------------------------------------------------------------%


