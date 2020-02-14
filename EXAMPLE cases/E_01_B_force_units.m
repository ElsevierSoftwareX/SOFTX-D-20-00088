% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO EXAMPLE CASE 1 B: FORCING UNITS
% Simple examples of (E1B i-iv.) forcing of the content units on the fly.

clear all; % Clear workspace
close all; % Close figures

% Example file
pathstr = fileparts([mfilename('fullpath') '.m']); % Get folder of this script
file = fullfile(pathstr, 'E_v5.wip'); % Construct full path of the example file
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'EXAMPLE CASE 1 B: FORCING UNITS' ...
    '' ...
    '* Using ''E_v5.wip'' WITec Project -file, which has Raman data from exfoliated graphene with 1-, 2- and 3-layer areas on 285 nm SiO2/Si-substrate.' ...
    '' ...
    '* Please note that MOST of this ''wit_io'' code is OPEN-SOURCED under simple and permissive BSD 3-Clause License and is FREE-TO-USE like described in LICENSE.txt!'});
if ishandle(h), figure(h); uiwait(h); end % Wait for helpdlg to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'!!! (E1B) The imported content units (DataUnit, SpaceUnit, SpectralUnit and TimeUnit) may be modified upon loading:' ...
    '' ...
    '!!! (E1B i.) by adding parameter pairs to wip.read as below:' ...
    '[...] = wip.read(..., ''-DataUnit'', ''Counts'', ''-SpaceUnit'', ''(µm)'', ''-SpectralUnit'', ''(nm)'', ''-TimeUnit'', ''(s)'');' ...
    '' ...
    '!!! (E1B ii.) by specifying the units in the bottom of the opened Project Manager GUI.' ...
    '' ...
    '!!! (E1B iii.) by modifying O_wip-object ForceDataUnit, ForceSpaceUnit, ForceSpectralUnit and ForceTimeUnit:' ...
    'O_wip.ForceDataUnit = ''Counts'';' ...
    'O_wip.ForceSpaceUnit = ''(µm)'';' ...
    'O_wip.ForceSpaceUnit = ''(um)''; % Same as above!' ...
    'O_wip.ForceSpectralUnit = ''(nm)'';' ...
    'O_wip.ForceTimeUnit = ''(s)'';' ...
    '' ...
    'Please note that Å''s (U+00C5) and µ''s (U+00B5) can be replaced by A''s u''s.' ...
    '' ...
    '!!! (E1B iv.) temporarily using wip.interpret (or easier wid-class interpret_X, interpret_Y, interpret_Z, interpret_Graph member-functions).' ...
    '' ...
    '* Read the code for more details.' ...
    '' ...
    '* Close this to END.'});
if ishandle(h), figure(h); uiwait(h); end % Wait for helpdlg to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% !!! (E1B i.) Enforce units via wip.read extra parameters:
% Extra parameters '-DataUnit', '-SpaceUnit', '-SpectralUnit' and
% '-TimeUnit' can be specified (in any order) to override the original
% corresponding units. For '-DataUnit', the input can be a string (new name
% of the Unit). For others, the input can be an integer (UnitIndex) or a
% search string.
[O_wid, O_wip, O_wid_HtmlNames] = wip.read(file, '-all', ...
    '-DataUnit', 'Counts', ... % Can be a string
    '-SpaceUnit', '(um)', ... % Can be an integer (0-5) or a search string
    '-SpectralUnit', '(nm)', ... % Can be an integer (0-7) or a search string
    '-TimeUnit', '(s)'); % Can be an integer (0-7) or a search string
% Try above without '-all' to see the specified units in Project Manager.
% Try search strings interactively in the bottom of the opened GUI window!

O_ImageScan = O_wid(3); % Get object of "Reduced<Image Scan 1 (Data)" at index 3



% !!! (E1B iii.) Enforce units as post-processing step
O_wip.ForceSpaceUnit = ''; % Remove the SpaceUnit enforcement and use the original units!
O_wip.ForceSpaceUnit = 'Invalid unit'; % But will result in '' and hence does the same as above!
O_wip.ForceSpaceUnit = 'Micrometers (µm)'; % Set SpaceUnit to µm by its full name (seen from full list of wip.FullStandardUnits)
O_wip.ForceSpaceUnit = 'Micro'; % Does the same as above, effectively using strfind-functionality
O_wip.ForceSpaceUnit = '(µm)'; % Does the same as above
O_wip.ForceSpaceUnit = '(um)'; % Does the same as above

% Please note that Å''s (U+00C5) and µ''s (U+00B5) can be replaced by A''s u''s.

% figure; O_ImageScan.plot; % (µm) as x- and y-axes
% O_wip.ForceSpaceUnit = 'Ångströms (Å)';
% O_wip.ForceSpaceUnit = '(Å)'; % Does the same as above
% O_wip.ForceSpaceUnit = '(A)'; % Does the same as above
% figure; O_ImageScan.plot; % (Å) as x- and y-axes



% !!! (E1B iv.) Temporarily alter units via wip.interpret:
O_ImageScan_Info = O_ImageScan.Info; % Load its READ-ONLY Info-struct only once, because its function call can be time consuming.
% * Double-click O_ImageScan_Info in Workspace to see its full contents!

% Temporarily change SpaceUnit of X-axis (== 1st dimension of C.Data)
X_um = O_ImageScan_Info.X; % = O_ImageScan.interpret_X(); % Get the internal input
XLength_um = O_ImageScan_Info.XLength; % Get the internal input
X_angstrom = O_ImageScan.interpret_X('(Å)'); % Convert the INTERNAL input == Info.X to new units
XLength_angstrom = O_ImageScan.interpret_X('(Å)', O_ImageScan_Info.XLength); % Convert the EXTERNAL input == O_ImageScan_Info.XLength to new units

% MANUAL: Same as above but behind the scenes revealed
[XUnit_angstrom_2, X_angstrom_2] = ...
    wip.interpret('Space', '(Å)', '(µm)', X_um); % Direct conversion from µm to Å
[XLengthUnit_angstrom_nm_2, XLength_angstrom_2] = ...
    wip.interpret('Space', '(Å)', O_ImageScan_Info.XUnit, O_ImageScan_Info.XLength); % A slightly more generic than previous line.

% Temporarily change SpectralUnit of Graph-axis (== 3rd dimension of O_ImageScan.Data)
Graph_nm = O_ImageScan_Info.Graph; % = O_ImageScan.interpret_Graph(); % Get the internal input
Graph_meV = O_ImageScan.interpret_Graph('(meV)', Graph_nm); % Convert the EXTERNAL input == Graph_nm to new units
Graph_Raman = O_ImageScan.interpret_Graph('(rel. 1/cm)'); % Convert the INTERNAL input == Info.Graph to new units

% MANUAL: Same as above but behind the scenes revealed
[GraphUnit_meV_2, Graph_meV_2] = ...
    wip.interpret('Spectral', '(meV)', '(nm)', Graph_nm); % Direct conversion from nm to meV
[GraphUnit_Raman_2, Graph_Raman_2] = ...
    wip.interpret(O_ImageScan_Info.GraphInterpretation, '(rel. 1/cm)', O_ImageScan_Info.GraphUnit, O_ImageScan_Info.Graph); % More generic than previous line, assuming that O_ImageScan_Info.GraphInterpretation exists (as it usually does for Graph-axis).
%-------------------------------------------------------------------------%


