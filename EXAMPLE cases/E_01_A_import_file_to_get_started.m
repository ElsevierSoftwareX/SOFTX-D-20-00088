% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO EXAMPLE CASE 1 A: FILE IMPORTING TO GET STARTED
% Simple examples of (E1A i-iv.) file importing to get started. This calls wip.read
% under '@wip'-folder to load WITec Project/Data (*.wip/*.wid) -files
% directly to the MATLAB environment without manual exporting/importing.

clear all; % Clear workspace
close all; % Close figures

% Example file
pathstr = fileparts([mfilename('fullpath') '.m']); % Get folder of this script
file = fullfile(pathstr, 'E_v5.wip'); % Construct full path of the example file
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'EXAMPLE CASE 1 A: FILE IMPORTING TO GET STARTED' ...
    '' ...
    '* Using ''E_v5.wip'' WITec Project -file, which has Raman data from exfoliated graphene with 1-, 2- and 3-layer areas on 285 nm SiO2/Si-substrate.' ...
    '' ...
    '* Please note that MOST of this ''wit_io'' code is OPEN-SOURCED under simple and permissive BSD 3-Clause License and is FREE-TO-USE like described in LICENSE.txt!'});
if ishandle(h), figure(h); uiwait(h); end % Wait for helpdlg to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
helpdlg({'!!! (E1A i.) Load and browse file contents in a GUI by executing:' ...
    '[O_wid, O_wip, O_HtmlNames] = wip.read(file);' ...
    '' ...
    '* It opens the file in a Project Manager -window, listing only the plottable data types (TDBitmap, TDGraph, TDImage, TDText). Non-plottable data types, such as TDInterpretation and TDTransformation, are hidden by default, but can be made visible by adding ''-Manager'', {''-all''} as an extra input pair.' ...
    '' ...
    '* A preview window is normally opened for each selected list item. Multiple items may be left-mouse selected one-by-one by holding Ctrl. Alternatively, a range of items may be selected by holding Shift.' ...
    '' ...
    '* Upon closing the Project Manager -window, it will return the selected data and their Html-names as O_wid and O_HtmlNames, respectively. Project is returned as O_wip. Read comments in these examples for better understanding of these output variables.' ...
    '' ...
    '* Click any item to open a preview window (by default). Also, clicking the opened preview window may open a subpreview window, when data has third dimension like a spectrum per pixel. For example, see ''Reduced<Image Scan 1 (Data)''. Please note that you may also use arrow keys to move in images.' ...
	'' ...
	'!!! Close the opened Project Manager -window to continue...'});
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% This opens the specified file in a Project Manager -window.
[O_wid, O_wip, O_HtmlNames] = wip.read(file); % (1A) Browse the file contents

% [O_wid, O_wip, O_HtmlNames] = wip.read(file, '-Manager', {'-all'}); % To show also the non-plottable data
% [O_wid, O_wip, O_HtmlNames] = wip.read(file, '-Manager', {'-Type', 'TDGraph'}); % To show only TDGraphs
% [O_wid, O_wip, O_HtmlNames] = wip.read(file, '-Manager', {'-Type', {'TDBitmap', 'TDGraph', 'TDImage'}}); % To show only TDBitmap, TDGraphs and TDImage
% * Other possible '-Manager' options are '-singlesection', '-nopreview',
% '-closepreview', '-nomanager', '-Title', '-Type' and '-SubType'.

% !!! Meaning of the OUTPUT variables:
%
% * O_wid:
% Selected datas loaded as WID-class objects. Each object has the following
% properties Type, Name, Data, Info, DataTree, Version, Id, ImageIndex,
% OrdinalNumber, SubType, Links, AllLinks, Tag and Project. To see these,
% double-click O_wid under Workspace to see each of these. Code interprets
% these from the loaded file WIT-node tree structure.
%
% * O_wip:
% Resulting project loaded as WIP-class object. Its properties are File,
% Version, Data, Tree, ForceDataUnit, ForceSpaceUnit, ForceSpectralUnit,
% ForceTimeUnit, UseLineValid, AutoCreateObj, AutoCopyObj, AutoModifyObj,
% FullStandardUnits, ArbitraryUnit, DefaultSpaceUnit, DefaultSpectralUnit
% and DefaultTimeUnit.
%
% * O_HtmlNames:
% The Html names of the selected datas. Double-click O_HtmlNames under
% Workspace to see these (and rescale the 1st column by holding left-mouse
% on the border between 1 and 2). This is useful feature, when loading a
% lot of data at once.
%-------------------------------------------------------------------------%



close all; % Close all windows before continuing



%-------------------------------------------------------------------------%
h = helpdlg({'!!! (E1A ii.) OR, load all file contents without GUI by executing:' ...
    '[...] = wip.read(file, ''-all'');' ...
    '' ...
    '!!! (E1A iii.) OR, specify ''-ifall'' to ask whether to browse or load the content:' ...
    '[...] = wip.read(file, ''-ifall'');' ...
    '' ...
    '!!! (E1A iv.) OR, load by browsing file system for WITec Project/Data (*.wip/*.wid) -files by executing:' ...
    '[...] = wip.read();' ...
    '' ...
    '* Read the code for more details.' ...
    '' ...
    '* Close this to END.'});
if ishandle(h), figure(h); uiwait(h); end % Wait for helpdlg to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% This opens the specified file. Then automatically loads all.
% [O_wid, O_wip, O_HtmlNames] = wip.read(file, '-all'); % (1B) Load all file content
% [O_wid, O_wip, O_HtmlNames] = wip.read(file, '-ifall'); % (1C) Ask whether to browse or load the file content
% [O_wid, O_wip, O_HtmlNames] = wip.read(); % (1D) Browse the file system
%-------------------------------------------------------------------------%


