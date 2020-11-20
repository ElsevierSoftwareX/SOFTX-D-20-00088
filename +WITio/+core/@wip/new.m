% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function O_wit = new(Version),
    % 'README on WIT-tag formatting.txt'
    if nargin == 0 || isempty(Version) || Version == 7, % Default: latest known version
        O_wit = WITio.core.wit('WITec Project', [ ...
            WITio.core.wit('Version', int32(7)) ...
            WITio.core.wit('SystemInformation', [WITio.core.wit('LastApplicationSessionIDs', WITio.core.wit()) WITio.core.wit('ServiceID', '') WITio.core.wit('LicenseID', '') WITio.core.wit('SystemID', '') WITio.core.wit('ApplicationVersions', WITio.core.wit(['MATLAB ' version]))]) ...
            WITio.core.wit('NextDataID', int32(1)) ...
            WITio.core.wit('ShellExtensionInfo') ... % For thumbnail, add: WITio.core.wit('ThumbnailPreviewBitmap', [WITio.core.wit('SizeX', int32(128)) WITio.core.wit('SizeY', int32(128)) WITio.core.wit('BitsPerPixel', int32(24)) WITio.core.wit('BitmapData', uint8(Data))]) % Data->Im (for reading): Im = permute(reshape(Data, [3 128 128]), [3 2 1]); Im = Im(:,:,end:-1:1); Im->Data (for writing): Data = ipermute(uint8(Im(:,:,end:-1:1)), [3 2 1]);
            WITio.core.wit('Data', WITio.core.wit('NumberOfData', int32(0))) ...
            WITio.core.wit('Viewer', [WITio.core.wit('ViewerClassName 0', 'TVProjectManagerForm') WITio.core.wit('Viewer 0', [WITio.core.wit('TVCustomForm') WITio.core.wit('TVProjectManagerForm')]) WITio.core.wit('NumberOfViewer', int32(1))]) ...
            ]);
        O_wit.Magic = 'WIT_PR06'; % Enforce the correct Magic string!
    elseif Version == 6,
        O_wit = WITio.core.wit('WITec Project', [ ...
            WITio.core.wit('Version', int32(6)) ...
            WITio.core.wit('SystemInformation', [WITio.core.wit('LastApplicationSessionIDs', WITio.core.wit()) WITio.core.wit('ServiceID', '') WITio.core.wit('LicenseID', '') WITio.core.wit('ApplicationVersions', WITio.core.wit(['MATLAB ' version]))]) ...
            WITio.core.wit('NextDataID', int32(1)) ...
            WITio.core.wit('ShellExtensionInfo') ... % For thumbnail, add: WITio.core.wit('ThumbnailPreviewBitmap', [WITio.core.wit('SizeX', int32(128)) WITio.core.wit('SizeY', int32(128)) WITio.core.wit('BitsPerPixel', int32(24)) WITio.core.wit('BitmapData', uint8(Data))]) % Data->Im (for reading): Im = permute(reshape(Data, [3 128 128]), [3 2 1]); Im = Im(:,:,end:-1:1); Im->Data (for writing): Data = ipermute(uint8(Im(:,:,end:-1:1)), [3 2 1]);
            WITio.core.wit('Data', WITio.core.wit('NumberOfData', int32(0))) ...
            WITio.core.wit('Viewer', [WITio.core.wit('ViewerClassName 0', 'TVProjectManagerForm') WITio.core.wit('Viewer 0', [WITio.core.wit('TVCustomForm') WITio.core.wit('TVProjectManagerForm')]) WITio.core.wit('NumberOfViewer', int32(1))]) ...
            ]);
        O_wit.Magic = 'WIT_PR06'; % Enforce the correct Magic string!
    elseif Version >= 0 && Version <= 5, % Legacy versions
        O_wit = WITio.core.wit('WITec Project', [ ...
            WITio.core.wit('Version', int32(Version)) ...
            WITio.core.wit('SystemInformation', [WITio.core.wit('LastApplicationSessionIDs', WITio.core.wit()) WITio.core.wit('ApplicationVersions', WITio.core.wit(['MATLAB ' version]))]) ... % (NOT IN ALL LEGACY VERSIONS)
            WITio.core.wit('NextDataID', int32(1)) ...
            WITio.core.wit('ShellExtensionInfo') ... % (NOT IN ALL LEGACY VERSIONS) % For thumbnail, add: WITio.core.wit('ThumbnailPreviewBitmap', [WITio.core.wit('SizeX', int32(128)) WITio.core.wit('SizeY', int32(128)) WITio.core.wit('BitsPerPixel', int32(24)) WITio.core.wit('BitmapData', uint8(Data))]) % Data->Im (for reading): Im = permute(reshape(Data, [3 128 128]), [3 2 1]); Im = Im(:,:,end:-1:1); Im->Data (for writing): Data = ipermute(uint8(Im(:,:,end:-1:1)), [3 2 1]);
            WITio.core.wit('Data', WITio.core.wit('NumberOfData', int32(0))) ...
            WITio.core.wit('Viewer', [WITio.core.wit('ViewerClassName 0', 'TVProjectManagerForm') WITio.core.wit('Viewer 0', [WITio.core.wit('TVCustomForm') WITio.core.wit('TVProjectManagerForm')]) WITio.core.wit('NumberOfViewer', int32(1))]) ...
            ]);
        O_wit.Magic = 'WIT_PRCT'; % Enforce the correct Magic string!
    else, error('Unimplemented Version (%d)!', Version); end
end
