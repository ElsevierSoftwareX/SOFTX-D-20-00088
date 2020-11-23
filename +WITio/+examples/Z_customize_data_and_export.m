% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO EXAMPLE CASE Z: CUSTOMIZE DATA AND EXPORT
% Illustrating the creation of Project, its customized objects and writing
% to a new file. Customized object examples for TDBitmap, Image<TDGraph,
% TDImage and TDText datatypes (and some related transformations and
% interpretations). The created WIP-file can then be opened in WITec's
% external softwares.

WITio.tbx.edit(); % Open this code in Editor
close all; % Close figures

% Example file
pathstr = fullfile(WITio.tbx.path.package, '+examples'); % Get folder of this script
file = fullfile(pathstr, 'A_v5.wip'); % Construct full path of the example file



%-------------------------------------------------------------------------%
WITio.tbx.license;

h = WITio.tbx.msgbox({'{\bf\fontsize{12}\color{magenta}EXAMPLE CASE Z:}' ...
'{\bf\fontsize{12}CUSTOMIZE DATA AND ' ...
'EXPORT}' ...
'' ...
'\bullet If unfamiliar with ''WITio'', then go through the previous ' ...
'examples first.'}, '-TextWrapping', false);
WITio.tbx.uiwait(h); % Wait for WITio.tbx.msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Create new Project objects
Version = 5; % Use version 5 here for forward-compability. For instance, WITec Project 2.1.
O_wit = WITio.obj.wip.new(Version); % Create new Project (*.WIP-format) WIT-tree root
% O_wit = WITio.obj.wid.new(Version); % Create new Project (*.WID-format) WIT-tree root
O_wip = WITio.obj.wip(O_wit); % Create its Project object

% Or uncomment below to alternatively append to old Project objects
% [~, O_wip, ~] = WITio.read(file, '-all'); % Load all
% O_wit = O_wip.Tree; % Get its underlying WIT-tree
% Version = O_wip.Version; % Get file WIT-tree version
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Create new TDBitmap with random content
new_TDBitmap = WITio.obj.wid.new_Bitmap(O_wit); % Create empty TDBitmap
new_TDBitmap.Name = 'Customized TDBitmap';

% Create customized Data
SizeX_TDBitmap = 100; % X-axis is always the 1st dimension of the wid object Data property!
SizeY_TDBitmap = 200; % Y-axis is always the 2nd dimension of the wid object Data property!
SizeGraph_TDBitmap = 3; % = 3 for the RGB channels. Graph-axis is always the 3rd dimension of the wid object Data property!
Data = randi(256, [SizeX_TDBitmap SizeY_TDBitmap SizeGraph_TDBitmap])-1; % Uniformly-distributed values from 0-255

% Set new Data (and its SizeX and SizeY parameters)
new_TDBitmap.Data = Data;

% Create customized transformations and interpretations
new_TDBitmap_TSpace = WITio.obj.wid.new_Transformation_Space(O_wit);
% Read TDSpaceTransformation details in 'README on WIT-tag formatting.txt'.

% Add links to transformations and interpretations
new_TDBitmap_Tag_Data = new_TDBitmap.Tag.Data; % Required by R2011a
new_TDBitmap_Tag_Data.regexp('^SpaceTransformationID<TDBitmap<', true).Data = new_TDBitmap_TSpace.Id; % Must be int32! (Required by WITec software)
% new_TDBitmap_Tag_Data.regexp('^SecondaryTransformationID<TDBitmap<', true).Data = int32(0); % (v7) % Must be int32!

% These were AUTOMATICALLY added to the wip Project object!
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Create new Image<TDGraph with random content
new_TDGraph = WITio.obj.wid.new_Graph(O_wit); % Create empty Image<TDGraph
% new_TDGraph.SubType = 'Image'; % Set its ImageIndex
% SubTypes are listed in @wid\wid_SubType_set.m and are as follows:
% 'Image', 'Line', 'Point', 'Array', 'Histogram', 'Time' and 'Mask'

new_TDGraph.Name = 'Customized Image<TDGraph';

% Create customized Data
DataUnit = WITio.obj.wip.ArbitraryUnit;
SizeX = 10; % X-axis is always the 1st dimension of the wid object Data property!
SizeY = 20; % Y-axis is always the 2nd dimension of the wid object Data property!
SizeGraph = 30; % Graph-axis is always the 3rd dimension of the wid object Data property!
Data_TDGraph = randn(SizeX, SizeY, SizeGraph); % Data with DataUnit!



