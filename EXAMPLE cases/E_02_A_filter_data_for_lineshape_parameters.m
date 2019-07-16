% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO EXAMPLE CASE 2 A: DATA FILTERING FOR LINESHAPE PARAMETERS
% Simple examples of data post processing like (E2A i.) filtering and
% (E2A ii.) fitting.

clear all; % Clear workspace
close all; % Close figures

% Example file
pathstr = fileparts([mfilename('fullpath') '.m']); % Get folder of this script
file = fullfile(pathstr, 'E_v5.wip'); % Construct full path of the example file
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'EXAMPLE CASE 2 A: DATA FILTERING FOR LINESHAPE PARAMETERS' ...
    '' ...
    '* Using ''E_v5.wip'' WITec Project -file, which has Raman data from exfoliated graphene with 1-, 2- and 3-layer areas on 285 nm SiO2/Si-substrate.' ...
    '' ...
    '* Please note that MOST of this ''wit_io'' code is OPEN-SOURCED under simple and permissive BSD 3-Clause License and is FREE-TO-USE like described in LICENSE.txt!'});
if ishandle(h), figure(h); uiwait(h); end % Wait for helpdlg to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
[O_wid, O_wip, O_wid_HtmlNames] = wip.read(file, '-all', '-SpectralUnit', '(rel. 1/cm)'); % Load all the file plottable content and force SpectralUnit to Raman shift

% Get handles to some specific data
C_Text = O_wid(1); % Get object of "Global (Calibration Information)" at index 1
C_Bitmap = O_wid(2); % Get object of "Exfoliated graphene (Gr) on SiO2/Si-substrate<Video Image (Data)" at index 2
C_ImageScan = O_wid(3); % Get object of "Reduced<Image Scan 1 (Data)" at index 3
C_Mask = O_wid(6); % Get object of "1-layer Gr<Mask 2" at index 6
C_Point = O_wid(17); % Get object of "1-layer Gr<Point Scan 1 (Data)" at index 17
% To see these names, double-click O_wid_HtmlNames-variable under your Workspace!

% Alternative way to get these handles is by use of manager without GUI and
% with a little prior knowledge of the file contents
C_ImageScans = O_wip.manager('-nomanager', '-Type', 'TDGraph', '-SubType', 'Image');
C_ImageScan = C_ImageScans(1); % Get the first Image<TDGraph in the file
C_Images = O_wip.manager('-nomanager', '-Type', 'TDImage');
C_Mask = C_Images(2); % Get the second TDImage in the file
C_Points = O_wip.manager('-nomanager', '-Type', 'TDGraph', '-SubType', 'Point');
C_Point = C_Points(end); % Get the last TDGraph Point in the file
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'!!! (E2A i.) Applying filters on the Raman D-, G- and 2D-peaks:' ...
    '' ...
    '* Please read the code that applies Sum and Center of Mass -filters over the specified ranges.' ...
    '' ...
    '* Click and see the newly processed data in the end of the opened Project Manager before closing this help dialog. Please note that you may also use arrow keys to move in images.'});
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Determine project parameters (but not needed because AutoCreateObj,
% AutoCopyObj and AutoModifyObj are true by default).
% oldState = O_wip.storeState(); % Store the original Project state
% O_wip.AutoCreateObj = true; % If wid-class functions should create new object
% O_wip.AutoCopyObj = true; % If wid-class functions should copy object
% O_wip.AutoModifyObj = true; % If wid-class functions should modify object

% Specify the spectral ranges for the Raman D, G and 2D-peaks of graphene
Range_D = [1300 1400]; % Filtering range for the D-peak
Range_G = [1540 1640]; % Filtering range for the G-peak
Range_2D = [2600 2800]; % Filtering range for the 2D-peak

% Manually use wid-class filter_bg-function to calculate the D-peak sum
% [~, ~] = C_ImageScan.filter_bg(D, 4, 4); % Like in the software, use 4-pixels lower and upper background averaging. Set 0 and 0 to disable it.
[C_ImageScan_D, Data_D] = C_ImageScan.filter_bg(Range_D); % Same as above, because the 4-pixels lower and upper background averaging is enabled by default.
Sum_D = sum(Data_D, 3);

% Or evaluate sum, center of mass with one function call.
[C_Sum_G, Sum_G] = C_ImageScan.filter_sum(Range_G); % Sum filtering of G-peak after removal of linear background (using filter_bg)
[C_Sum_2D, Sum_2D] = C_ImageScan.filter_sum(Range_2D); % Sum filtering of 2D-peak after removal of linear background (using filter_bg)
[C_CoM_G, CoM_G] = C_ImageScan.filter_center_of_mass(Range_G); % Center of mass filtering of G-peak after removal of linear background (using filter_bg)
[C_CoM_2D, CoM_2D] = C_ImageScan.filter_center_of_mass(Range_2D); % Center of mass filtering of 2D-peak after removal of linear background (using filter_bg)
% Other implemented filter types can be found in wit_io\@wid-folder
% starting with 'filter_'. You can also write your own custom filter by
% utilizing a generic filter_fun (under @wid) like filter_sum and others.

O_wip.manager;
if ishandle(h), figure(h); uiwait(h); end
close all; % Close Project Manager
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'!!! (E2A ii.) Applying lineshape-fitting filters on the Raman 0-, D-, G- and 2D-peaks:' ...
    '' ...
    '* Please read the code that applies Gaussian and Voigtian -filters over the specified ranges.' ...
    '' ...
    '* See the fitting result in the opened figure before closing this help dialog to END.'});
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


