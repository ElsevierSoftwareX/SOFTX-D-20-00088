% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO EXAMPLE CASE 4: SPECTRAL STITCHING
% Simple example of (E4) spectral stitching.

clear all; % Clear workspace
close all; % Close figures

% Example file
pathstr = fileparts([mfilename('fullpath') '.m']); % Get folder of this script
file = fullfile(pathstr, 'E_04_stitch_spectra_v7.wip'); % Construct full path of the example file



%-------------------------------------------------------------------------%
wit_io_license;

h = helpdlg({'EXAMPLE CASE 4: SPECTRAL STITCHING' ...
    '' ...
    '* If unfamiliar with ''wit_io'', then go through the previous examples first.'});
uiwait(h); % Wait for helpdlg to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Load all TDGraphs and set their SpectralUnits to '(nm)'.
[O_wid, O_wip, O_wid_HtmlNames] = wip.read(file, '-all', '-Manager', '--Type', 'TDGraph', '-SpectralUnit', 'nm');
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'!!! (E4) Spectral stitching the measured LED lamp spectra into one spectrum:' ...
    '' ...
    '* Illustrative stitching procedure begins by closing this help dialog.'});
if ishandle(h), figure(h); uiwait(h); end
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
[O_result, X, Y] = O_wid.spectral_stitch('-debug'); % Here debug-mode is used to visualize the progress to the user. It can be used for double-checking. Remove '-debug' to disable such demonstration.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'!!! Spectral stitching has completed:' ...
    '' ...
    '* Here the 1st figure illustrates how each neighbouring datas were weighted. See the opened figures for the total-weighted datas, the original datas and the total-weights.' ...
    '' ...
    '* Close this dialog to END and see the final result.'});
if ishandle(h), figure(h); uiwait(h); end
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
close all;
figure; O_result.plot;
%-------------------------------------------------------------------------%


