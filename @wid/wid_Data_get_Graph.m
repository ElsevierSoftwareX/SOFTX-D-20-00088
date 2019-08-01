% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function out = wid_Data_get_Graph(obj),
    Version = [obj.Version];
     % 'README on WIT-tag formatting.txt'
    if isempty(Version) || Version == 7, % WITec Suite FIVE 5.x
        TDGraph = obj.Tag.Data.regexp('^TDGraph<', true);
        Data = TDGraph.regexp('^Data<GraphData<', true);
        if isempty(Data.Data), Data.reload(); end
        in = Data.Data;

        SizeX = TDGraph.regexp('^SizeX<', true).Data;
        SizeY = TDGraph.regexp('^SizeY<', true).Data;
        SizeGraph = TDGraph.regexp('^SizeGraph<', true).Data;
        % Reshape to user format
        DataFieldInverted = TDGraph.regexp('^DataFieldInverted<', true).Data;
        if DataFieldInverted,
            out = permute(reshape(obj.wid_get_DataType(in), [SizeGraph SizeX SizeY]), [2 3 1]);
        else,
            out = permute(reshape(obj.wid_get_DataType(in), [SizeGraph SizeY SizeX]), [3 2 1]);
        end
        if obj.Project.popUseLineValid, % Get the latest value (may be temporary or permanent or default)
            out = obj.wid_get_LineValid(out);
        end
    elseif Version == 6, % WITec Project 4.x
        TDGraph = obj.Tag.Data.regexp('^TDGraph<', true);
        Data = TDGraph.regexp('^Data<GraphData<', true);
        if isempty(Data.Data), Data.reload(); end
        in = Data.Data;

        SizeX = TDGraph.regexp('^SizeX<', true).Data;
        SizeY = TDGraph.regexp('^SizeY<', true).Data;
        SizeGraph = TDGraph.regexp('^SizeGraph<', true).Data;
        % Reshape to user format
        out = permute(reshape(obj.wid_get_DataType(in), [SizeGraph SizeY SizeX]), [3 2 1]);
        if obj.Project.popUseLineValid, % Get the latest value (may be temporary or permanent or default)
            out = obj.wid_get_LineValid(out);
        end
    elseif Version == 5, % WITec Project 2.x
        TDGraph = obj.Tag.Data.regexp('^TDGraph<', true);
        Data = TDGraph.regexp('^Data<GraphData<', true);
        if isempty(Data.Data), Data.reload(); end
        in = Data.Data;

        SizeX = TDGraph.regexp('^SizeX<', true).Data;
        SizeY = TDGraph.regexp('^SizeY<', true).Data;
        SizeGraph = TDGraph.regexp('^SizeGraph<', true).Data;
        % Reshape to user format
        out = permute(reshape(obj.wid_get_DataType(in), [SizeGraph SizeY SizeX]), [3 2 1]);
        if obj.Project.popUseLineValid, % Get the latest value (may be temporary or permanent or default)
            out = obj.wid_get_LineValid(out);
        end
    else, error('Unimplemented Version (%d)!', Version); end
end
