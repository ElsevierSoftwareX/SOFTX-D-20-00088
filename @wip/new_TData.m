% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function O_wit = new_TData(Version, Caption),
    if nargin < 2 || isempty(Version) || Version == 7,
        Tag_TData = wit('TData', [ ...
            wit('Version', int32(0)) ...
            wit('ID', int32(1)) ... % To be updated later in wip.append
            wit('ImageIndex', int32(0)) ...
            wit('Caption', Caption) ...
            wit('MetaData', wit.empty) ...
            wit('HistoryList', [wit('Number Of History Entries', int32(0)) wit('Dates', uint32.empty) wit('Histories', '') wit('Types', int32.empty)]) ...
            ]);
    elseif Version == 6,
        Tag_TData = wit('TData', [ ...
            wit('Version', int32(0)) ...
            wit('ID', int32(1)) ... % To be updated later in wip.append
            wit('ImageIndex', int32(0)) ...
            wit('Caption', Caption) ...
            wit('MetaData', wit.empty) ...
            wit('HistoryList', [wit('Number Of History Entries', int32(0)) wit('Dates', uint32.empty) wit('Histories', '') wit('Types', int32.empty)]) ...
            ]);
    elseif Version >= 0 && Version <= 5,
        Tag_TData = wit('TData', [ ...
            wit('Version', int32(0)) ...
            wit('ID', int32(1)) ... % To be updated later in wip.append
            wit('ImageIndex', int32(0)) ...
            wit('Caption', Caption) ...
            wit('HistoryList', [wit('Number Of History Entries', int32(0)) wit('Dates', uint32.empty) wit('Histories', '') wit('Types', int32.empty)]) ...
            ]);
    else, error('Unimplemented Version (%d)!', Version); end
    O_wit = Tag_TData;
end
