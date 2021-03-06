% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function format = wid_Data_format_TData(obj),
    if isempty(obj.Version) || obj.Version == 7,
        % Define the file format fields
        % Each row: wit-tag name, {write-parser; read-parser}
        subformat_TData = ...
            { ...
            'Version' {false; @int32; @int32}; ...
            'ID' {false; @int32; @int32}; ...
            'ImageIndex' {false; @int32; @int32}; ...
            'Caption' {false; @char; @char}; ...
            'MetaData' ...
            { ... % Sub-format
            }; ...
            'HistoryList' ...
            { ... % Sub-format
            'Number Of History Entries' {false; @int32; @int32}; ...
            'Dates' {false; @uint32; @uint32}; ...
            'Histories' {false; @char; @char}; ...
            'Types' {false; @int32; @int32} ...
            } ...
            };
    elseif obj.Version >= 0 && obj.Version <= 5 || obj.Version == 6, % Legacy versions OR v6
        % Define the file format fields
        % Each row: wit-tag name, {write-parser; read-parser}
        subformat_TData = ...
            { ...
            'Version' {false; @int32; @int32}; ...
            'ID' {false; @int32; @int32}; ...
            'ImageIndex' {false; @int32; @int32}; ...
            'Caption' {false; @char; @char}; ...
            'HistoryList' ...
            { ... % Sub-format
            'Number Of History Entries' {false; @int32; @int32}; ...
            'Dates' {false; @uint32; @uint32}; ...
            'Histories' {false; @char; @char}; ...
            'Types' {false; @int32; @int32} ...
            } ...
            };
    end
    
    % Each row: wit-tag name, {subformat}
    format = {'TData' subformat_TData};
end
