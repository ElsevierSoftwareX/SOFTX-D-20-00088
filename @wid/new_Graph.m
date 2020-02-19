% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function obj = new_Graph(O_wit),
    if nargin == 0 || isempty(O_wit), O_wit = wid.new(); end % Create O_wit
    Version = wip.get_Root_Version(O_wit);
    
    Tag_DataClassName = wit('DataClassName 0', 'TDGraph');
    Tag_Data = wit('Data 0');
    
    Tag_TData = wip.new_TData(Version, sprintf('New %s', Tag_DataClassName.Data));
    if isempty(Version) || Version == 7,
        Tag_TDGraph = wit('TDGraph', [ ...
            wit('Version', int32(1)) ...
            wit('SizeX', int32(1)) wit('SizeY', int32(0)) wit('SizeGraph', int32(0)) ...
            wit('SpaceTransformationID', int32(0)) ...
            wit('SecondaryTransformationID', int32(0)) ...
            wit('XTransformationID', int32(0)) ...
            wit('XInterpretationID', int32(0)) ...
            wit('ZInterpretationID', int32(0)) ...
            wit('DataFieldInverted', true) ...
            wit('GraphData', [wit('Dimension', int32(2)) wit('DataType', int32(10)) wit('Ranges', int32([1 0])) wit('Data', uint8.empty)]) ...
            wit('LineChanged', logical.empty) wit('LineValid', logical.empty) ...
            ]);
        Tag_Data.Data = [Tag_TData Tag_TDGraph];
    elseif Version == 6,
        Tag_TDGraph = wit('TDGraph', [ ...
            wit('Version', int32(1)) ...
            wit('SizeX', int32(1)) wit('SizeY', int32(0)) wit('SizeGraph', int32(0)) ...
            wit('SpaceTransformationID', int32(0)) ...
            wit('XTransformationID', int32(0)) ...
            wit('XInterpretationID', int32(0)) ...
            wit('ZInterpretationID', int32(0)) ...
            wit('DataFieldInverted', true) ...
            wit('GraphData', [wit('Dimension', int32(2)) wit('DataType', int32(10)) wit('Ranges', int32([1 0])) wit('Data', uint8.empty)]) ...
            wit('LineChanged', logical.empty) wit('LineValid', logical.empty) ...
            ]);
        Tag_Data.Data = [Tag_TData Tag_TDGraph];
    elseif Version >= 0 && Version <= 5,
        Tag_TDGraph = wit('TDGraph', [ ...
            wit('Version', int32(0)) ...
            wit('SizeX', int32(1)) wit('SizeY', int32(0)) wit('SizeGraph', int32(0)) ...
            wit('SpaceTransformationID', int32(0)) ...
            wit('XTransformationID', int32(0)) ...
            wit('XInterpretationID', int32(0)) ...
            wit('ZInterpretationID', int32(0)) ...
            wit('GraphData', [wit('Dimension', int32(2)) wit('DataType', int32(10)) wit('Ranges', int32([1 0])) wit('Data', uint8.empty)]) ...
            wit('LineChanged', logical.empty) wit('LineValid', logical.empty) ...
            ]);
        Tag_Data.Data = [Tag_TData Tag_TDGraph];
    else, error('Unimplemented Version (%d)!', Version); end
    
    % Append these to the given (or created) O_wit
    [~, Pair] = wip.append(O_wit, [Tag_DataClassName Tag_Data]);
    
    % Create new wid
    obj = wid(Pair(2));
end
