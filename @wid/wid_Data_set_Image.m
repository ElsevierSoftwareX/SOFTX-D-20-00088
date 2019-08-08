% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function wid_Data_set_Image(obj, in),
    Version = [obj.Version];
     % 'README on WIT-tag formatting.txt'
    if isempty(Version) || Version == 7, % WITec Suite FIVE 5.x
        TDImage = obj.Tag.Data.regexp('^TDImage<', true);
        TDImage.regexp('^SizeX<', true).Data = int32(size(in, 1)); % SizeX
        TDImage.regexp('^SizeY<', true).Data = int32(size(in, 2)); % SizeY
        % Reshape to writing format
%         TDImage.regexp('^ImageDataIsInverted<', true).Data = false;
%         TDImage.regexp('^Ranges<ImageData<', true).Data = int32([size(in, 1) size(in, 2)]); % Ranges
%         TDImage.regexp('^Data<ImageData<', true).Data = obj.wid_set_DataType(ipermute(in, [2 1]));
        TDImage.regexp('^ImageDataIsInverted<', true).Data = true;
        TDImage.regexp('^Ranges<ImageData<', true).Data = int32([size(in, 2) size(in, 1)]); % Ranges
        TDImage.regexp('^Data<ImageData<', true).Data = obj.wid_set_DataType(in);
        % Recalculate various statistics
        in = double(in); % Convert to double for the statistics
        TDImage.regexp('^Average<', true).Data = mean(in(:));
        TDImage.regexp('^Deviation<', true).Data = std(in(:), 1);
        TDImage.regexp('^LineAverage<', true).Data = mean(in, 1);
        TDImage.regexp('^LineSumSqr<', true).Data = sum(in.^2, 1);
        TDImage.regexp('^LineSum<', true).Data = sum(in, 1);
        TDImage.regexp('^LineA<', true).Data = zeros(1, size(in, 2)); % UNKNOWN. Sometimes the first line but other times not.
        TDImage.regexp('^LineB<', true).Data = zeros(1, size(in, 2)); % UNKNOWN. Sometimes the difference between the second and the first lines but other times not.
        % Reset the LineChanged and LineValid states because new Data was set
        TDImage.regexp('^LineChanged<', true).Data = false(1, size(in, 2));
        TDImage.regexp('^LineValid<', true).Data = true(1, size(in, 2));
    elseif Version == 6, % WITec Project 4.x
        TDImage = obj.Tag.Data.regexp('^TDImage<', true);
        TDImage.regexp('^SizeX<', true).Data = int32(size(in, 1)); % SizeX % int32 required by WITec Project 2.10.3.3
        TDImage.regexp('^SizeY<', true).Data = int32(size(in, 2)); % SizeY % int32 required by WITec Project 2.10.3.3
        TDImage.regexp('^Ranges<ImageData<', true).Data = int32([size(in, 1) size(in, 2)]); % Ranges % int32 required by WITec Project 2.10.3.3
        % Reshape to writing format
        TDImage.regexp('^ImageDataIsInverted<', true).Data = false;
        TDImage.regexp('^Data<ImageData<', true).Data = obj.wid_set_DataType(ipermute(in, [2 1]));
%         TDImage.regexp('^ImageDataIsInverted<', true).Data = true;
%         TDImage.regexp('^Data<ImageData<', true).Data = obj.wid_set_DataType(in);
        % Recalculate various statistics
        in = double(in); % Convert to double for the statistics
        TDImage.regexp('^Average<', true).Data = mean(in(:));
        TDImage.regexp('^Deviation<', true).Data = std(in(:), 1);
        TDImage.regexp('^LineAverage<', true).Data = mean(in, 1);
        TDImage.regexp('^LineSumSqr<', true).Data = sum(in.^2, 1);
        TDImage.regexp('^LineSum<', true).Data = sum(in, 1);
        TDImage.regexp('^LineA<', true).Data = zeros(1, size(in, 2)); % UNKNOWN
        TDImage.regexp('^LineB<', true).Data = zeros(1, size(in, 2)); % UNKNOWN
        % Reset the LineChanged and LineValid states because new Data was set
        TDImage.regexp('^LineChanged<', true).Data = false(1, size(in, 2));
        TDImage.regexp('^LineValid<', true).Data = true(1, size(in, 2));
    elseif Version == 5, % WITec Project 2.x
%         if size(in, 1) < 2 || size(in, 2) < 2, warning('WITec Project 2.10.3.3 cannot read this!'); end
        TDImage = obj.Tag.Data.regexp('^TDImage<', true);
        TDImage.regexp('^SizeX<', true).Data = int32(size(in, 1)); % SizeX % int32 required by WITec Project 2.10.3.3
        TDImage.regexp('^SizeY<', true).Data = int32(size(in, 2)); % SizeY % int32 required by WITec Project 2.10.3.3
        TDImage.regexp('^Ranges<ImageData<', true).Data = int32([size(in, 1) size(in, 2)]); % Ranges % int32 required by WITec Project 2.10.3.3
        % Reshape to writing format
        TDImage.regexp('^Data<ImageData<', true).Data = obj.wid_set_DataType(ipermute(in, [2 1]));
        % Recalculate various statistics
        in = double(in); % Convert to double for the statistics
        TDImage.regexp('^Average<', true).Data = mean(in(:));
        TDImage.regexp('^Deviation<', true).Data = std(in(:), 1);
        TDImage.regexp('^LineAverage<', true).Data = mean(in, 1);
        TDImage.regexp('^LineSumSqr<', true).Data = sum(in.^2, 1);
        TDImage.regexp('^LineSum<', true).Data = sum(in, 1);
        TDImage.regexp('^LineA<', true).Data = zeros(1, size(in, 2)); % UNKNOWN
        TDImage.regexp('^LineB<', true).Data = zeros(1, size(in, 2)); % UNKNOWN
        % Reset the LineChanged and LineValid states because new Data was set
        TDImage.regexp('^LineChanged<', true).Data = false(1, size(in, 2));
        TDImage.regexp('^LineValid<', true).Data = true(1, size(in, 2));
    else, error('Unimplemented Version (%d)!', Version); end
end
