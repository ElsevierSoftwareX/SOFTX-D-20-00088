% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO EXAMPLE 4: WRITE CUSTOMIZED DATA
% Illustrating the creation of Project, its customized objects and writing
% to a new file. Customized object examples for TDBitmap, Image<TDGraph,
% TDImage and TDText datatypes (and some related transformations and
% interpretations). The created WIP-file can then be opened in WITec's
% external softwares.

clear all; % Clear workspace
close all; % Close figures

% Example file
pathstr = fileparts([mfilename('fullpath') '.m']); % Get folder of this script
file = fullfile(pathstr, 'example_v5.wip'); % Construct full path of the example file



%-------------------------------------------------------------------------%
h = helpdlg({'EXAMPLE 4: WRITE CUSTOMIZED DATA' ...
    '' ...
    '* If unfamiliar with ''wit_io'', then go through the previous examples first.' ...
    '' ...
    '* Please note that MOST of this ''wit_io'' code is OPEN-SOURCED under simple and permissive BSD 3-Clause License and is FREE-TO-USE like described in LICENSE.txt!'});
uiwait(h); % Wait for helpdlg to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Create new Project objects
Version = 5; % Use version 5 here for forward-compability
C_wit = wip.new(Version); % Create new Project (*.WIP-format) WIT-tree root
% C_wit = wid.new(Version); % Create new Project (*.WID-format) WIT-tree root
C_wip = wip(C_wit); % Create its Project object

% Or uncomment below to alternatively append to old Project objects
% [~, C_wip, ~] = wip.read(file, '-all'); % Load all
% C_wit = C_wip.Tree; % Get its underlying WIT-tree
% Version = C_wip.Version; % Get file WIT-tree version
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Create new TDBitmap with random content
new_TDBitmap = wid.new_Bitmap(C_wit); % Create empty TDBitmap
new_TDBitmap.Name = 'Customized TDBitmap';

% Create customized Data
Data = randi(256, [100 200 3])-1; % Uniformly-distributed values from 0-255

% Set new Data (and its SizeX and SizeY parameters)
new_TDBitmap.Data = Data;

% Create customized transformations and interpretations
new_TDBitmap_TSpace = wid.new_Transformation_Space(C_wit);
% Read TDSpaceTransformation details in 'README on WIT-tag formatting.txt'.

% Add links to transformations and interpretations
new_TDBitmap.Tag.Data.regexp('^SpaceTransformationID<TDBitmap<', true).Data = new_TDBitmap_TSpace.Id;
% new_TDBitmap.Tag.Data.regexp('^SecondaryTransformationID<TDBitmap<', true).Data = 0; % (v7)

% Append all new objects to Project
C_wip.add_Data(new_TDBitmap, new_TDBitmap_TSpace); % Make new objects visible in Project-object
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Create new Image<TDGraph with random content
new_TDGraph = wid.new_Graph(C_wit); % Create empty Image<TDGraph
% new_TDGraph.SubType = 'Image'; % Set its ImageIndex
% SubTypes are listed in @wid\wid_SubType_set.m and are as follows:
% 'Image', 'Line', 'Point', 'Array', 'Histogram', 'Time' and 'Mask'

new_TDGraph.Name = 'Customized Image<TDGraph';

% Create customized Data
DataUnit = 'TDGraph a.u.';
SizeGraph = 30;
Data_TDGraph = randn(10, 20, SizeGraph); % Double

% Set new Data (and its SizeX, SizeY and SizeGraph parameters)
new_TDGraph.Data = Data_TDGraph;

% Create customized Graph-axis (3rd dimension of Data).
Graph = 530+(1:SizeGraph); % Custom spectral axis
Graph = Graph + randn(size(Graph)); % Add gaussian noise to spectral axis

% Create customized transformations and interpretations
new_TDGraph_TSpace = wid.new_Transformation_Space(C_wit);
% Read TDSpaceTransformation details in 'README on WIT-tag formatting.txt'.

new_TDGraph_TSpectral = wid.new_Transformation_LUT(C_wit);
new_TDGraph_TSpectral_Data = new_TDGraph_TSpectral.Data; % Get formatted struct once to speed-up
new_TDGraph_TSpectral_Data.TDLUTTransformation.LUT = Graph; % Its SpectralUnit is always (nm) under the hood until interpreted to other kind!
new_TDGraph_TSpectral_Data.TDLUTTransformation.LUTSize = numel(Graph); % Ignored by wit_io, but used in WITec software
new_TDGraph_TSpectral_Data.TDLUTTransformation.LUTIsIncreasing = false; % Ignored by wit_io, but used in WITec software
new_TDGraph_TSpectral.Data = new_TDGraph_TSpectral_Data; % Save all changes once
% Read TDLUTTransformation details in 'README on WIT-tag formatting.txt'.

