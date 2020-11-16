% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO EXAMPLE CASE A 3: DATA PLOTTING
% Simple demonstration of (A3) data plotting.

wit.io.misc.edit(); % Open this code in Editor
close all; % Close figures

% Example file
pathstr = fullfile(wit.io.path, '+examples'); % Get folder of this script
file = fullfile(pathstr, 'A_v5.wip'); % Construct full path of the example file
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
wit.io.misc.license;

h = wit.io.misc.msgbox({'{\bf\fontsize{12}\color{magenta}EXAMPLE CASE 1 C:}' ...
    '{\bf\fontsize{12}DATA PLOTTING}' ...
    '' ...
    '\bullet Using ''A\_v5.wip'' WITec Project -file, which has Raman data from exfoliated graphene with 1-, 2- and 3-layer areas on 285 nm SiO2/Si-substrate.'});
wit.io.misc.uiwait(h); % Wait for wit.io.misc.msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
[O_wid, O_wip, O_wid_HtmlNames] = wit.io.read(file, '-all', '-SpectralUnit', 'rel. 1/cm'); % Load all the file plottable content

% Get handles to some specific data
O_Text = O_wid(1); % Get object of "Global (Calibration Information)" at index 1
O_Bitmap = O_wid(2); % Get object of "Exfoliated graphene (Gr) on SiO2/Si-substrate<Video Image (Data)" at index 2
O_ImageScan = O_wid(3); % Get object of "Reduced<Image Scan 1 (Data)" at index 3
O_Mask = O_wid(7); % Get object of "1-layer Gr<Mask 2" at index 7
% To see these names, double-click O_wid_HtmlNames-variable under your Workspace!



%-------------------------------------------------------------------------%
h = wit.io.misc.msgbox({'{\bf\fontsize{12}{\color{magenta}(A3)} Plot data}' ...
    '' ...
    '\bullet Although the plottable wid objects are of Types: TDBitmap, TDGraph, TDImage and TDText, the non-plottable objects are plotted like TDText but via DataTree-format:' ...
    '' ...
    '{\bf\fontname{Courier}obj.plot();}' ...
    '{\bf\fontname{Courier}obj.plot(''-nosidebar'');}' ...
    '{\bf\fontname{Courier}obj.plot(''-compare'', obj2, ..., objN);}' ...
    '' ...
    '\bullet Read the code for more details.' ...
    '' ...
    '\ldots Close this to END.'});
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Plottable objects
figure; O_Bitmap.plot(); % TDBitmap with sidebar
figure; O_ImageScan.plot(); % TDGraph with sidebar
figure; O_Mask.plot('-nosidebar'); % TDImage WITHOUT SIDEBAR
figure; O_Text.plot(); % TDText with sidebar'

% Non-plottable objects like TDSpaceTransformation
figure; O_Bitmap.Info.XTransformation.plot(); % TDBitmap's TDSpaceTransformation with sidebar

wit.io.misc.uiwait(h);
close all; % Close the plot
%-------------------------------------------------------------------------%