% new_TDGraph.SubType = 'Point'; % Makes sense only if SizeX == SizeY == 1
% Data_TDGraph = permute(Data_spectrum(:), [2 3 1]); % Make a data vector (spectrum) a data cube (X, Y, spectrum)



% new_TDGraph.SubType = 'Line'; % Makes sense only if SizeY == 1
% Data_TDGraph = permute(Data_X_spectrum, [1 3 2]); % Make a data matrix (X, spectrum) a data cube (X, Y, spectrum) 
% % Data_TDGraph = permute(Data_spectrum_X, [2 3 1]); % Make a data matrix (spectrum, X) a data cube (X, Y, spectrum)



% Set new Data (and its SizeX, SizeY and SizeGraph parameters)
new_TDGraph.Data = Data_TDGraph;

% Create customized Graph-axis (Data's 3rd dimension).
ExcitationWavelength = 532.1; % (nm)
Graph_nm = 530+(1:SizeGraph); % Custom spectral axis
Graph_nm = Graph_nm + randn(size(Graph_nm)); % Add gaussian noise to spectral axis
% IMPORTANT: Its SpectralUnit is ALWAYS WITio.obj.wip.interpret_StandardUnit('nm')
% due to the way TDSpectralTransformation was implemented by WITec.
% In other words, Graph with non-'nm' SpectralUnit must first be converted
% to Graph with 'nm' SpectralUnit! It can be done as follows:
% [~, Graph_nm] = WITio.obj.wip.interpret({'Spectral', ExcitationWavelength}, '(nm)', '(meV)', Graph_meV); % Direct conversion from meV to nm. Here ExcitationWavelength's extra input is only used when converting from relative units.

% Create customized transformations and interpretations
new_TDGraph_TSpace = WITio.obj.wid.new_Transformation_Space(O_wit);
% Read TDSpaceTransformation details in 'README on WIT-tag formatting.txt'.

new_TDGraph_TSpectral = WITio.obj.wid.new_Transformation_LUT(O_wit);
new_TDGraph_TSpectral_Data = new_TDGraph_TSpectral.Data; % Get formatted struct once to speed-up
new_TDGraph_TSpectral_Data.TDLUTTransformation.LUT = Graph_nm; % Its SpectralUnit is always (nm) under the hood until interpreted to other kind!
new_TDGraph_TSpectral_Data.TDLUTTransformation.LUTSize = numel(Graph_nm); % Ignored by WITio, but used in WITec software
new_TDGraph_TSpectral_Data.TDLUTTransformation.LUTIsIncreasing = false; % Ignored by WITio, but used in WITec software
new_TDGraph_TSpectral.Data = new_TDGraph_TSpectral_Data; % Save all changes once
% Read TDLUTTransformation details in 'README on WIT-tag formatting.txt'.

% Interpret Graph-variable (nm) as (rel. 1/cm)
new_TDGraph_ISpectral = WITio.obj.wid.new_Interpretation_Spectral(O_wit);
new_TDGraph_ISpectral.Data.TDSpectralInterpretation.ExcitationWaveLength = ExcitationWavelength; % Green laser
new_TDGraph_ISpectral.Data.TDInterpretation.UnitIndex = 3; % (rel. 1/cm)
% UnitIndex (TDInterpretation<TDSpectralInterpretation)
% 0 = nm, 1 = µm, 2 = 1/cm, 3 = rel. 1/cm, 4 = eV, 5 = meV, 6 = rel. eV, 7 = rel. meV, >7 = a.u. (but in nm)
% Read other UnitIndex details in 'README on WIT-tag formatting.txt'

% Or interpret it as customized unit
% GraphUnit = 'Randomized spectral axis unit'; % Custom spectral axis unit name
% new_TDGraph_ISpectral = WITio.obj.wid.new_Interpretation_Z(O_wit);
% new_TDGraph_ISpectral.Data.TDZInterpretation.UnitName = GraphUnit;
% Read TDZInterpretation details in 'README on WIT-tag formatting.txt'.

new_TDGraph_IData = WITio.obj.wid.new_Interpretation_Z(O_wit);
new_TDGraph_IData.Data.TDZInterpretation.UnitName = DataUnit;
% Read TDZInterpretation details in 'README on WIT-tag formatting.txt'.

% Add links to transformations and interpretations
new_TDGraph_Tag_Data = new_TDGraph.Tag.Data; % Required by R2011a
new_TDGraph_Tag_Data.regexp('^SpaceTransformationID<TDGraph<', true).Data = new_TDGraph_TSpace.Id; % Must be int32!
% new_TDGraph_Tag_Data.regexp('^SecondaryTransformationID<TDGraph<', true).Data = int32(0); % (v7) % Must be int32!
new_TDGraph_Tag_Data.regexp('^XTransformationID<TDGraph<', true).Data = new_TDGraph_TSpectral.Id; % Must be int32!
new_TDGraph_Tag_Data.regexp('^XInterpretationID<TDGraph<', true).Data = new_TDGraph_ISpectral.Id; % Must be int32!
new_TDGraph_Tag_Data.regexp('^ZInterpretationID<TDGraph<', true).Data = new_TDGraph_IData.Id; % Must be int32!

% These were AUTOMATICALLY added to the wip Project object!
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Create new TDImage with random content
new_TDImage = WITio.obj.wid.new_Image(O_wit); % Create empty TDImage
new_TDImage.Name = 'Customized TDImage';

% Create customized Data
DataUnit_TDImage = 'TDImage a.u.';
SizeX_TDImage = 100; % X-axis is always the 1st dimension of the wid object Data property!
SizeY_TDImage = 80; % Y-axis is always the 2nd dimension of the wid object Data property
Data_TDImage = randn(SizeX_TDImage, SizeY_TDImage); % Double

% Set new Data (and its SizeX and SizeY parameters)
new_TDImage.Data = Data_TDImage;

% Create customized transformations and interpretations
new_TDImage_TSpace = WITio.obj.wid.new_Transformation_Space(O_wit);
% Read TDSpaceTransformation details in 'README on WIT-tag formatting.txt'.

new_TDImage_IData = WITio.obj.wid.new_Interpretation_Z(O_wit);
new_TDImage_IData.Data.TDZInterpretation.UnitName = DataUnit_TDImage;
% Read TDZInterpretation details in 'README on WIT-tag formatting.txt'.

% Add links to transformations and interpretations
new_TDImage_Tag_Data = new_TDImage.Tag.Data; % Required by R2011a
new_TDImage_Tag_Data.regexp('^PositionTransformationID<TDImage<', true).Data = new_TDImage_TSpace.Id; % Must be int32!
% new_TDImage_Tag_Data.regexp('^SecondaryTransformationID<TDImage<', true).Data = int32(0); % (v7) % Must be int32!
new_TDImage_Tag_Data.regexp('^ZInterpretationID<TDImage<', true).Data = new_TDImage_IData.Id; % Must be int32!

% These were AUTOMATICALLY added to the wip Project object!
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Create new TDText
new_TDText = WITio.obj.wid.new_Text(O_wit); % Create empty TDText
new_TDText.Name = 'Customized TDText';
new_TDText.Data = {'Customized TDText example:', ''; ...
    '', ''; ...
    'This is seen as a title (in WITec Project).', ''; ...
    'This is not a seen as a title.', ''; ...
    'Property 1:', 'Value 2.'; ...
    'Property 2:', 'Value 4.'};
% These were AUTOMATICALLY added to the wip Project object!
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% O_wip.write(); % Overwrite the original

O_wip.write('Z_customize_data_and_export.wip'); % Write Project to the specified file

O_wip.manager('-all', '-closepreview'); % Show the newly created Project
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = WITio.tbx.msgbox({'{\bf\fontsize{12}{\color{magenta}(Z)} Customizing data and exporting:}' ...
'' ...
'\bullet In this advanced example, customized TDBitmap, TDGraph, TDImage and ' ...
'TDText were created and exported to a file. See the generated data in the ' ...
'opened Project Manager.' ...
'' ...
'\ldots Close this dialog to END and close all the opened figures.'}, '-TextWrapping', false);
WITio.tbx.uiwait(h); % Wait for WITio.tbx.msgbox to be closed before continuing.
close all;
%-------------------------------------------------------------------------%


