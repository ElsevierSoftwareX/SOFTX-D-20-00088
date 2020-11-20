% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO EXAMPLE CASE B 1: DATA FILTERING FOR LINESHAPE PARAMETERS
% Simple examples of data post processing like (B1 i.) filtering and
% (B1 ii.) fitting.

WITio.core.edit(); % Open this code in Editor
close all; % Close figures

% Example file
pathstr = fullfile(WITio.path.package, '+examples'); % Get folder of this script
file = fullfile(pathstr, 'A_v5.wip'); % Construct full path of the example file
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
WITio.core.license;

h = WITio.core.msgbox({'{\bf\fontsize{12}\color{magenta}EXAMPLE CASE B1:}' ...
'{\bf\fontsize{12}DATA FILTERING FOR LINESHAPE ' ...
'PARAMETERS}' ...
'' ...
'\bullet Using ''A\_v5.wip'' WITec Project -file, which has Raman data from exfoliated graphene with 1-, ' ...
'2- and 3-layer areas on 285 nm SiO2/Si-substrate.'}, '-TextWrapping', false);
WITio.core.uiwait(h); % Wait for WITio.core.msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
[O_wid, O_wip, O_wid_HtmlNames] = WITio.read(file, '-all', '-SpectralUnit', 'rel. 1/cm'); % Load all the file plottable content and force SpectralUnit to Raman shift

% Get handles to some specific data
O_Text = O_wid(1); % Get object of "Global (Calibration Information)" at index 1
O_Bitmap = O_wid(2); % Get object of "Exfoliated graphene (Gr) on SiO2/Si-substrate<Video Image (Data)" at index 2
O_ImageScan = O_wid(3); % Get object of "Reduced<Image Scan 1 (Data)" at index 3
O_Mask = O_wid(7); % Get object of "1-layer Gr<Mask 2" at index 7
O_Point = O_wid(17); % Get object of "1-layer Gr<Point Scan 1 (Data)" at index 17
% To see these names, double-click O_wid_HtmlNames-variable under your Workspace!

% Alternative way to get these handles is by use of manager without GUI and
% with a little prior knowledge of the file contents
O_ImageScans = O_wip.manager('-nomanager', '-Type', 'TDGraph', '-SubType', 'Image');
O_ImageScan = O_ImageScans(1); % Get the first Image<TDGraph in the file
O_Images = O_wip.manager('-nomanager', '-Type', 'TDImage');
O_Mask = O_Images(3); % Get the third TDImage in the file
O_Points = O_wip.manager('-nomanager', '-Type', 'TDGraph', '-SubType', 'Point');
O_Point = O_Points(end); % Get the last TDGraph Point in the file
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = WITio.core.msgbox({'{\bf\fontsize{12}{\color{magenta}(B1 i.)} Apply filters on the Raman D-, ' ...
'G- and 2D-peaks:}' ...
'' ...
'\bullet Please read the code that applies Sum and Center of Mass -filters over ' ...
'the specified ranges.' ...
'' ...
'\ldots Click and see the newly processed data in the end of the opened ' ...
'Project Manager before closing this help dialog. Please note that you may ' ...
'also use arrow keys to move in images.'}, '-TextWrapping', false);
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Determine project parameters (but not needed because AutoCreateObj,
% AutoCopyObj and AutoModifyObj are true by default).
% O_wip.AutoCreateObj = true; % If wid-class functions should ALWAYS create new object
% O_wip.AutoCopyObj = true; % If wid-class functions should ALWAYS copy object
% O_wip.AutoModifyObj = true; % If wid-class functions should ALWAYS modify object
% O_wip.pushAutoCreateObj(true); % If wid-class functions should ONLY ONCE create new object
% O_wip.pushAutoCopyObj(true); % If wid-class functions should ONLY ONCE copy object
% O_wip.pushAutoModifyObj(true); % If wid-class functions should ONLY ONCE modify object

% Specify the spectral ranges for the Raman D, G and 2D-peaks of graphene
Range_D = [1300 1400]; % Filtering range for the D-peak
Range_G = [1540 1640]; % Filtering range for the G-peak
Range_2D = [2600 2800]; % Filtering range for the 2D-peak

% Manually use wid-class filter_bg-function to calculate the D-peak sum
% [~, ~] = O_ImageScan.filter_bg(D, 4, 4); % Like in the software, use 4-pixels lower and upper background averaging. Set 0 and 0 to disable it.
[O_ImageScan_D, Data_D] = O_ImageScan.filter_bg(Range_D); % Same as above, because the 4-pixels lower and upper background averaging is enabled by default.
Sum_D = sum(Data_D, 3);

