% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function wid_Data_set_Bitmap(obj, in),
    Version = [obj.Version];
     % 'README on WIT-tag formatting.txt'
    if isempty(Version) || Version == 7 || Version == 6, % WITec Suite FIVE 5.x OR WITec Project 4.x
        TDBitmap = obj.Tag.Data.regexp('^TDBitmap<', true);
        TDBitmap.regexp('^SizeX<', true).Data = int32(size(in, 1)); % SizeX
        TDBitmap.regexp('^SizeY<', true).Data = int32(size(in, 2)); % SizeY
        % Reshape to writing format
        TDBitmap.regexp('^Ranges<BitmapData<', true).Data = int32([size(in, 2) size(in, 1)]); % Ranges
        out = uint8(in);
        out(:,:,end+1) = 0; % Restore the alpha channel as zeros
        out = ipermute(out, [2 3 1]); % Permute the color channel to 1st
        out = typecast(out(:), 'int32'); % From uint8 to int32
        TDBitmap.regexp('^Data<BitmapData<', true).Data = obj.wid_set_DataType(out);
    elseif Version >= 0 && Version <= 5, % Legacy versions
        if isempty(in), warning('WITec Project 2.10.3.3 cannot read this!'); end
        
        % Process the image for writing
        SizeX = size(in, 1);
        SizeY = size(in, 2);
        BytesPerPixel = size(in, 3);
        in = ipermute(uint8(in(:,end:-1:1,end:-1:1)), [2 3 1]); % Restructure data
        in = reshape(in, [], SizeY);
        % Pad to nearest 4-byte boundary
        in_padded = zeros(ceil(BytesPerPixel.*SizeX./4).*4, SizeY, 'uint8');
        in_padded(1:BytesPerPixel.*SizeX,:) = in;
        
        out = zeros(54+numel(in_padded), 1, 'uint8'); % Initialize all to zero
        out(1:2) = 'BM';
        out(3:6) = typecast(uint32(numel(out)), 'uint8'); % The size of the BMP file in bytes
%         out(7:8) = typecast(uint16(0), 'uint8'); % Reserved; actual value depends on the application that creates the image
%         out(9:10) = typecast(uint16(0), 'uint8'); % Reserved; actual value depends on the application that creates the image
        out(11:14) = typecast(uint32(54), 'uint8'); % The offset, i.e. starting address, of the byte where the bitmap image data (pixel array) can be found.
        out(15:18) = typecast(uint32(40), 'uint8'); % The size of this header (40 bytes)
        out(19:22) = typecast(int32(SizeX), 'uint8'); % The bitmap width in pixels (signed integer)
        out(23:26) = typecast(int32(SizeY), 'uint8'); % The bitmap height in pixels (signed integer)
        out(27:28) = typecast(uint16(1), 'uint8'); % The number of color planes (must be 1)
        out(29:30) = typecast(uint16(8.*BytesPerPixel), 'uint8'); % The number of bits per pixel, which is the color depth of the image. Typical values are 1, 4, 8, 16, 24 and 32.
%         out(31:34) = typecast(uint32(0), 'uint8'); % The compression method being used. See the next table for a list of possible values
        out(35:38) = typecast(uint32(numel(in_padded)), 'uint8'); % The image size. This is the size of the raw bitmap data; a dummy 0 can be given for BI_RGB bitmaps.
%         out(39:42) = typecast(int32(0), 'uint8'); % The horizontal resolution of the image. (pixel per meter, signed integer)
%         out(43:46) = typecast(int32(0), 'uint8'); % The vertical resolution of the image. (pixel per meter, signed integer)
%         out(47:50) = typecast(uint32(0), 'uint8'); % The number of colors in the color palette, or 0 to default to 2n
%         out(51:54) = typecast(uint32(0), 'uint8'); % The number of important colors used, or 0 when every color is important; generally ignored
        out(55:end) = in_padded;

        TDStream = obj.Tag.Data.regexp('^TDStream<', true);
        TDStream.regexp('^StreamSize<', true).Data = int32(numel(out)); % int32 required by WITec Project 2.10.3.3
        TDStream.regexp('^StreamData<', true).Data = uint8(out); % uint8 required by WITec Project 2.10.3.3
    else, error('Unimplemented Version (%d)!', Version); end
end
