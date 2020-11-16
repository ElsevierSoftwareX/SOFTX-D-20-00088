% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function O_wit = new(Version),
    % 'README on WIT-tag formatting.txt'
    if nargin == 0 || isempty(Version) || Version == 7, % Default: latest known version
        O_wit = wit.io.wit('WITec Data', [ ...
            wit.io.wit('Version', int32(7)) ...
            wit.io.wit('SystemInformation', [wit.io.wit('LastApplicationSessionIDs', wit.io.wit())  wit.io.wit('ServiceID', '') wit.io.wit('LicenseID', '') wit.io.wit('SystemID', '') wit.io.wit('ApplicationVersions', wit.io.wit(['MATLAB ' version]))]) ...
            wit.io.wit('Data', wit.io.wit('NumberOfData', int32(0))) ...
            ]);
        O_wit.Magic = 'WIT_DA06'; % Enforce the correct Magic string!
    elseif Version == 6,
        O_wit = wit.io.wit('WITec Data', [ ...
            wit.io.wit('Version', int32(6)) ...
            wit.io.wit('SystemInformation', [wit.io.wit('LastApplicationSessionIDs', wit.io.wit())  wit.io.wit('ServiceID', '') wit.io.wit('LicenseID', '') wit.io.wit('ApplicationVersions', wit.io.wit(['MATLAB ' version]))]) ...
            wit.io.wit('Data', wit.io.wit('NumberOfData', int32(0))) ...
            ]);
        O_wit.Magic = 'WIT_DA06'; % Enforce the correct Magic string!
    elseif Version >= 0 && Version <= 5, % Legacy versions
        O_wit = wit.io.wit('WITec Data', [ ...
            wit.io.wit('Version', int32(Version)) ...
            wit.io.wit('SystemInformation', [wit.io.wit('LastApplicationSessionIDs', wit.io.wit()) wit.io.wit('ApplicationVersions', wit.io.wit(['MATLAB ' version]))]) ... % (NOT IN ALL LEGACY VERSIONS)
            wit.io.wit('Data', wit.io.wit('NumberOfData', int32(0))) ...
            ]);
        O_wit.Magic = 'WIT_DATA'; % Enforce the correct Magic string!
    else, error('Unimplemented Version (%d)!', Version); end
end
