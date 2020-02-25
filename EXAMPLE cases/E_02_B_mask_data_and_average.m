% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO EXAMPLE CASE 2 B: DATA MASKING AND SPATIAL AVERAGING
% Simple examples of data post processing like (E2B i.) masking and
% (E2B ii.) spatial averaging.

clear all; % Clear workspace
close all; % Close figures

% Example file
pathstr = fileparts([mfilename('fullpath') '.m']); % Get folder of this script
file = fullfile(pathstr, 'E_v5.wip'); % Construct full path of the example file
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'EXAMPLE CASE 2 B: DATA MASKING AND SPATIAL AVERAGING' ...
    '' ...
    '* Using ''E_v5.wip'' WITec Project -file, which has Raman data from exfoliated graphene with 1-, 2- and 3-layer areas on 285 nm SiO2/Si-substrate.' ...
    '' ...
    '* Please note that MOST of this ''wit_io'' code is OPEN-SOURCED under simple and permissive BSD 3-Clause License and is FREE-TO-USE like described in LICENSE.txt!'});
if ishandle(h), figure(h); uiwait(h); end % Wait for helpdlg to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
[O_wid, O_wip, O_wid_HtmlNames] = wip.read(file, '-all', '-SpectralUnit', 'rel. 1/cm'); % Load all the file plottable content

% Get handles to some specific data
O_ImageScan = O_wid(3); % Get object of "Reduced<Image Scan 1 (Data)" at index 3
O_Mask = O_wid(6); % Get object of "1-layer Gr<Mask 2" at index 6
% To see these names, double-click O_wid_HtmlNames-variable under your Workspace!



%-------------------------------------------------------------------------%
h = helpdlg({'!!! (E2B i.) Masking of the ImageScan data:' ...
    '' ...
    '* This example uses "1-layer Gr<Mask 2"-mask on "Reduced<Image Scan 1 (Data)"-data.' ...
    '' ...
    '(A.) Plot can temporarily mask data with ''-mask''-option.' ...
    '(B.) Object can be masked using image_mask-function.' ...
    '(C.) Masks can be created/edited using image_mask_editor. ' ...
    '' ...
    '* Please read the code that demonstrates the masking. Only case (C.) above is executed. Others have been commented in the code.' ...
    '' ...
    '* Close the Mask Editor -window to continue...'});
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% CASE (E2B i. A.):
% figure; O_ImageScan.plot('-mask', O_Mask); % Show NaN-masked Image<TDGraph with sidebar

% CASE (E2B i. B.):
O_masked = O_ImageScan.image_mask(O_Mask); % Mask data (second input is mask)
% figure; O_masked.plot(); % GraphLine with sidebar

% CASE (E2B i. C.):
% O_mask = O_ImageScan.image_mask_editor(); % Create a new mask using O_ImageScan as background!
O_wip.pushAutoCreateObj(false); % Avoid TEMPORARILY creating a new mask object
[~, O_Mask.Data] = O_ImageScan.image_mask_editor(O_Mask.Data); % Edit mask O_mask using O_ImageScan as background!
close all; % Close the plot
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'!!! (E2B ii.) Getting spatial average of the previously masked data.' ...
    '' ...
    '* Close this to END.'});
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
O_avg = O_masked.spatial_average();
figure; O_avg.plot; % Point<TDGraph with sidebar
if ishandle(h), figure(h); uiwait(h); end
close all; % Close the plot
%-------------------------------------------------------------------------%


