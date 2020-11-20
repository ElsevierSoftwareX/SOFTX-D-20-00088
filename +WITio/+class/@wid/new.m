% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function O_wit = new(Version),
    % 'README on WIT-tag formatting.txt'
    if nargin == 0 || isempty(Version) || Version == 7, % Default: latest known version
        O_wit = WITio.class.wit('WITec Data', [ ...
            WITio.class.wit('Version', int32(7)) ...
            WITio.class.wit('SystemInformation', [WITio.class.wit('LastApplicationSessionIDs', WITio.class.wit())  WITio.class.wit('ServiceID', '') WITio.class.wit('LicenseID', '') WITio.class.wit('SystemID', '') WITio.class.wit('ApplicationVersions', WITio.class.wit(['MATLAB ' version]))]) ...
            WITio.class.wit('Data', WITio.class.wit('NumberOfData', int32(0))) ...
            ]);
        O_wit.Magic = 'WIT_DA06'; % Enforce the correct Magic string!
    elseif Version == 6,
        O_wit = WITio.class.wit('WITec Data', [ ...
            WITio.class.wit('Version', int32(6)) ...
            WITio.class.wit('SystemInformation', [WITio.class.wit('LastApplicationSessionIDs', WITio.class.wit())  WITio.class.wit('ServiceID', '') WITio.class.wit('LicenseID', '') WITio.class.wit('ApplicationVersions', WITio.class.wit(['MATLAB ' version]))]) ...
            WITio.class.wit('Data', WITio.class.wit('NumberOfData', int32(0))) ...
            ]);
        O_wit.Magic = 'WIT_DA06'; % Enforce the correct Magic string!
    elseif Version >= 0 && Version <= 5, % Legacy versions
        O_wit = WITio.class.wit('WITec Data', [ ...
            WITio.class.wit('Version', int32(Version)) ...
            WITio.class.wit('SystemInformation', [WITio.class.wit('LastApplicationSessionIDs', WITio.class.wit()) WITio.class.wit('ApplicationVersions', WITio.class.wit(['MATLAB ' version]))]) ... % (NOT IN ALL LEGACY VERSIONS)
            WITio.class.wit('Data', WITio.class.wit('NumberOfData', int32(0))) ...
            ]);
        O_wit.Magic = 'WIT_DATA'; % Enforce the correct Magic string!
    else, error('Unimplemented Version (%d)!', Version); end
end
