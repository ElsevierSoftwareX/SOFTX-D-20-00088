% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO EXAMPLE 1: LOADING CONTENT AND UNITS
% This example 1 is an introduction to the usage of wit_io-functionality.
% It utilizes wip.read under '@wip'-folder to load WITec Project (*.WIP)
% -files directly to the MATLAB environment without exporting/importing. It
% also allows modifications of the content units on the fly.

clear all; % Clear workspace
close all; % Close figures

% Example file
pathstr = fileparts([mfilename('fullpath') '.m']); % Get folder of this script
file = fullfile(pathstr, 'example_v5.wip'); % Construct full path of the example file
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'EXAMPLE 1: LOADING CONTENT AND UNITS' ...
    '' ...
    '* Using ''example_v5.wip'' WITec Project -file, which has Raman data from exfoliated graphene with 1-, 2- and 3-layer areas on 285 nm SiO2/Si-substrate.' ...
    '' ...
    '* Please note that MOST of this ''wit_io'' code is OPEN-SOURCED under simple and permissive BSD 3-Clause License and is FREE-TO-USE like described in LICENSE.txt!'});
if ishandle(h), figure(h); uiwait(h); end % Wait for helpdlg to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
helpdlg({'!!! (1A) Load and browse file contents in a GUI by executing:' ...
    '[C_wid, C_wip, HtmlNames] = wip.read(file);' ...
    '' ...
    '* It opens the file in a Project Manager -window, listing only the plottable data types (TDBitmap, TDGraph, TDImage, TDText). Non-plottable data types, such as TDInterpretation and TDTransformation, are hidden by default, but can be made visible by adding ''-Manager'', {''-all''} as an extra input pair.' ...
    '' ...
    '* A preview window is normally opened for each selected list item. Multiple items may be left-mouse selected one-by-one by holding Ctrl. Alternatively, a range of items may be selected by holding Shift.' ...
    '' ...
    '* Upon closing the Project Manager -window, it will return the selected data and their Html-names as C_wid and HtmlNames, respectively. Project is returned as C_wip. Read comments in these examples for better understanding of these output variables.' ...
    '' ...
    '* Click any item to open a preview window (by default). Also, clicking the opened preview window may open a subpreview window, when data has third dimension like a spectrum per pixel.  Please note that you may also use arrow keys to move in images.' ...
	'' ...
	'!!! Close the opened Project Manager -window to continue...'});
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% This opens the specified file in a Project Manager -window.
[C_wid, C_wip, HtmlNames] = wip.read(file); % (1A) Browse the file contents

% [C_wid, C_wip, HtmlNames] = wip.read(file, '-Manager', {'-all'}); % To show also the non-plottable data
% [C_wid, C_wip, HtmlNames] = wip.read(file, '-Manager', {'-Type', 'TDGraph'}); % To show only TDGraphs
% [C_wid, C_wip, HtmlNames] = wip.read(file, '-Manager', {'-Type', {'TDBitmap', 'TDGraph', 'TDImage'}}); % To show only TDBitmap, TDGraphs and TDImage
% * Other possible '-Manager' options are '-singlesection', '-nopreview',
% '-closepreview', '-nomanager', '-Title', '-Type' and '-SubType'.

% !!! Meaning of the output variables:
% * C_wid: Selected datas loaded as WID-class objects. Each object has the
% following properties Type, Name, Data, Info, Version, Id, ImageIndex,
% OrdinalNumber, SubType, Links, AllLinks, Tag and Project. To see these,
% double-click C_wid under Workspace to see each of these. Code interprets
% these from the loaded file WIT-node tree structure.
% * C_wip: Resulting project loaded as WIP-class object. Its properties are
% File, Version, Data, Tree, ForceDataUnit, ForceSpaceUnit,
% ForceSpectralUnit, ForceTimeUnit, UseLineValid, AutoCopyObj,
% AutoModifyObj and ArbitraryUnit.
% * HtmlNames: The Html names of the selected datas. Double-click HtmlNames
% under Workspace to see these (and rescale the 1st column by holding left-
% mouse on the border between 1 and 2). This is useful feature, when
% loading a lot of data at once.
%-------------------------------------------------------------------------%



close all; % Close all windows before continuing



%-------------------------------------------------------------------------%
h = helpdlg({'!!! (1B) OR, load all file contents without GUI by executing:' ...
    '[...] = wip.read(file, ''-all'');' ...
    '' ...
    '!!! (1C) OR, specify ''-ifall'' to ask whether to browse or load the content:' ...
    '[...] = wip.read(file, ''-ifall'');' ...
    '' ...
    '!!! (1D) OR, load by browsing file system for WITec Project/Data (*.wip/*.wid) -files by executing:' ...
    '[...] = wip.read();'});
