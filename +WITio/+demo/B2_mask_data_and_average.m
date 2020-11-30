% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO DEMO CASE B 2: DATA MASKING AND SPATIAL AVERAGING
% Simple examples of data post processing like (B2 i.) masking and
% (B2 ii.) spatial averaging.

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

h = WITio.tbx.msgbox({'{\bf\fontsize{12}\color{magenta}DEMO CASE B2:}' ...
'{\bf\fontsize{12}DATA MASKING AND SPATIAL ' ...
'AVERAGING}' ...
'' ...
'\bullet Using ''A\_v5.wip'' WITec Project -file, which has Raman data from exfoliated ' ...
'graphene with 1-, 2- and 3-layer areas on 285 nm SiO2/Si-substrate.'}, '-TextWrapping', false);
WITio.tbx.uiwait(h); % Wait for WITio.tbx.msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
[O_wid, O_wip, O_wit] = WITio.read(file, '-all', '-SpectralUnit', 'rel. 1/cm'); % Load all the file plottable content

% Get handles to some specific data
O_ImageScan = O_wid(3); % Get object of "Reduced<Image Scan 1 (Data)" at index 3
O_Mask = O_wid(7); % Get object of "1-layer Gr<Mask 2" at index 7
% To see these names, either call 'O_wid(1).Name' or 'O_wid.manager;' in Command Window!



%-------------------------------------------------------------------------%
h = WITio.tbx.msgbox({'{\bf\fontsize{12}{\color{magenta}(B2 i.)} Masking of the ImageScan data:}' ...
'' ...
'\bullet This example uses "1-layer Gr<Mask 2"-mask on "Reduced<Image Scan 1 ' ...
'(Data)"-data.' ...
'' ...
'(A.) Plot can temporarily mask data with {\bf\fontname{Courier}''-mask''}-option.' ...
'(B.) Object can be masked using {\bf\fontname{Courier}image\_mask}-function.' ...
'(C.) Masks can be created/edited using {\bf\fontname{Courier}image\_mask\_editor}. ' ...
'' ...
'\bullet Please read the code that demonstrates the masking. Only case (C.) above is ' ...
'executed. Others have been commented in the code.' ...
'' ...
'\ldots Close the Mask Editor -window to continue...'}, '-TextWrapping', false);
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% CASE (B2 i. A.):
% figure; O_ImageScan.plot('-mask', O_Mask); % Show NaN-masked Image<TDGraph with sidebar

% CASE (B2 i. B.):
O_masked = O_ImageScan.image_mask(O_Mask); % Mask data (second input is mask)
% figure; O_masked.plot(); % GraphLine with sidebar

% CASE (B2 i. C.):
% O_mask = O_ImageScan.image_mask_editor(); % Create a new mask using O_ImageScan as background!
resetOnCleanup = WITio.tbx.pref.set('wip_AutoCreateObj', false); % Avoid TEMPORARILY creating a new mask object
[~, O_Mask.Data] = O_ImageScan.image_mask_editor(O_Mask.Data); % Edit mask O_mask using O_ImageScan as background!
clear resetOnCleanup; % Restore the original state
close all; % Close the plot
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = WITio.tbx.msgbox({'{\bf\fontsize{12}{\color{magenta}(B2 ii.)} Getting spatial average of the ' ...
'previously masked data.}' ...
'' ...
'\ldots Close this to END.'}, '-TextWrapping', false);
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
O_avg = O_masked.spatial_average();
figure; O_avg.plot; WITio.tbx.ifnodesktop(); % Point<TDGraph with sidebar
WITio.tbx.uiwait(h);
close all; % Close the plot
%-------------------------------------------------------------------------%

% Reset user preferences
clear resetOnCleanup; % The original values are restored here.


