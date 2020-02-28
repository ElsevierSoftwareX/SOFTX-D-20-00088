% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO EXAMPLE CASE 1 C: DATA PLOTTING
% Simple demonstration of (E1C) data plotting.

clear all; % Clear workspace
close all; % Close figures

% Example file
pathstr = fileparts([mfilename('fullpath') '.m']); % Get folder of this script
file = fullfile(pathstr, 'E_v5.wip'); % Construct full path of the example file
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
wit_io_license;

h = helpdlg({'EXAMPLE CASE 1 C: DATA PLOTTING' ...
    '' ...
    '* Using ''E_v5.wip'' WITec Project -file, which has Raman data from exfoliated graphene with 1-, 2- and 3-layer areas on 285 nm SiO2/Si-substrate.'});
if ishandle(h), figure(h); uiwait(h); end % Wait for helpdlg to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
[O_wid, O_wip, O_wid_HtmlNames] = wip.read(file, '-all', '-SpectralUnit', 'rel. 1/cm'); % Load all the file plottable content

% Get handles to some specific data
O_Text = O_wid(1); % Get object of "Global (Calibration Information)" at index 1
O_Bitmap = O_wid(2); % Get object of "Exfoliated graphene (Gr) on SiO2/Si-substrate<Video Image (Data)" at index 2
O_ImageScan = O_wid(3); % Get object of "Reduced<Image Scan 1 (Data)" at index 3
O_Mask = O_wid(6); % Get object of "1-layer Gr<Mask 2" at index 6
% To see these names, double-click O_wid_HtmlNames-variable under your Workspace!



%-------------------------------------------------------------------------%
h = helpdlg({'!!! (E1C) Plotting demonstration of plottables (TDBitmap, TDGraph, TDImage and TDText) and a non-plottable TDSpaceTransformation. Any non-plottable object is plotted like TDText but via DataTree-format:' ...
    'obj.plot();' ...
    'obj.plot(''-nosidebar'');' ...
    'obj.plot(''-compare'', obj2, ..., objN);' ...
    '' ...
    '* Read the code for more details.' ...
    '' ...
    '* Close this to END.'});
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Plottable objects
figure; O_Bitmap.plot(); % TDBitmap with sidebar
figure; O_ImageScan.plot(); % TDGraph with sidebar
figure; O_Mask.plot('-nosidebar'); % TDImage WITHOUT SIDEBAR
figure; O_Text.plot(); % TDText with sidebar'

% Non-plottable objects like TDSpaceTransformation
figure; O_Bitmap.Info.XTransformation.plot(); % TDBitmap's TDSpaceTransformation with sidebar

if ishandle(h), figure(h); uiwait(h); end
close all; % Close the plot
%-------------------------------------------------------------------------%