% Interpret Graph-variable (nm) as (rel. 1/cm)
new_TDGraph_ISpectral = wid.new_Interpretation_Spectral(C_wit);
new_TDGraph_ISpectral.Data.TDSpectralInterpretation.ExcitationWaveLength = 532; % Green laser
new_TDGraph_ISpectral.Data.TDInterpretation.UnitIndex = 3; % (rel. 1/cm)
% UnitIndex (TDInterpretation<TDSpectralInterpretation)
% 0 = nm, 1 = µm, 2 = 1/cm, 3 = rel. 1/cm, 4 = eV, 5 = meV, 6 = rel. eV, 7 = rel. meV, >7 = a.u. (but in nm)
% Read other UnitIndex details in 'README on WIT-tag formatting.txt'

% Or interpret it as customized unit
% GraphUnit = 'Randomized spectral axis unit'; % Custom spectral axis unit name
% new_TDGraph_ISpectral = wid.new_Interpretation_Z(C_wit);
% new_TDGraph_ISpectral.Data.TDZInterpretation.UnitName = GraphUnit;
% Read TDZInterpretation details in 'README on WIT-tag formatting.txt'.

new_TDGraph_IData = wid.new_Interpretation_Z(C_wit);
new_TDGraph_IData.Data.TDZInterpretation.UnitName = DataUnit;
% Read TDZInterpretation details in 'README on WIT-tag formatting.txt'.

% Add links to transformations and interpretations
new_TDGraph.Tag.Data.regexp('^SpaceTransformationID<TDGraph<', true).Data = new_TDGraph_TSpace.Id;
% new_TDGraph.Tag.Data.regexp('^SecondaryTransformationID<TDGraph<', true).Data = 0; % (v7)
new_TDGraph.Tag.Data.regexp('^XTransformationID<TDGraph<', true).Data = new_TDGraph_TSpectral.Id;
new_TDGraph.Tag.Data.regexp('^XInterpretationID<TDGraph<', true).Data = new_TDGraph_ISpectral.Id;
new_TDGraph.Tag.Data.regexp('^ZInterpretationID<TDGraph<', true).Data = new_TDGraph_IData.Id;

% Append all new objects to Project
C_wip.add_Data(new_TDGraph, new_TDGraph_TSpace, new_TDGraph_TSpectral, new_TDGraph_ISpectral, new_TDGraph_IData); % Make new objects visible in Project-object
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Create new TDImage with random content
new_TDImage = wid.new_Image(C_wit); % Create empty TDImage
new_TDImage.Name = 'Customized TDImage';

% Create customized Data
DataUnit_TDImage = 'TDImage a.u.';
Data_TDImage = randn(100, 80); % Double

% Set new Data (and its SizeX and SizeY parameters)
new_TDImage.Data = Data_TDImage;

% Create customized transformations and interpretations
new_TDImage_TSpace = wid.new_Transformation_Space(C_wit);
% Read TDSpaceTransformation details in 'README on WIT-tag formatting.txt'.

new_TDImage_IData = wid.new_Interpretation_Z(C_wit);
new_TDImage_IData.Data.TDZInterpretation.UnitName = DataUnit_TDImage;
% Read TDZInterpretation details in 'README on WIT-tag formatting.txt'.

% Add links to transformations and interpretations
new_TDImage.Tag.Data.regexp('^PositionTransformationID<TDImage<', true).Data = new_TDImage_TSpace.Id;
% new_TDImage.Tag.Data.regexp('^SecondaryTransformationID<TDImage<', true).Data = 0; % (v7)
new_TDImage.Tag.Data.regexp('^ZInterpretationID<TDImage<', true).Data = new_TDImage_IData.Id;

% Append all new objects to Project
C_wip.add_Data(new_TDImage, new_TDImage_TSpace, new_TDImage_IData); % Make new objects visible in Project-object
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Create new TDText
new_TDText = wid.new_Text(C_wit); % Create empty TDText
new_TDText.Name = 'Customized TDText';
new_TDText.Data = {'Customized TDText example:', ''; ...
    '', ''; ...
    'This is seen as a title (in WITec Project).', ''; ...
    'This is not a seen as a title.', ''; ...
    'Property 1:', 'Value 2.'; ...
    'Property 2:', 'Value 4.'};
% Append all new objects to Project
C_wip.add_Data(new_TDText); % Make new object visible in Project-object
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% C_wip.write(); % Overwrite the original

new_file = [mfilename '.wip']; % Generate a new filename
C_wip.write(new_file); % Write Project to the specified file

C_wip.manager('-all', '-closepreview'); % Show the newly created Project
%-------------------------------------------------------------------------%


