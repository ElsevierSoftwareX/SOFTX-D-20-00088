% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO EXAMPLE CASE 6: SCANLINE ERROR CORRECTION
% Simple example of (E6) correcting images with scanline errors, which can
% be additive (for height images from AFM or peak position images from CRM)
% or multiplicative (for intensity images from CRM or SNOM) in nature. Here
% AFM, CRM and SNOM stand for Atomic Force Microscopy, Confocal Raman
% Microscopy and Scanning Near-Field Optical Microscopy, respectively.

edit([mfilename('fullpath') '.m']); % Open this code in Editor
clear all; % Clear workspace
close all; % Close figures

% Example file
pathstr = fileparts([mfilename('fullpath') '.m']); % Get folder of this script
file = fullfile(pathstr, 'E_v5.wip'); % Construct full path of the example file

%-------------------------------------------------------------------------%
wit_io_license;

h = wit_io_msgbox({'{\bf\fontsize{12}\color{magenta}EXAMPLE CASE 6:}' ...
    '{\bf\fontsize{12}SCANLINE ERROR CORRECTION}' ...
    '' ...
    '\bullet If unfamiliar with ''wit\_io'', then go through the previous examples first.'});
uiwait(h); % Wait for wit_io_msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Load all TDImages.
[O_wid, O_wip, O_wid_HtmlNames] = wip.read(file, '-all', '-Manager', '--Type', 'TDImage');

O_Image = O_wid(7); % Get object of "Raman Si-peak<Sum[500-550]<Image Scan 2" at index 7

figure; O_Image.plot;

% The image plotted above shows clear horizontal scanline errors. The image
% represents the integrated intensity of Raman Si-peak, which means that
% the underlying error is multiplicative in nature.

% This toolbox provides two scanline correction algoritms:
% (1a) 'apply_MDLCA' for additive errors, where MDLCA stands for Median
% Difference Line Correction by Addition.
% (2a) 'apply_MRLCM' for multiplicative errors, where MRLCM stands for
% Median Difference Line Correction by Addition.

% Both of these have so called Clever-variants, which utilize an outlier
% detection scheme presented by G. Buzzi-Ferraris and F. Manenti (2011)
% (URL: http://dx.doi.org/10.1016/j.compchemeng.2010.11.004):
% (1a) 'apply_CMDLCA' for additive errors and problematic outliers.
% (2b) 'apply_CMRLCM' for multiplicative errors and problematic outliers.

% For more details, see to their code documentations.

% In this case, it is enough to apply simple 'apply_MRLCM' to the
% multiplicative scanline errors seen in the image for the integrated
% intensity of Raman Si-peak:
O_Image_2 = O_Image.copy(); % Create copy
O_Image_2.Name = sprintf('Scanline Corrected<%s', O_Image_2.Name); % Rename it
O_Image_2.Data = apply_MRLCM(O_Image_2.Data, 2); % Correct the data scanline errors in the 2nd dimension

figure; O_Image_2.plot;
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = wit_io_msgbox({'{\bf\fontsize{12}{\color{magenta}(E6)} Scanline correction of images:}' ...
    '' ...
    '\bullet Aim is to correct the additive/multiplicative scanline errors due to the scanning instrument glitches. The scanning laser based measurements are very sensitive to various environmental effects, but these can be greatly reduced by vibration shielding. Median is used because it is one of the most outlier resistant statistic with breakdown point of 50% dataset contamination.' ...
    '' ...
    '\bullet Read the code documentation for more details.' ...
    '' ...
    '\ldots Close this dialog to END.'});
%-------------------------------------------------------------------------%