if ishandle(h), figure(h); uiwait(h); end % Wait for helpdlg to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% This opens the specified file. Then automatically loads all.
% [C_wid, C_wip, HtmlNames] = wip.read(file, '-all'); % (1B) Load all file content
% [C_wid, C_wip, HtmlNames] = wip.read(file, '-ifall'); % (1C) Ask whether to browse or load the file content
% [C_wid, C_wip, HtmlNames] = wip.read(); % (1D) Browse the file system
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'ALSO, the selected content units (DataUnit, SpaceUnit, SpectralUnit and TimeUnit) may be modified upon loading:' ...
    '' ...
    '!!! (2A) by adding parameter pairs to wip.read as below:' ...
    '[...] = wip.read(..., ''-DataUnit'', ''Counts'', ''-SpaceUnit'', ''(µm)'', ''-SpectralUnit'', ''(nm)'', ''-TimeUnit'', ''(s)'');' ...
    '' ...
    '!!! (2B) by specifying the units in the bottom of the opened Project Manager GUI.' ...
    '' ...
    '!!! (2C) by modifying C_wip-object ForceDataUnit, ForceSpaceUnit, ForceSpectralUnit and ForceTimeUnit:' ...
    'C_wip.ForceDataUnit = ''Counts'';' ...
    'C_wip.ForceSpaceUnit = ''(µm)'';' ...
    'C_wip.ForceSpectralUnit = ''(nm)'';' ...
    'C_wip.ForceTimeUnit = ''(s)'';' ...
    '' ...
    '!!! (2D) temporarily using wip.interpret (or easier wid-class interpret_X, interpret_Y, interpret_Z, interpret_Graph member-functions).' ...
    '' ...
    '* Please read the code!' ...
    '' ...
    '* Close this to END.'});
if ishandle(h), figure(h); uiwait(h); end % Wait for helpdlg to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% !!! (2A) Enforce units via wip.read extra parameters:
% Extra parameters '-DataUnit', '-SpaceUnit', '-SpectralUnit' and
% '-TimeUnit' can be specified (in any order) to override the original
% corresponding units. For '-DataUnit', the input can be a string (new name
% of the Unit). For others, the input can be an integer (UnitIndex) or a
% search string.
[C_wid, C_wip, HtmlNames] = wip.read(file, '-all', ...
    '-DataUnit', 'Counts', ... % Can be a string
    '-SpaceUnit', '(µm)', ... % Can be an integer (0-5) or a search string
    '-SpectralUnit', '(nm)', ... % Can be an integer (0-7) or a search string
    '-TimeUnit', '(s)'); % Can be an integer (0-7) or a search string
% Try above without '-all' to see the specified units in Project Manager.
% Try search strings interactively in the bottom of the opened GUI window!

C = C_wid(3); % Get object of "Reduced<Image Scan 1 (Data)" at index 3



% !!! (2C) Enforce units as post-processing step
C_wip.ForceSpaceUnit = ''; % Remove the SpaceUnit enforcement and use the original units!
C_wip.ForceSpaceUnit = 'Invalid unit'; % But will result in '' and hence does the same as above!
C_wip.ForceSpaceUnit = 'Micrometers (µm)'; % Set SpaceUnit to µm by its full name (seen in interpret.m under @wip)
C_wip.ForceSpaceUnit = 'Micro'; % Does the same as above, effectively using strfind-functionality
C_wip.ForceSpaceUnit = '(µm)'; % Does the same as above

% figure; C.plot; % (µm) as x- and y-axes
% C_wip.ForceSpaceUnit = '(Å)';
% figure; C.plot; % (Å) as x- and y-axes



% !!! (2D) Temporarily alter units via wip.interpret:
C_Info = C.Info; % Load its READ-ONLY Info-struct only once, because its function call can be time consuming.
% * Double-click C_Info in Workspace to see its full contents!

% Temporarily change SpaceUnit of X-axis (== 1st dimension of C.Data)
X_um = C_Info.X; % = C.interpret_X(); % Get the internal input
XLength_um = C_Info.XLength; % Get the internal input
X_angstrom = C.interpret_X('(Å)'); % Convert the INTERNAL input == Info.X to new units
XLength_angstrom = C.interpret_X('(Å)', C_Info.XLength); % Convert the EXTERNAL input == C_Info.XLength to new units

% MANUAL: Same as above but behind the scenes revealed
[XUnit_angstrom_2, X_angstrom_2] = ...
    wip.interpret('Space', '(Å)', '(µm)', X_um); % Direct conversion from µm to Å
[XLengthUnit_angstrom_nm_2, XLength_angstrom_2] = ...
    wip.interpret('Space', '(Å)', C_Info.XUnit, C_Info.XLength); % A slightly more generic than previous line.

% Temporarily change SpectralUnit of Graph-axis (== 3rd dimension of C.Data)
Graph_nm = C_Info.Graph; % = C.interpret_Graph(); % Get the internal input
Graph_meV = C.interpret_Graph('(meV)', Graph_nm); % Convert the EXTERNAL input == Graph_nm to new units
Graph_Raman = C.interpret_Graph('(rel. 1/cm)'); % Convert the INTERNAL input == Info.Graph to new units

% MANUAL: Same as above but behind the scenes revealed
[GraphUnit_meV_2, Graph_meV_2] = ...
    wip.interpret('Spectral', '(meV)', '(nm)', Graph_nm); % Direct conversion from nm to meV
[GraphUnit_Raman_2, Graph_Raman_2] = ...
    wip.interpret(C_Info.GraphInterpretation, '(rel. 1/cm)', C_Info.GraphUnit, C_Info.Graph); % More generic than previous line, assuming that C_Info.GraphInterpretation exists (as it usually does for Graph-axis).
%-------------------------------------------------------------------------%


