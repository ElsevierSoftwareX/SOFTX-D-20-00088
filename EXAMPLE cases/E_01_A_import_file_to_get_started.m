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
wit_io_license;

h = wit_io_msgbox({'{\bf\fontsize{12}\color{magenta}EXAMPLE CASE 1 A:}' ...
    '{\bf\fontsize{12}FILE IMPORTING TO GET STARTED}' ...
    '' ...
    '\bullet Using ''E\_v5.wip'' WITec Project -file, which has Raman data from exfoliated graphene with 1-, 2- and 3-layer areas on 285 nm SiO2/Si-substrate.'});
if ishandle(h), figure(h); uiwait(h); end % Wait for wit_io_msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
wit_io_msgbox({'{\bf\fontsize{12}{\color{magenta}(E1A i.)} Load and browse file contents in a GUI by executing:}' ...
    '' ...
    '{\bf\fontname{Courier}[O\_wid, O\_wip, O\_wid\_HtmlNames] = wip.read(file);}' ...
    '' ...
    '\bullet It opens the file in a Project Manager -window, listing only the plottable data types (TDBitmap, TDGraph, TDImage, TDText). Non-plottable data types, such as TDInterpretation and TDTransformation, are hidden by default, but can be made visible by adding {\bf\fontname{Courier}''-Manager''}, {\bf\fontname{Courier}''--all''} as an extra input pair.' ...
    '' ...
    '\bullet A preview window is normally opened for each selected list item. Multiple items may be left-mouse selected one-by-one by holding Ctrl. Alternatively, a range of items may be selected by holding Shift.' ...
    '' ...
    '\bullet Upon closing the Project Manager -window, it will return the selected data and their Html-names as {\bf\fontname{Courier}O\_wid} and {\bf\fontname{Courier}O\_wid\_HtmlNames}, respectively. Project is returned as {\bf\fontname{Courier}O\_wip}. Read comments in these examples for better understanding of these output variables.' ...
    '' ...
    '\bullet Click any item to open a preview window (by default). Also, clicking the opened preview window may open a subpreview window, when data has third dimension like a spectrum per pixel. For example, see ''Reduced<Image Scan 1 (Data)''. Please note that you may also use arrow keys to move in images.' ...
    '' ...
    '\ldots Close the opened Project Manager -window to continue...'});
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% This opens the specified file in a Project Manager -window.
[O_wid, O_wip, O_wid_HtmlNames] = wip.read(file); % (1A) Browse the file contents

% '-Manager'-option with single-dashed options require enclosing by
% {}-brackets:
% [O_wid, O_wip, O_wid_HtmlNames] = wip.read(file, '-Manager', {'-all'}); % To show also the non-plottable data

% The single-dashed options can be replaced by double-dashed options and
% passed on via '-Manager'-option without {}-brackets:
% [O_wid, O_wip, O_wid_HtmlNames] = wip.read(file, '-Manager', '--all'); % To show also the non-plottable data
% [O_wid, O_wip, O_wid_HtmlNames] = wip.read(file, '-Manager', '--Type', 'TDGraph'); % To show only TDGraphs
% [O_wid, O_wip, O_wid_HtmlNames] = wip.read(file, '-Manager', '--Type', 'TDGraph', '--SubType', 'Image'); % To show only Image<TDGraphs
% [O_wid, O_wip, O_wid_HtmlNames] = wip.read(file, '-Manager', '--Type', 'TDBitmap', 'TDGraph', 'TDImage', '--SubType', '', 'Image', ''); % To show only TDBitmap, Image<TDGraphs and TDImage

% * Other possible '-Manager' options are '-singlesection', '-nopreview',
% '-closepreview', '-nomanager', '-Title', '-Type' and '-SubType'. Make
% them double-dashed like above if passing on without {}-brackets!
% It is noted that each input for '-Type' can have a corresponding input for
% '-SubType' or vice versa! Any missing input is set to empty char array.

% !!! Meaning of the OUTPUT variables:
%
% * O_wid:
% Selected datas loaded as WID-class objects. Each object has the following
% properties Type, Name, Data, Info, DataTree, Version, Id, ImageIndex,
% OrdinalNumber, SubType, LinksToOthers, AllLinksToOthers, LinksToThis,
% AllLinksToThis, Tag and Project. To see these, double-click O_wid under
% Workspace to see each of these. Code interprets these from the loaded
% file WIT-node tree structure.
%
% * O_wip:
% Resulting project loaded as WIP-class object. Its properties are File,
% Version, Data, Tree, ForceDataUnit, ForceSpaceUnit, ForceSpectralUnit,
% ForceTimeUnit, UseLineValid, AutoCreateObj, AutoCopyObj, AutoModifyObj,
% FullStandardUnits, ArbitraryUnit, DefaultSpaceUnit, DefaultSpectralUnit
% and DefaultTimeUnit.
%
% * O_wid_HtmlNames:
% The Html names of the selected datas. Double-click O_wid_HtmlNames under
% Workspace to see these (and rescale the 1st column by holding left-mouse
% on the border between 1 and 2). This is useful feature, when loading a
% lot of data at once. Alternatively, call 'O_wid.manager;' to open
% selected WID-class objects in Project Manager view.
%-------------------------------------------------------------------------%



close all; % Close all windows before continuing



%-------------------------------------------------------------------------%
h = wit_io_msgbox({'{\bf\fontsize{12}{\color{magenta}(E1A ii.)} OR, load all file contents without GUI by executing:}' ...
    '' ...
    '{\bf\fontname{Courier}[...] = wip.read(file, ''-all'');}' ...
    '' ...
    '{\bf\fontsize{12}{\color{magenta}(E1A iii.)} OR, specify ''-ifall'' to ask whether to browse or load the content:}' ...
    '' ...
    '{\bf\fontname{Courier}[...] = wip.read(file, ''-ifall'');}' ...
    '' ...
    '{\bf\fontsize{12}{\color{magenta}(E1A iv.)} OR, load by browsing file system for WITec Project/Data (*.wip/*.wid) -files by executing:}' ...
    '' ...
    '{\bf\fontname{Courier}[...] = wip.read();}' ...
    '' ...
    '\bullet Read the code for more details.' ...
    '' ...
    '\ldots Close this to END.'});
if ishandle(h), figure(h); uiwait(h); end % Wait for wit_io_msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% This opens the specified file. Then automatically loads all.
% [O_wid, O_wip, O_wid_HtmlNames] = wip.read(file, '-all'); % (1B) Load all file content
% [O_wid, O_wip, O_wid_HtmlNames] = wip.read(file, '-ifall'); % (1C) Ask whether to browse or load the file content
% [O_wid, O_wip, O_wid_HtmlNames] = wip.read(); % (1D) Browse the file system
%-------------------------------------------------------------------------%


