% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO DEMO CASE D: SPECTRAL STITCHING
% Simple example of (D) spectral stitching.

% Temporarily set user preferences
resetOnCleanup = WITio.tbx.pref.set({'wip_AutoCreateObj', 'wip_AutoCopyObj', 'wip_AutoModifyObj'}, {true, true, true}); % The original values prior to this call are restored when resetOnCleanup-variable is cleared.

WITio.tbx.edit(); % Open this code in Editor
close all; % Close figures

% Demo file
pathstr = WITio.tbx.path.demo; % Get folder of this script
file = fullfile(pathstr, 'D_stitch_spectra_v7.wip'); % Construct full path of the demo file



%-------------------------------------------------------------------------%
WITio.tbx.license;

h = WITio.tbx.msgbox({'{\bf\fontsize{12}\color{magenta}DEMO CASE D:}' ...
'{\bf\fontsize{12}SPECTRAL STITCHING}' ...
'' ...
'\bullet If unfamiliar with ''WITio'', then go through the previous ' ...
'examples first.'}, '-TextWrapping', false);
WITio.tbx.uiwait(h); % Wait for WITio.tbx.msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Load all TDGraphs and set their SpectralUnits to '(nm)'.
[O_wid, O_wip, O_wit] = WITio.read(file, '-all', '-Manager', '--Type', 'TDGraph', '-SpectralUnit', 'nm');
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = WITio.tbx.msgbox({'{\bf\fontsize{12}{\color{magenta}(D)} Spectral stitching the measured ' ...
'LED lamp spectra into one spectrum:}' ...
'' ...
'\bullet Illustrative stitching procedure begins by closing this help dialog.'}, '-TextWrapping', false);
WITio.tbx.uiwait(h); % Wait for WITio.tbx.msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Spectral stitching of the given TDGraph objects into a large spectrum.
% Each TDGraph must be of same spatial size. Stitching of each individual
% overlap is linear, but, due to a product rule, becomes non-linear for
% more generalized case of multiple simultaneous overlaps. Linear case
% behaves like WITec's Spectral Stitching measurement scheme.

% WARNING! The related instrumental errors, if NOT corrected for, can lead
% to UNPHYSICAL stitching result in the overlapping regions, even if their
% apparent stitching result looks smooth!
if WITio.tbx.verbose, % This is true by default (and can be set by WITio.tbx.pref.set('Verbose', tf);)
    [O_result, X, Y] = O_wid.spectral_stitch('-debug'); % Here debug-mode is used to visualize the progress to the user. It can be used for double-checking. Remove '-debug' to disable such demonstration.
else,
    [O_result, X, Y] = O_wid.spectral_stitch();
end
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
[h,b] = WITio.tbx.msgbox({'{\bf\fontsize{12}Spectral stitching has completed:}' ...
'' ...
'\bullet Here the 1st figure illustrates how each neighbouring datas were ' ...
'weighted. See the opened figures for the total-weighted datas, the ' ...
'original datas and the total-weights.' ...
'' ...
'\ldots Close this dialog to END and see the final result.'}, '-TextWrapping', false);
WITio.tbx.uiwait(h); % Wait for WITio.tbx.msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
close all;
figure; O_result.plot;
%-------------------------------------------------------------------------%

% Reset user preferences
clear resetOnCleanup; % The original values are restored here.


