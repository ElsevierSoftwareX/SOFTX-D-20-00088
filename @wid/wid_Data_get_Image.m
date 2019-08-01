% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function out = wid_Data_get_Image(obj),
    Version = [obj.Version];
     % 'README on WIT-tag formatting.txt'
    if isempty(Version) || Version == 7, % WITec Suite FIVE 5.x
        TDImage = obj.Tag.Data.regexp('^TDImage<', true);
        Data = TDImage.regexp('^Data<ImageData<', true);
        if isempty(Data.Data), Data.reload(); end
        in = Data.Data;

        SizeX = TDImage.regexp('^SizeX<', true).Data;
        SizeY = TDImage.regexp('^SizeY<', true).Data;
        % Reshape to user format
        ImageDataIsInverted = TDImage.regexp('^ImageDataIsInverted<', true).Data;
        if ImageDataIsInverted,
            out = reshape(obj.wid_get_DataType(in), [SizeX SizeY]);
        else,
            out = permute(reshape(obj.wid_get_DataType(in), [SizeY SizeX]), [2 1]);
        end
        if obj.Project.popUseLineValid, % Get the latest value (may be temporary or permanent or default)
            out = obj.wid_get_LineValid(out);
        end
    elseif Version == 6, % WITec Project 4.x
        TDImage = obj.Tag.Data.regexp('^TDImage<', true);
        Data = TDImage.regexp('^Data<ImageData<', true);
        if isempty(Data.Data), Data.reload(); end
        in = Data.Data;

        SizeX = TDImage.regexp('^SizeX<', true).Data;
        SizeY = TDImage.regexp('^SizeY<', true).Data;
        % Reshape to user format
        ImageDataIsInverted = TDImage.regexp('^ImageDataIsInverted<', true).Data;
        if ImageDataIsInverted,
            out = reshape(obj.wid_get_DataType(in), [SizeX SizeY]);
        else,
            out = permute(reshape(obj.wid_get_DataType(in), [SizeY SizeX]), [2 1]);
        end
        if obj.Project.popUseLineValid, % Get the latest value (may be temporary or permanent or default)
            out = obj.wid_get_LineValid(out);
        end
    elseif Version == 5, % WITec Project 2.x
        TDImage = obj.Tag.Data.regexp('^TDImage<', true);
        Data = TDImage.regexp('^Data<ImageData<', true);
        if isempty(Data.Data), Data.reload(); end
        in = Data.Data;

        SizeX = TDImage.regexp('^SizeX<', true).Data;
        SizeY = TDImage.regexp('^SizeY<', true).Data;
        % Reshape to user format
        out = permute(reshape(obj.wid_get_DataType(in), [SizeY SizeX]), [2 1]);
        if obj.Project.popUseLineValid, % Get the latest value (may be temporary or permanent or default)
            out = obj.wid_get_LineValid(out);
        end
    else, error('Unimplemented Version (%d)!', Version); end
end
