% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO EXAMPLE CASE 2 C: DATA CROPPING
% Simple examples of (E2C) data cropping.

edit([mfilename('fullpath') '.m']); % Open this code in Editor
clear all; % Clear workspace
close all; % Close figures

% Example file
pathstr = fileparts([mfilename('fullpath') '.m']); % Get folder of this script
file = fullfile(pathstr, 'E_v5.wip'); % Construct full path of the example file
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
wit_io_license;

h = wit_io_msgbox({'{\bf\fontsize{12}\color{magenta}EXAMPLE CASE 2 C:}' ...
    '{\bf\fontsize{12}DATA CROPPING}' ...
    '' ...
    '\bullet Using ''E\_v5.wip'' WITec Project -file, which has Raman data from exfoliated graphene with 1-, 2- and 3-layer areas on 285 nm SiO2/Si-substrate.'});
if ishandle(h), figure(h); uiwait(h); end % Wait for wit_io_msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
[O_wid, O_wip, O_wid_HtmlNames] = wip.read(file, '-all', '-SpectralUnit', 'rel. 1/cm'); % Load all the file plottable content

% Get handles to some specific data
O_Bitmap = O_wid(2); % Get object of "Exfoliated graphene (Gr) on SiO2/Si-substrate<Video Image (Data)" at index 2
O_PointScan = O_wid(17); % Get object of "1-layer Gr<Point Scan 1 (Data)" at index 17
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
figure; O_Bitmap.plot();
figure; O_PointScan.plot();
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = wit_io_msgbox({'{\bf\fontsize{12}{\color{magenta}(E2C)} Cropping objects:}' ...
    '' ...
    '\bullet Any TDBitmap, TDGraph or TDImage can be cropped using {\bf\fontname{Courier}crop}-function, which takes pixel indices as input.' ...
    '' ...
    '\bullet Also, spectral range of any TDGraph can be cropped using {\bf\fontname{Courier}crop\_Graph}-function. (This feature is automatically used by {\bf\fontname{Courier}filter\_bg}-function.)' ...
    '' ...
    '\ldots Close this dialog to END and show cropped examples of the opened figures.'});
if ishandle(h), figure(h); uiwait(h); end
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Please note that the MATLAB indices begin from 1 and not from 0.

% [obj, Data_reduced, X_reduced, Y_reduced, Graph_reduced, Z_reduced] = ...
% crop(obj, ind_X_begin, ind_X_end, ind_Y_begin, ind_Y_end, ...
% ind_Graph_begin, ind_Graph_end, ind_Z_begin, ind_Z_end);

O_Bitmap_cropped = O_Bitmap.crop(150, [], 250, [], [], [], [], []); % Start/end indices in (px) for X, Y, Graph and Z dimensions. Here [] means no cropping.
% O_Bitmap_cropped = O_Bitmap.crop(150, [], 250, []); % Same as above but allow crop-function to fill-in the missing input.

% [obj, Data_reduced, Graph_reduced] = crop_Graph(obj, ind_range, ...
% Data_reduced, Graph_reduced);
O_PointScan_cropped = O_PointScan.crop_Graph([332 1130]);  % Start/end indices in (px) for Graph dimension. Here [] means no cropping.
% O_PointScan_cropped = O_PointScan.filter_bg([900 2800]); % Same as above, but here start/end values are in (rel. 1/cm). This is a specialized wrapper function for crop_Graph.

% Additionally, if Graph and Data were cropped elsewhere, then one can
% update all related wid objects (and all underlying wit objects) to it.
% Data_cropped = O_PointScan_cropped.Data;
% Graph_cropped = O_PointScan_cropped.Graph;
% O_PointScan_cropped = O_PointScan.crop_Graph([], Data_cropped, Graph_cropped); % Special case, used sometimes after wid.crop_Graph_with_bg_helper.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
figure; O_Bitmap_cropped.plot(); % Cropped bitmap
figure; O_PointScan_cropped.plot(); % Cropped spectrum

% It is worth noting that WHEN WRITING BACK TO WIP-FILE, the Viewer windows
% (shown on the WITec software side) may become corrupted due to the Data
% modifications if not removed before writing. This was a true risk until
% wit_io v1.1.2 (unless O_wip.destroy_all_Viewers; was manually executed).
% However, in the newer wit_io versions, the Viewers windows are now
% always removed before writing. User may disable this automation by
% setting O_wip.OnWriteDestroyAllViewers to false.

% ADDITIONALLY, remove any duplicate Transformations created by the
% (possibly multiple) data croppings (or i.e. data copyings). This is
% necessary when user wishes to utilize many of the WITec software's data
% analysis tools, which may refuse to work if the selected data do not
% share the same Transformation Id. IT IS NOTEWORTHY that this task is done
% now by default during *.wip file writing (unless the default user
% preference is changed as is shown in the last commented line).
O_wip.destroy_duplicate_Transformations; % Do it immediately
% O_wip.OnWriteDestroyDuplicateTransformations = true; % OR do it later on write
% wit_io_pref_set('wip_OnWriteDestroyDuplicateTransformations', true); % Permanently change its user preference for the future runs
%-------------------------------------------------------------------------%


