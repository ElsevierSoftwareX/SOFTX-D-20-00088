% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO DEMO CASE F: SCANLINE ERROR CORRECTION
% Simple example of (F) correcting images with scanline errors, which can
% be additive (for height images from AFM or peak position images from CRM)
% or multiplicative (for intensity images from CRM or SNOM) in nature. Here
% AFM, CRM and SNOM stand for Atomic Force Microscopy, Confocal Raman
% Microscopy and Scanning Near-Field Optical Microscopy, respectively.

WITio.tbx.edit(); % Open this code in Editor
close all; % Close figures

% Demo file
pathstr = WITio.tbx.path.demo; % Get folder of this script
file = fullfile(pathstr, 'A_v5.wip'); % Construct full path of the demo file

%-------------------------------------------------------------------------%
WITio.tbx.license;

h = WITio.tbx.msgbox({'{\bf\fontsize{12}\color{magenta}DEMO CASE F:}' ...
'{\bf\fontsize{12}SCANLINE ERROR ' ...
'CORRECTION}' ...
'' ...
'\bullet If unfamiliar with ''WITio'', then go through the previous ' ...
'examples first.'}, '-TextWrapping', false);
WITio.tbx.uiwait(h); % Wait for WITio.tbx.msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Load all TDImages.
[O_wid, O_wip, O_wid_HtmlNames] = WITio.read(file, '-all', '-Manager', '--Type', 'TDImage');

O_Image = O_wid(7); % Get object of "Raman Si-peak<Sum[500-550]<Image Scan 2" at index 7

figure; O_Image.plot;

% This plotted image shows clear horizontal scanline errors. The image
% represents the integrated intensity of Raman Si-peak, for which reason
% the underlying error is expected to be multiplicative in nature.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = WITio.tbx.msgbox({'{\bf\fontsize{12}{\color{magenta}(F)} Scanline error correction of images:}' ...
'' ...
'\bullet This plotted image shows clear horizontal scanline errors. The image ' ...
'represents the integrated intensity of Raman Si-peak, for which reason the ' ...
'underlying error is expected to be multiplicative in nature.' ...
'' ...
'\bullet These additive and multiplicative scanline errors occur due to glitches of the ' ...
'scanning instrument. The scanning laser based measurements are very ' ...
'sensitive to various environmental effects, even though their sensitivity can be ' ...
'greatly reduced by vibration shielding. In this example case, no shielding was ' ...
'installed.' ...
'' ...
'\bullet As a solution, this toolbox offers two scanline correction algoritms:' ...
'(1) {\bf\fontname{Courier}apply\_MDLCA} for additive errors, where MDLCA stands for Median ' ...
'Difference Line Correction by Addition.' ...
'(2) {\bf\fontname{Courier}apply\_MRLCM} for multiplicative errors, where MRLCM stands for ' ...
'Median Difference Line Correction by Addition.' ...
'' ...
'\bullet Both of these have so called Clever-variants, {\bf\fontname{Courier}apply\_CMDLCA} and ' ...
'{\bf\fontname{Courier}apply\_CMRLCM}, which are designed to handle more problematic ' ...
'outliers.' ...
'' ...
'\bullet For more details, continue by reading the example case comments and the ' ...
'code documentation.' ...
'' ...
'\ldots Close this dialog to display the corrected image and END.'}, '-TextWrapping', false);
WITio.tbx.uiwait(h); % Wait for WITio.tbx.msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% This toolbox provides two scanline correction algoritms:
% (1a) 'apply_MDLCA' for additive errors, where MDLCA stands for Median
% Difference Line Correction by Addition.
% (2a) 'apply_MRLCM' for multiplicative errors, where MRLCM stands for
% Median Difference Line Correction by Addition.

% Median was used because it is one of the most outlier resistant statistic
% with breakdown point of 50% dataset contamination.

% Both of these have so called Clever-variants, which utilize an outlier
% detection scheme presented by G. Buzzi-Ferraris and F. Manenti (2011)
% (URL: http://dx.doi.org/10.1016/j.compchemeng.2010.11.004):
% (1a) 'apply_CMDLCA' for additive errors and problematic outliers.
% (2b) 'apply_CMRLCM' for multiplicative errors and problematic outliers.

% These algorithms have already been successfully used in the previously
% published work [1-2].
% [1] URL: http://urn.fi/URN:NBN:fi:aalto-201605122027
% [2] URL: https://doi.org/10.1016/j.jcrysgro.2018.07.024

% In the example case, it is enough to apply simple 'apply_MRLCM' to the
% multiplicative scanline errors seen in the image for the integrated
% intensity of Raman Si-peak:
O_Image_2 = O_Image.copy(); % Create copy
O_Image_2.Name = sprintf('Scanline Corrected<%s', O_Image_2.Name); % Rename it
O_Image_2.Data = WITio.fun.image.apply_MRLCM(O_Image_2.Data, 2); % Correct the data scanline errors in the 2nd dimension

figure; O_Image_2.plot;
%-------------------------------------------------------------------------%


