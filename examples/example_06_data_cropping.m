% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO EXAMPLE 6: DATA CROPPING
% The data cropping demonstration.

clear all; % Clear workspace
close all; % Close figures

% Example file
pathstr = fileparts([mfilename('fullpath') '.m']); % Get folder of this script
file = fullfile(pathstr, 'example_v5.wip'); % Construct full path of the example file
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'EXAMPLE 6: DATA CROPPING' ...
    '' ...
    '* Using ''example_v5.wip'' WITec Project -file, which has Raman data from exfoliated graphene with 1-, 2- and 3-layer areas on 285 nm SiO2/Si-substrate.' ...
    '' ...
    '* Please note that MOST of this ''wit_io'' code is OPEN-SOURCED under simple and permissive BSD 3-Clause License and is FREE-TO-USE like described in LICENSE.txt!'});
if ishandle(h), figure(h); uiwait(h); end % Wait for helpdlg to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
[C_wid, C_wip, HtmlNames] = wip.read(file, '-all', '-SpectralUnit', '(rel. 1/cm)'); % Load all the file plottable content

% Get handles to some specific data
C_Bitmap = C_wid(2); % Get object of "Exfoliated graphene (Gr) on SiO2/Si-substrate<Video Image (Data)" at index 2
C_PointScan = C_wid(17); % Get object of "1-layer Gr<Point Scan 1 (Data)" at index 17
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
figure; C_Bitmap.plot();
figure; C_PointScan.plot();
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'!!! (1) Cropping objects:' ...
    '' ...
    '* Any TDBitmap, TDGraph or TDImage can be cropped using crop-function, which takes pixel indices as input.' ...
    '' ...
    '* Also, spectral range of any TDGraph can be cropped using crop_Graph-function. (This feature is automatically used by filter_bg-function.)' ...
    '' ...
    '* Close this dialog to show cropped examples of the opened figures.'});
if ishandle(h), figure(h); uiwait(h); end
close all; % Close the plot
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Please note that the MATLAB indices begin from 1 and not from 0.

% [obj, Data_reduced, X_reduced, Y_reduced, Graph_reduced, Z_reduced] = ...
% crop(obj, ind_X_begin, ind_X_end, ind_Y_begin, ind_Y_end, ...
% ind_Graph_begin, ind_Graph_end, ind_Z_begin, ind_Z_end);

C_Bitmap_cropped = C_Bitmap.crop(150, [], 250, [], [], [], [], []); % Start/end indices in (px) for X, Y, Graph and Z dimensions. Here [] means no cropping.
% C_Bitmap_cropped = C_Bitmap.crop(150, [], 250, []); % Same as above but allow crop-function to fill-in the missing input.

% [obj, Data_reduced, Graph_reduced] = crop_Graph(obj, ind_range, ...
% Data_reduced, Graph_reduced);
C_PointScan_cropped = C_PointScan.crop_Graph([332 1130]);  % Start/end indices in (px) for Graph dimension. Here [] means no cropping.
% C_PointScan_cropped = C_PointScan.filter_bg([900 2800]); % Same as above, but here start/end values are in (rel. 1/cm). This is a specialized wrapper function for crop_Graph.

% Additionally, if Graph and Data were cropped elsewhere, then one can
% update all related wid objects (and all underlying wit objects) to it.
% Data_cropped = C_PointScan_cropped.Data;
% Graph_cropped = C_PointScan_cropped.Graph;
% C_PointScan_cropped = C_PointScan.crop_Graph([], Data_cropped, Graph_cropped); % Special case, used sometimes after wid.crop_Graph_with_bg_helper.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
figure; C_Bitmap_cropped.plot(); % Cropped bitmap
figure; C_PointScan_cropped.plot(); % Cropped spectrum
%-------------------------------------------------------------------------%