% Or evaluate sum, center of mass with one function call.
[O_Sum_G, Sum_G] = O_ImageScan.filter_sum(Range_G); % Sum filtering of G-peak after removal of linear background (using filter_bg)
[O_Sum_2D, Sum_2D] = O_ImageScan.filter_sum(Range_2D); % Sum filtering of 2D-peak after removal of linear background (using filter_bg)
[O_CoM_G, CoM_G] = O_ImageScan.filter_center_of_mass(Range_G); % Center of mass filtering of G-peak after removal of linear background (using filter_bg)
[O_CoM_2D, CoM_2D] = O_ImageScan.filter_center_of_mass(Range_2D); % Center of mass filtering of 2D-peak after removal of linear background (using filter_bg)
% Other implemented filter types can be found in +WITio\@wid-folder
% starting with 'filter_'. You can also write your own custom filter by
% utilizing a generic filter_fun (under @wid) like filter_sum and others.

O_wip.manager;
WITio.core.uiwait(h);
close all; % Close Project Manager
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = WITio.core.msgbox({'{\bf\fontsize{12}{\color{magenta}(B1 ii.)} Apply lineshape-fitting filters ' ...
'on the Raman 0-, D-, G- and ' ...
'2D-peaks:}' ...
'' ...
'\bullet Please read the code that applies Gaussian and Voigtian -filters over the ' ...
'specified ranges.' ...
'' ...
'\ldots See the fitting result in the opened figure before closing this help dialog ' ...
'to END.'}, '-TextWrapping', false);
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
Range_0 = [-25 25]; % The spectral range of Rayleigh-peak (laser line) at (supposedly) zero

if WITio.core.verbose, % This is true by default (and can be set by WITio.core.pref.set('Verbose', tf);)
    % First fit Gaussian to Rayleigh-peak in order to find instrument-induced Fwhm_G (needed for Voigtian-fitting)
    [O_Point_0, ~, ~, Point_Fwhm_G] = O_Point.filter_gaussian(Range_0); % Gauss filtering after removal of linear background (using filter_bg)

    % Then fit Voigtian to D-, G- and 2D-peaks, but Lock 'Fwhm_G' parameter to previously experimental value in order to retain physical meaning!
    O_Point_D = O_Point.filter_voigtian({'-Fwhm_G', Point_Fwhm_G}, Range_D); % Voigt filtering after removal of linear background (using filter_bg)
    O_Point_G = O_Point.filter_voigtian({'-Fwhm_G', Point_Fwhm_G}, Range_G); % Voigt filtering after removal of linear background (using filter_bg)
    O_Point_2D = O_Point.filter_voigtian({'-Fwhm_G', Point_Fwhm_G}, Range_2D); % Voigt filtering after removal of linear background (using filter_bg)
else,
    % First fit Gaussian to Rayleigh-peak in order to find instrument-induced Fwhm_G (needed for Voigtian-fitting)
    [O_Point_0, ~, ~, Point_Fwhm_G] = O_Point.filter_gaussian({'-silent'}, Range_0); % Gauss filtering after removal of linear background (using filter_bg)

    % Then fit Voigtian to D-, G- and 2D-peaks, but Lock 'Fwhm_G' parameter to previously experimental value in order to retain physical meaning!
    O_Point_D = O_Point.filter_voigtian({'-Fwhm_G', Point_Fwhm_G, '-silent'}, Range_D); % Voigt filtering after removal of linear background (using filter_bg)
    O_Point_G = O_Point.filter_voigtian({'-Fwhm_G', Point_Fwhm_G, '-silent'}, Range_G); % Voigt filtering after removal of linear background (using filter_bg)
    O_Point_2D = O_Point.filter_voigtian({'-Fwhm_G', Point_Fwhm_G, '-silent'}, Range_2D); % Voigt filtering after removal of linear background (using filter_bg)
end

% Compare the experimental data with the fitting result using '-compare'-feature of obj.plot
figure; O_Point.plot('-compare', O_Point_0(end), O_Point_D(end), O_Point_G(end), O_Point_2D(end)); % Show fitting results % Image<TDGraph with sidebar

WITio.core.uiwait(h);
close all; % Close the plot
%-------------------------------------------------------------------------%


