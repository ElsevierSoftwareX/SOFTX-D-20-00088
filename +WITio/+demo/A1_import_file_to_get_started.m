% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO DEMO CASE A 1: FILE IMPORTING TO GET STARTED
% Simple examples of (A1 i-iv.) file importing to get started. This calls WITio.obj.wip.read
% under '@wip'-folder to load WITec Project/Data (*.wip/*.wid) -files
% directly to the MATLAB environment without manual exporting/importing.

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

h = WITio.tbx.msgbox({'{\bf\fontsize{12}\color{magenta}DEMO CASE A1:}' ...
'{\bf\fontsize{12}FILE IMPORTING TO GET STARTED}' ...
'' ...
'\bullet Using ''A\_v5.wip'' WITec Project -file, which has Raman data from ' ...
'exfoliated graphene with 1-, 2- and 3-layer areas on 285 nm ' ...
'SiO2/Si-substrate.'}, '-TextWrapping', false);
WITio.tbx.uiwait(h); % Wait for WITio.tbx.msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
WITio.tbx.msgbox({'{\bf\fontsize{12}{\color{magenta}(A1 i.)} Load and browse file contents in a GUI by ' ...
'executing:}' ...
'' ...
'{\bf\fontname{Courier}[O\_wid, O\_wip, O\_wit] = WITio.read(file);}' ...
'' ...
'\bullet It opens the file in a Project Manager -window, listing only the plottable data types ' ...
'(TDBitmap, TDGraph, TDImage, TDText). Non-plottable data types, such as ' ...
'TDInterpretation and TDTransformation, are hidden by default, but can be made ' ...
'visible by adding {\bf\fontname{Courier}''-Manager''}, {\bf\fontname{Courier}''--all''} as an extra input pair.' ...
'' ...
'\bullet A preview window is normally opened for each selected list item. Multiple items ' ...
'may be left-mouse selected one-by-one by holding Ctrl. Alternatively, a range of ' ...
'items may be selected by holding Shift.' ...
'' ...
'\bullet Upon closing the Project Manager -window, it will return the selected data, their ' ...
'projects and the underlying trees as {\bf\fontname{Courier}O\_wid}, {\bf\fontname{Courier}O\_wip} and {\bf\fontname{Courier}O\_wit}, respectively. Read ' ...
'comments in these examples for better understanding of these output variables.' ...
'' ...
'\bullet Click any item to open a preview window (by default). Also, clicking the opened ' ...
'preview window may open a subpreview window, when data has third dimension like ' ...
'a spectrum per pixel. For example, see ''Reduced<Image Scan 1 (Data)''. Please note ' ...
'that you may also use arrow keys to move in images.' ...
'' ...
'\ldots Close the opened Project Manager -window to continue...'}, '-TextWrapping', false);
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% This opens the specified file in a Project Manager -window.
[O_wid, O_wip, O_wit] = WITio.read(file); % (1A) Browse the file contents

% '-Manager'-option with single-dashed options require enclosing by
% {}-brackets:
% [O_wid, O_wip, O_wit] = WITio.read(file, '-Manager', {'-all'}); % To show also the non-plottable data

% The single-dashed options can be replaced by double-dashed options and
% passed on via '-Manager'-option without {}-brackets:
% [O_wid, O_wip, O_wit] = WITio.read(file, '-Manager', '--all'); % To show also the non-plottable data
% [O_wid, O_wip, O_wit] = WITio.read(file, '-Manager', '--Type', 'TDGraph'); % To show only TDGraphs
% [O_wid, O_wip, O_wit] = WITio.read(file, '-Manager', '--Type', 'TDGraph', '--SubType', 'Image'); % To show only Image<TDGraphs
% [O_wid, O_wip, O_wit] = WITio.read(file, '-Manager', '--Type', 'TDBitmap', 'TDGraph', 'TDImage', '--SubType', '', 'Image', ''); % To show only TDBitmap, Image<TDGraphs and TDImage

% * Other possible '-Manager' options are '-singlesection', '-nopreview',
% '-closepreview', '-nomanager', '-Title', '-Type' and '-SubType'. Make
% them double-dashed like above if passing on without {}-brackets!
% It is noted that each input for '-Type' can have a corresponding input for
% '-SubType' or vice versa! Any missing input is set to empty char array.

% !!! Meaning of the OUTPUT variables:
%
% * O_wid:
% Selected datas loaded as wid Data objects. Each object has the following
% properties File, Name, Data, Type, Version, Info, DataTree, Id,
% ImageIndex, OrdinalNumber, SubType, LinksToOthers, AllLinksToOthers,
% LinksToThis, AllLinksToThis, Tag and Project. To see these, double-click
% O_wid under Workspace to see each of these. Code interprets these from
% the loaded file WIT-node tree structure.
%
% * O_wip:
% Resulting project loaded as wip Project object. Its properties are File,
% Name, Data, Type, Version, Tree, ForceDataUnit, ForceSpaceUnit,
% ForceSpectralUnit, ForceTimeUnit, AutoCopyObj, AutoCreateObj,
% AutoModifyObj, AutoNanInvalid, AutoDestroyDuplicateTransformations,
% AutoDestroyViewers, FullStandardUnits, ArbitraryUnit, DefaultSpaceUnit,
% DefaultSpectralUnit, DefaultTimeUnit and Projects.
%
% * O_wit:
% Underlying tree loaded as wit Tree object. Its properties are File Name,
% Data, Type, Parent, Children, Root, Siblings, Next, Prev, FullName,
% Magic, Listeners, PropListeners, ModifiedCount,
% ModifiedDescendantProperty, ModifiedDescendantMeta,
% ModifiedDescendantIndices, ModifiedDescendantIds, ModifiedEvents,
% OrdinalNumber and Id.
%
% The simplest way to quickly and visually inspect the O_wid or O_wip array
% contents in a Project Manager view is to execute either 'O_wid.manager;'
% or 'O_wip.manager;' in Command Window below.
%-------------------------------------------------------------------------%



close all; % Close all windows before continuing



%-------------------------------------------------------------------------%
h = WITio.tbx.msgbox({'{\bf\fontsize{12}{\color{magenta}(A1 ii.)} OR, load all file contents without GUI by executing:}' ...
'' ...
'{\bf\fontname{Courier}[...] = WITio.read(file, ''-all'');}' ...
'' ...
'{\bf\fontsize{12}{\color{magenta}(A1 iii.)} OR, specify ''-ifall'' to ask whether to browse or load ' ...
'the content:}' ...
'' ...
'{\bf\fontname{Courier}[...] = WITio.read(file, ''-ifall'');}' ...
'' ...
'{\bf\fontsize{12}{\color{magenta}(A1 iv.)} OR, load by browsing file system for WITec ' ...
'Project/Data (*.wip/*.wid) -files by executing:}' ...
'' ...
'{\bf\fontname{Courier}[...] = WITio.read();}' ...
'' ...
'\bullet Read the code for more details.' ...
'' ...
'\ldots Close this to END.'}, '-TextWrapping', false);
WITio.tbx.uiwait(h); % Wait for WITio.tbx.msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% This opens the specified file. Then automatically loads all.
% [O_wid, O_wip, O_wit] = WITio.read(file, '-all'); % (1B) Load all file content
% [O_wid, O_wip, O_wit] = WITio.read(file, '-ifall'); % (1C) Ask whether to browse or load the file content
% [O_wid, O_wip, O_wit] = WITio.read(); % (1D) Browse the file system
%-------------------------------------------------------------------------%

% Reset user preferences
clear resetOnCleanup; % The original values are restored here.


