% Verification of TDSpectralTransformation (STT==2) implementation

% Create new Project objects
Version = 5; % Use version 5 here for forward-compability
C_wit = wip.new(Version); % Create new Project (*.WIP-format) WIT-tree root
C_wip = wip(C_wit); % Create its Project object

% Create new Image<TDGraph with random content
new_TDGraph = wid.new_Graph(C_wit); % Create empty Image<TDGraph
new_TDGraph.SubType = 'Point'; % Set its ImageIndex
new_TDGraph.Name = 'Point<TDGraph';

% Create customized Data
SizeGraph = 1600;
Data_TDGraph = reshape(1:SizeGraph, 1, 1, SizeGraph); % Double

% Set new Data (and its SizeX, SizeY and SizeGraph parameters)
new_TDGraph.Data = Data_TDGraph;

% Create customized transformations and interpretations
new_TDGraph_TSpectral = wid.new_Transformation_Spectral(C_wit);



% Interpret Graph-variable (nm) as (rel. 1/cm)
new_TDGraph_ISpectral = wid.new_Interpretation_Spectral(C_wit);
new_TDGraph_ISpectral.Data.TDSpectralInterpretation.ExcitationWaveLength = 532.070; % Green laser
new_TDGraph_ISpectral.Data.TDInterpretation.UnitIndex = 3; % (rel. 1/cm)

% Add links to transformations and interpretations
new_TDGraph.Tag.Data.regexp('^XTransformationID<TDGraph<', true).Data = new_TDGraph_TSpectral.Id;
new_TDGraph.Tag.Data.regexp('^XInterpretationID<TDGraph<', true).Data = new_TDGraph_ISpectral.Id;

% Append all new objects to Project
C_wip.add_Data(new_TDGraph, new_TDGraph_TSpectral, new_TDGraph_ISpectral); % Make new objects visible in Project-object



% Create test cases for STT = 2
for ii = 1:7,
    % Generate a random FreePolynom case
    obj = new_TDGraph.copy();
    obj.Name = sprintf('Test %d', ii);
    
    GT = obj.Info.GraphTransformation;
    TData = GT.Data;
    order = randi(4);
    TData.TDSpectralTransformation.SpectralTransformationType = 2;
    TData.TDSpectralTransformation.FreePolynomOrder = order;
    TData.TDSpectralTransformation.FreePolynomStartBin = 7;
    TData.TDSpectralTransformation.FreePolynomStopBin = randi(SizeGraph)-1;
    TData.TDSpectralTransformation.FreePolynom = randn(order+1,1);
    GT.Data = TData;
    
    % Make a LUT version of previous object
    obj_LUT = obj.copy();
    obj_LUT.Name = sprintf('Test %d LUT', ii);
    
    LUTT = wid.new_Transformation_LUT(C_wit);
    LUTT_Data = LUTT.Data; % Get formatted struct once to speed-up
    LUTT_Data.TDLUTTransformation.LUT = obj.interpret_Graph('(nm)'); % Its SpectralUnit is always (nm) under the hood until interpreted to other kind!
    LUTT_Data.TDLUTTransformation.LUTSize = SizeGraph; % Ignored by wit_io, but used in WITec software
    LUTT_Data.TDLUTTransformation.LUTIsIncreasing = true; % Ignored by wit_io, but used in WITec software
    LUTT.Data = LUTT_Data; % Save all changes once
    obj_LUT.Tag.Data.regexp('^XTransformationID<TDGraph<', true).Data = LUTT.Id;
    
    C_wip.add_Data(LUTT);
end



new_file = [mfilename('fullpath') '.wip']; % Generate a new filename
C_wip.write(new_file); % Write Project to the specified file

% Show the newly created Project
C_wip.manager('-all', '-closepreview');

% Then open generated file in WITec Project software and compare to LUT
% and see that they DO OVERLAP.


