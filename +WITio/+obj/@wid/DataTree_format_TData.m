% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function format = DataTree_format_TData(Version_or_obj),
    if nargin == 0 || numel(Version_or_obj) ~= 1, Version_or_obj = []; end
    
    Version = Version_or_obj;
    if isa(Version_or_obj, 'WITio.obj.wid') || isa(Version_or_obj, 'WITio.obj.wip') || isa(Version_or_obj, 'WITio.obj.wit'),
        Version = WITio.obj.wip.get_Root_Version(Version_or_obj);
    end
    
    isVisible = false;
    if isempty(Version) || Version == 7,
        % Define the file format fields
        % Each row: wit-tag name, isVisible, {write-parser; read-parser}
        subformat_TData = ...
            { ...
            'Version' isVisible {@int32; @int32}; ...
            'ID' isVisible {@int32; @int32}; ...
            'ImageIndex' isVisible {@int32; @int32}; ...
            'Caption' isVisible {@char; @char}; ...
            'MetaData' isVisible ...
            { ... % Sub-format
            }; ...
            'HistoryList' isVisible ...
            { ... % Sub-format
            'Number Of History Entries' isVisible {@int32; @int32}; ...
            'Dates' isVisible {@uint32; @uint32}; ...
            'Histories' isVisible {@char; @char}; ...
            'Types' isVisible {@int32; @int32} ...
            } ...
            };
    elseif Version >= 0 && Version <= 5 || Version == 6, % Legacy versions OR v6
        % Define the file format fields
        % Each row: wit-tag name, isVisible, {write-parser; read-parser}
        subformat_TData = ...
            { ...
            'Version' isVisible {@int32; @int32}; ...
            'ID' isVisible {@int32; @int32}; ...
            'ImageIndex' isVisible {@int32; @int32}; ...
            'Caption' isVisible {@char; @char}; ...
            'HistoryList' isVisible ...
            { ... % Sub-format
            'Number Of History Entries' isVisible {@int32; @int32}; ...
            'Dates' isVisible {@uint32; @uint32}; ...
            'Histories' isVisible {@char; @char}; ...
            'Types' isVisible {@int32; @int32} ...
            } ...
            };
    end
    
    % Each row: wit-tag name, isVisible, {subformat}
    format = {'TData' isVisible subformat_TData};
end
