% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function out = wid_Data_get_Bitmap(obj)
    Version = [obj.Version];
     % 'README on WIT-tag formatting.txt'
    if isempty(Version) || Version == 7, % WITec Suite FIVE 5.x
        TDBitmap = obj.Tag.Data.regexp('^TDBitmap<', true);
        Data = TDBitmap.regexp('^Data<BitmapData<', true);
        if isempty(Data.Data), Data.reload(); end
        in = Data.Data;

        SizeX = TDBitmap.regexp('^SizeX<', true).Data;
        SizeY = TDBitmap.regexp('^SizeY<', true).Data;
        % Reshape to user format
        out = typecast(obj.wid_get_DataType(in), 'uint8'); % From int32 to uint8
        out = reshape(out, 4, SizeX, SizeY); % Reshape back to a matrix
        out = permute(out, [2 3 1]); % Permute the matrix so that the color channels go to the end
        out = out(:,:,1:3); % Ignore the 4th channel (= alpha)
    elseif Version == 6, % WITec Project 4.x
        TDBitmap = obj.Tag.Data.regexp('^TDBitmap<', true);
        Data = TDBitmap.regexp('^Data<BitmapData<', true);
        if isempty(Data.Data), Data.reload(); end
        in = Data.Data;

        SizeX = TDBitmap.regexp('^SizeX<', true).Data;
        SizeY = TDBitmap.regexp('^SizeY<', true).Data;
        % Reshape to user format
        out = typecast(obj.wid_get_DataType(in), 'uint8'); % From int32 to uint8
        out = reshape(out, 4, SizeX, SizeY); % Reshape back to a matrix
        out = permute(out, [2 3 1]); % Permute the matrix so that the color channels go to the end
        out = out(:,:,1:3); % Ignore the 4th channel (= alpha)
    elseif Version == 5, % WITec Project 2.x
        Data = obj.Tag.Data.regexp('^StreamData<TDStream<', true);
        if isempty(Data.Data), Data.reload(); end
        in = Data.Data;

        % Test if this is correctly formatted bitmap
        if ~strcmp(reshape(char(in(1:2)), 1, []), 'BM'),
            error('Unsupported TDBitmap format detected!');
        end

%             BmpFileSize = typecast(uint8(in(3:6)), 'uint32'); % The size of the BMP file in bytes
%             Reserved1 = typecast(uint8(in(7:8)), 'uint16'); % Reserved; actual value depends on the application that creates the image
%             Reserved2 = typecast(uint8(in(9:10)), 'uint16'); % Reserved; actual value depends on the application that creates the image
        Offset = typecast(uint8(in(11:14)), 'uint32'); % The offset, i.e. starting address, of the byte where the bitmap image data (pixel array) can be found.
%             HeaderSize = typecast(uint8(in(15:18)), 'uint32'); % The size of this header (40 bytes)
        SizeX = typecast(uint8(in(19:22)), 'int32'); % The bitmap width in pixels (signed integer)
        SizeY = typecast(uint8(in(23:26)), 'int32'); % The bitmap height in pixels (signed integer)
%             NColorPlanes = typecast(uint8(in(27:28)), 'uint16'); % The number of color planes (must be 1)
        BitsPerPixel = typecast(uint8(in(29:30)), 'uint16'); % The number of bits per pixel, which is the color depth of the image. Typical values are 1, 4, 8, 16, 24 and 32.
%             CompressionMethod = typecast(uint8(in(31:34)), 'uint32'); % The compression method being used. See the next table for a list of possible values
        BitmapSize = typecast(uint8(in(35:38)), 'uint32'); % The image size. This is the size of the raw bitmap data; a dummy 0 can be given for BI_RGB bitmaps.
%             ResolutionX = typecast(uint8(in(39:42)), 'int32'); % The horizontal resolution of the image. (pixel per meter, signed integer)
%             ResolutionY = typecast(uint8(in(43:46)), 'int32'); % The vertical resolution of the image. (pixel per meter, signed integer)
%             NColorsInPalette = typecast(uint8(in(47:50)), 'uint32'); % The number of colors in the color palette, or 0 to default to 2n
%             NImportantColors = typecast(uint8(in(51:54)), 'uint32'); % The number of important colors used, or 0 when every color is important; generally ignored

        out = in(Offset+1:Offset+BitmapSize); % Actual data (Suboptimal for low memory systems)

        out = permute(reshape(uint8(out), [int32(BitsPerPixel/8) SizeX SizeY]), [2 3 1]); % Reshape to easier format % int32 added for backward compability! Avoids 'Warning: Concatenation with dominant (left-most) integer class may overflow other operands on conversion to return class.'
        out = out(:,end:-1:1,end:-1:1); % Restructure data (to be shown correctly)
    else, error('Unimplemented Version (%d)!', Version); end
end
