% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO DEMO CASE B 3: DATA CROPPING
% Simple examples of (B3) data cropping.

% Temporarily set user preferences
resetOnCleanup = WITio.tbx.pref.set({'wip_AutoCreateObj', 'wip_AutoCopyObj', 'wip_AutoModifyObj'}, {true, true, true}); % The original values prior to this call are restored when resetOnCleanup-variable is cleared.

WITio.tbx.edit(); % Open this code in Editor
close all; % Close figures

% Demo file
pathstr = WITio.tbx.path.demo; % Get folder of this script
file = fullfile(pathstr, 'A_v5.wip'); % Construct full path of the demo file
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
WITio.tbx.license;

h = WITio.tbx.msgbox({'{\bf\fontsize{12}\color{magenta}DEMO CASE B3:}' ...
'{\bf\fontsize{12}DATA CROPPING}' ...
'' ...
'\bullet Using ''A\_v5.wip'' WITec Project -file, which has Raman data from ' ...
'exfoliated graphene with 1-, 2- and 3-layer areas on 285 nm ' ...
'SiO2/Si-substrate.'}, '-TextWrapping', false);
WITio.tbx.uiwait(h); % Wait for WITio.tbx.msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
[O_wid, O_wip, O_wit] = WITio.read(file, '-all', '-SpectralUnit', 'rel. 1/cm'); % Load all the file plottable content

% Get handles to some specific data
O_Bitmap = O_wid(2); % Get object of "Exfoliated graphene (Gr) on SiO2/Si-substrate<Video Image (Data)" at index 2
O_PointScan = O_wid(17); % Get object of "1-layer Gr<Point Scan 1 (Data)" at index 17
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
figure; O_Bitmap.plot(); WITio.tbx.ifnodesktop();
figure; O_PointScan.plot(); WITio.tbx.ifnodesktop();
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = WITio.tbx.msgbox({'{\bf\fontsize{12}{\color{magenta}(B3)} Cropping objects:}' ...
'' ...
'\bullet Any TDBitmap, TDGraph or TDImage can be cropped using ' ...
'{\bf\fontname{Courier}crop}-function, which takes pixel indices as input.' ...
'' ...
'\bullet Also, spectral range of any TDGraph can be cropped using ' ...
'{\bf\fontname{Courier}crop\_Graph}-function. (This feature is automatically used by ' ...
'{\bf\fontname{Courier}filter\_bg}-function.)' ...
'' ...
'\ldots Close this dialog to END and show cropped examples of the opened ' ...
'figures.'}, '-TextWrapping', false);
WITio.tbx.uiwait(h); % Wait for WITio.tbx.msgbox to be closed before continuing.
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
% O_PointScan_cropped = O_PointScan.crop_Graph([], Data_cropped, Graph_cropped); % Special case, used sometimes after WITio.obj.wid.crop_Graph_with_bg_helper.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
figure; O_Bitmap_cropped.plot(); WITio.tbx.ifnodesktop(); % Cropped bitmap
figure; O_PointScan_cropped.plot(); WITio.tbx.ifnodesktop(); % Cropped spectrum

% It is worth noting that WHEN WRITING BACK TO WIP-FILE, the Viewer windows
% (shown on the WITec software side) may become corrupted due to the Data
% modifications if not removed before writing. This was a true risk until
% WITio v1.1.2 (unless O_wip.destroy_Viewers; was manually executed).
% However, in the newer WITio versions, the Viewers windows are now
% always removed before writing. User may disable this automation by
% setting O_wip.AutoDestroyViewers to false.

% ADDITIONALLY, remove any duplicate Transformations created by the
% (possibly multiple) data croppings (or i.e. data copyings). This is
% necessary when user wishes to utilize many of the WITec software's data
% analysis tools, which may refuse to work if the selected data do not
% share the same Transformation Id. IT IS NOTEWORTHY that this task is done
% now by default during *.wip file writing (unless the default user
% preference is changed as is shown in the last commented line).
O_wip.destroy_duplicate_Transformations; % Do it immediately
% O_wip.AutoDestroyDuplicateTransformations = true; % OR do it later on write
% WITio.tbx.pref.set('wip_AutoDestroyDuplicateTransformations', true); % Permanently change its user preference for the future runs
%-------------------------------------------------------------------------%

% Reset user preferences
clear resetOnCleanup; % The original values are restored here.


