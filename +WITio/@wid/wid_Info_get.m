% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function out = wid_Info_get(obj),
    out = struct.empty; % If not TDBitmap, TDGraph or TDImage
    
    SpaceTransformation = WITio.wid.empty;
    SecondaryTransformation = WITio.wid.empty; % v7 (only known case: Time<TDGraph, where SpaceTransformation and SecondaryTransformation are related to time (a vector) and space (a single point) in WITec Project FIVE, respectively.)
    GraphTransformation = WITio.wid.empty;
    GraphInterpretation = WITio.wid.empty;
    DataInterpretation = WITio.wid.empty;
    
    % Specialize according to the obj Type
    switch(obj.Type),
        case 'TDBitmap',
            SpaceTransformation = obj.Project.find_Data(obj.Tag.Data.regexp('^SpaceTransformationID<TDBitmap<', true).Data);
            SecondaryTransformation = obj.Project.find_Data(obj.Tag.Data.regexp('^SecondaryTransformationID<TDBitmap<', true).Data);
        case 'TDGraph',
            SpaceTransformation = obj.Project.find_Data(obj.Tag.Data.regexp('^SpaceTransformationID<TDGraph<', true).Data);
            SecondaryTransformation = obj.Project.find_Data(obj.Tag.Data.regexp('^SecondaryTransformationID<TDGraph<', true).Data);
            GraphTransformation = obj.Project.find_Data(obj.Tag.Data.regexp('^XTransformationID<TDGraph<', true).Data);
            GraphInterpretation = obj.Project.find_Data(obj.Tag.Data.regexp('^XInterpretationID<TDGraph<', true).Data);
            DataInterpretation = obj.Project.find_Data(obj.Tag.Data.regexp('^ZInterpretationID<TDGraph<', true).Data);
        case 'TDImage',
            SpaceTransformation = obj.Project.find_Data(obj.Tag.Data.regexp('^PositionTransformationID<TDImage<', true).Data);
            SecondaryTransformation = obj.Project.find_Data(obj.Tag.Data.regexp('^SecondaryTransformationID<TDImage<', true).Data);
            DataInterpretation = obj.Project.find_Data(obj.Tag.Data.regexp('^ZInterpretationID<TDImage<', true).Data);
        otherwise,
            return; % Exit if not TDBitmap, TDGraph or TDImage
    end
    
    SizeGraph = size(obj.Data, 3);
    [GraphUnit, Graph] = WITio.wip.transform(GraphTransformation, (1:SizeGraph+1)'); % 25.2.2019 transform_forced would cause NaN if ForceSpectralUnit == '(rel. 1/cm)' due to missing ExcitationWavelength!
    if isempty(GraphInterpretation) && ~isempty(GraphTransformation), % 25.2.2019 to allow handling of forced units
        GraphInterpretation = strrep(GraphTransformation.Type, 'Transformation', 'Interpretation');
    end
    [GraphUnit, Graph] = obj.Project.interpret_forced(GraphInterpretation, [], GraphUnit, Graph);
    if size(Graph, 3) == 3, Graph = sqrt(sum((Graph(:,:,:)-repmat(Graph(1,:,:), [size(Graph, 1) 1 1])).^2, 3)); end % If it was SpaceTransformation, then get length
    LengthGraph = abs(Graph(end)-Graph(1));
    Graph = Graph(1:end-1); % Remove the last point, which was needed for the length calculation
    
    % Calculate PRIMARY side lengths
    SizeX = size(obj.Data, 1);
    SizeY = size(obj.Data, 2);
    SizeZ = size(obj.Data, 4);
    X = (1:SizeX)';
    Y = (1:SizeY)';
    Z = (1:SizeZ)';
    LengthX = SizeX;
    LengthY = SizeY;
    LengthZ = SizeZ;
    LengthUnit = WITio.wip.ArbitraryUnit;
    if ~isempty(SpaceTransformation),
        [LengthUnit, Corners] = obj.Project.transform_forced(SpaceTransformation, permute([1 SizeX+1 1 1;1 1 SizeY+1 1;1 1 1 SizeZ+1], [2 3 1]));
        LengthX = sqrt(sum((Corners(1,:,:)-Corners(2,:,:)).^2, 3));
        LengthY = sqrt(sum((Corners(1,:,:)-Corners(3,:,:)).^2, 3));
        LengthZ = sqrt(sum((Corners(1,:,:)-Corners(4,:,:)).^2, 3));
        X = interp1([1 SizeX+1], Corners([1 2],:,1), X);
        Y = interp1([1 SizeY+1], Corners([1 3],:,2), Y);
        Z = interp1([1 SizeZ+1], Corners([1 4],:,3), Z);
    end
    
    % Calculate SECONDARY side lengths
    SecondarySizeX = 1;
    SecondarySizeY = 1;
    SecondarySizeZ = 1;
    SecondaryX = (1:SecondarySizeX)';
    SecondaryY = (1:SecondarySizeY)';
    SecondaryZ = (1:SecondarySizeZ)';
    SecondaryLengthX = SecondarySizeX;
    SecondaryLengthY = SecondarySizeY;
    SecondaryLengthZ = SecondarySizeZ;
    SecondaryLengthUnit = WITio.wip.ArbitraryUnit;
    if ~isempty(SecondaryTransformation),
        [SecondaryLengthUnit, SecondaryCorners] = obj.Project.transform_forced(SecondaryTransformation, permute([1 SecondarySizeX+1 1 1;1 1 SecondarySizeY+1 1;1 1 1 SecondarySizeZ+1], [2 3 1]));
        SecondaryLengthX = sqrt(sum((SecondaryCorners(1,:,:)-SecondaryCorners(2,:,:)).^2, 3));
        SecondaryLengthY = sqrt(sum((SecondaryCorners(1,:,:)-SecondaryCorners(3,:,:)).^2, 3));
        SecondaryLengthZ = sqrt(sum((SecondaryCorners(1,:,:)-SecondaryCorners(4,:,:)).^2, 3));
        SecondaryX = interp1([1 SecondarySizeX+1], SecondaryCorners([1 2],:,1), SecondaryX);
        SecondaryY = interp1([1 SecondarySizeY+1], SecondaryCorners([1 3],:,2), SecondaryY);
        SecondaryZ = interp1([1 SecondarySizeZ+1], SecondaryCorners([1 4],:,3), SecondaryZ);
    end
    
    if isempty(DataInterpretation), Unit = obj.Project.interpret_forced('TDZInterpretation');
    else, Unit = obj.Project.interpret_forced(DataInterpretation); end
    
    % Construct S_out
    out = struct();
    out.DataUnit = Unit;
    out.DataInterpretation = DataInterpretation;
    
    out.X = X;
    out.XSize = SizeX;
    out.XLength = LengthX;
    out.XUnit = LengthUnit;
    out.XTransformation = SpaceTransformation;
    out.XInterpretation = WITio.wid.empty;
    
    out.Y = Y;
    out.YSize = SizeY;
    out.YLength = LengthY;
    out.YUnit = LengthUnit;
    out.YTransformation = SpaceTransformation;
    out.YInterpretation = WITio.wid.empty;
    
    out.Graph = Graph;
    out.GraphSize = SizeGraph;
    out.GraphLength = LengthGraph;
    out.GraphUnit = GraphUnit;
    out.GraphTransformation = GraphTransformation;
    out.GraphInterpretation = GraphInterpretation;
    
    out.Z = Z;
    out.ZSize = SizeZ;
    out.ZLength = LengthZ;
    out.ZUnit = LengthUnit;
    out.ZTransformation = SpaceTransformation;
    out.ZInterpretation = WITio.wid.empty;
    
    out.SecondaryX = SecondaryX;
    out.SecondaryXSize = SecondarySizeX;
    out.SecondaryXLength = SecondaryLengthX;
    out.SecondaryXUnit = SecondaryLengthUnit;
    out.SecondaryXTransformation = SecondaryTransformation;
    out.SecondaryXInterpretation = WITio.wid.empty;
    
    out.SecondaryY = SecondaryY;
    out.SecondaryYSize = SecondarySizeY;
    out.SecondaryYLength = SecondaryLengthY;
    out.SecondaryYUnit = SecondaryLengthUnit;
    out.SecondaryYTransformation = SecondaryTransformation;
    out.SecondaryYInterpretation = WITio.wid.empty;
    
    out.SecondaryZ = SecondaryZ;
    out.SecondaryZSize = SecondarySizeZ;
    out.SecondaryZLength = SecondaryLengthZ;
    out.SecondaryZUnit = SecondaryLengthUnit;
    out.SecondaryZTransformation = SecondaryTransformation;
    out.SecondaryZInterpretation = WITio.wid.empty;
end
