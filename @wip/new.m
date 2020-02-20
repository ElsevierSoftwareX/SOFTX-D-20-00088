% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function O_wit = new(Version),
    % 'README on WIT-tag formatting.txt'
    if nargin == 0 || isempty(Version) || Version == 7, % Default: latest known version
        O_wit = wit('WITec Project', [ ...
            wit('Version', int32(7)) ...
            wit('SystemInformation', [wit('LastApplicationSessionIDs', wit()) wit('ServiceID', '') wit('LicenseID', '') wit('SystemID', '') wit('ApplicationVersions', wit(['MATLAB ' version]))]) ...
            wit('NextDataID', int32(1)) ...
            wit('ShellExtensionInfo') ... % For thumbnail, add: wit('ThumbnailPreviewBitmap', [wit('SizeX', int32(128)) wit('SizeY', int32(128)) wit('BitsPerPixel', int32(24)) wit('BitmapData', uint8(Data))]) % Data->Im (for reading): Im = permute(reshape(Data, [3 128 128]), [3 2 1]); Im = Im(:,:,end:-1:1); Im->Data (for writing): Data = ipermute(uint8(Im(:,:,end:-1:1)), [3 2 1]);
            wit('Data', wit('NumberOfData', int32(0))) ...
            wit('Viewer', [wit('ViewerClassName 0', 'TVProjectManagerForm') wit('Viewer 0', [wit('TVCustomForm') wit('TVProjectManagerForm')]) wit('NumberOfViewer', int32(1))]) ...
            ]);
        O_wit.Magic = 'WIT_PR06'; % Enforce the correct Magic string!
    elseif Version == 6,
        O_wit = wit('WITec Project', [ ...
            wit('Version', int32(6)) ...
            wit('SystemInformation', [wit('LastApplicationSessionIDs', wit()) wit('ServiceID', '') wit('LicenseID', '') wit('ApplicationVersions', wit(['MATLAB ' version]))]) ...
            wit('NextDataID', int32(1)) ...
            wit('ShellExtensionInfo') ... % For thumbnail, add: wit('ThumbnailPreviewBitmap', [wit('SizeX', int32(128)) wit('SizeY', int32(128)) wit('BitsPerPixel', int32(24)) wit('BitmapData', uint8(Data))]) % Data->Im (for reading): Im = permute(reshape(Data, [3 128 128]), [3 2 1]); Im = Im(:,:,end:-1:1); Im->Data (for writing): Data = ipermute(uint8(Im(:,:,end:-1:1)), [3 2 1]);
            wit('Data', wit('NumberOfData', int32(0))) ...
            wit('Viewer', [wit('ViewerClassName 0', 'TVProjectManagerForm') wit('Viewer 0', [wit('TVCustomForm') wit('TVProjectManagerForm')]) wit('NumberOfViewer', int32(1))]) ...
            ]);
        O_wit.Magic = 'WIT_PR06'; % Enforce the correct Magic string!
    elseif Version >= 0 && Version <= 5, % Legacy versions
        O_wit = wit('WITec Project', [ ...
            wit('Version', int32(Version)) ...
            wit('SystemInformation', [wit('LastApplicationSessionIDs', wit()) wit('ApplicationVersions', wit(['MATLAB ' version]))]) ... % (NOT IN ALL LEGACY VERSIONS)
            wit('NextDataID', int32(1)) ...
            wit('ShellExtensionInfo') ... % (NOT IN ALL LEGACY VERSIONS) % For thumbnail, add: wit('ThumbnailPreviewBitmap', [wit('SizeX', int32(128)) wit('SizeY', int32(128)) wit('BitsPerPixel', int32(24)) wit('BitmapData', uint8(Data))]) % Data->Im (for reading): Im = permute(reshape(Data, [3 128 128]), [3 2 1]); Im = Im(:,:,end:-1:1); Im->Data (for writing): Data = ipermute(uint8(Im(:,:,end:-1:1)), [3 2 1]);
            wit('Data', wit('NumberOfData', int32(0))) ...
            wit('Viewer', [wit('ViewerClassName 0', 'TVProjectManagerForm') wit('Viewer 0', [wit('TVCustomForm') wit('TVProjectManagerForm')]) wit('NumberOfViewer', int32(1))]) ...
            ]);
        O_wit.Magic = 'WIT_PRCT'; % Enforce the correct Magic string!
    else, error('Unimplemented Version (%d)!', Version); end
end
