% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function wid_Data_set_Graph(obj, in)
    Version = [obj.Version];
     % 'README on WIT-tag formatting.txt'
    if isempty(Version) || Version == 7, % WITec Suite FIVE 5.x
        TDGraph = obj.Tag.Data.regexp('^TDGraph<', true);
        TDGraph.regexp('^SizeX<', true).Data = int32(max(1, size(in, 1))); % SizeX
        TDGraph.regexp('^SizeY<', true).Data = int32(size(in, 2)); % SizeY
        TDGraph.regexp('^SizeGraph<', true).Data = int32(size(in, 3)); % SizeGraph
        % Reshape to writing format
        TDGraph.regexp('^DataFieldInverted<', true).Data = false;
        TDGraph.regexp('^Ranges<GraphData<', true).Data = int32([max(1, size(in, 1)) size(in, 2).*size(in, 3)]); % Ranges
        TDGraph.regexp('^Data<GraphData<', true).Data = obj.wid_set_DataType(ipermute(in, [3 2 1]));
%         TDGraph.regexp('^DataFieldInverted<', true).Data = true;
%         TDGraph.regexp('^Ranges<GraphData<', true).Data = int32([max(1, size(in, 2)) size(in, 1).*size(in, 3)]); % Ranges
%         TDGraph.regexp('^Data<GraphData<', true).Data = obj.wid_set_DataType(ipermute(in, [2 3 1]));
        % Reset the LineChanged and LineValid states because new Data was set
        TDGraph.regexp('^LineChanged<', true).Data = false(1, size(in, 2));
        TDGraph.regexp('^LineValid<', true).Data = true(1, size(in, 2));
    elseif Version == 6, % WITec Project 4.x
        TDGraph = obj.Tag.Data.regexp('^TDGraph<', true);
        TDGraph.regexp('^SizeX<', true).Data = int32(max(1, size(in, 1))); % SizeX % int32 and max required by WITec Project 2.10.3.3
        TDGraph.regexp('^SizeY<', true).Data = int32(size(in, 2)); % SizeY % int32 required by WITec Project 2.10.3.3
        TDGraph.regexp('^SizeGraph<', true).Data = int32(size(in, 3)); % SizeGraph % int32 required by WITec Project 2.10.3.3
        TDGraph.regexp('^Ranges<GraphData<', true).Data = int32([max(1, size(in, 1)) size(in, 2).*size(in, 3)]); % Ranges % int32 required by WITec Project 2.10.3.3
        % Reshape to writing format
        TDGraph.regexp('^Data<GraphData<', true).Data = obj.wid_set_DataType(ipermute(in, [3 2 1]));
        % Reset the LineChanged and LineValid states because new Data was set
        TDGraph.regexp('^LineChanged<', true).Data = false(1, size(in, 2));
        TDGraph.regexp('^LineValid<', true).Data = true(1, size(in, 2));
    elseif Version == 5, % WITec Project 2.x
        TDGraph = obj.Tag.Data.regexp('^TDGraph<', true);
        TDGraph.regexp('^SizeX<', true).Data = int32(max(1, size(in, 1))); % SizeX % int32 and max required by WITec Project 2.10.3.3
        TDGraph.regexp('^SizeY<', true).Data = int32(size(in, 2)); % SizeY % int32 required by WITec Project 2.10.3.3
        TDGraph.regexp('^SizeGraph<', true).Data = int32(size(in, 3)); % SizeGraph % int32 required by WITec Project 2.10.3.3
        TDGraph.regexp('^Ranges<GraphData<', true).Data = int32([max(1, size(in, 1)) size(in, 2).*size(in, 3)]); % Ranges % int32 required by WITec Project 2.10.3.3
        % Reshape to writing format
        TDGraph.regexp('^Data<GraphData<', true).Data = obj.wid_set_DataType(ipermute(in, [3 2 1]));
        % Reset the LineChanged and LineValid states because new Data was set
        TDGraph.regexp('^LineChanged<', true).Data = false(1, size(in, 2));
        TDGraph.regexp('^LineValid<', true).Data = true(1, size(in, 2));
    else, error('Unimplemented Version (%d)!', Version); end
end
