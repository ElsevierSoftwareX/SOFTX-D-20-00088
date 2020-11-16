% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This helper function is called before the next release and it updates all
% the necessary files with the new version number. For instance, if old
% version is 1.2.3 and new version is 1.3.0, then provide '1.2.3' and
% '1.3.0'.

function update_version(old_version, new_version),
    % Validate input
    if ~ischar(old_version) || ~ischar(new_version),
        error('Accepting only char array inputs, i.e. ''1.3.0.0''!');
    end
    
    % Do nothing if same version
    if strcmp(old_version, new_version), return; end
    
    % Get the toolbox folder
    stored_cd = cd;
    cd_onCleanup = onCleanup(@() cd(stored_cd)); % Return to original folder upon exit or error
    cd(wit.io.basepath); % Go to the toolbox folder
    
    %% UPDATE Contents.m
    file = 'Contents.m';
    
    % Read from file
    fid = fopen(file, 'r');
    if fid == -1, error('Cannot open ''%s'' for reading.', file); end
    data = reshape(fread(fid, inf, 'uint8=>char'), 1, []);
    fclose(fid);
    
    % Update file
    data = strrep(data, ['Version ' old_version ' ('], ['Version ' new_version ' (']);
    
    % Write to file
    fid = fopen(file, 'w');
    if fid == -1, error('Cannot open ''%s'' for writing.', file); end
    fwrite(fid, data, 'uint8');
    fclose(fid);
    
    %% UPDATE CHANGELOG.md
    file = 'CHANGELOG.md';
    
    % Read from file
    fid = fopen(file, 'r');
    if fid == -1, error('Cannot open ''%s'' for reading.', file); end
    data = reshape(fread(fid, inf, 'uint8=>char'), 1, []);
    fclose(fid);
    
    % Update file
    data = strrep(data, sprintf('## [Unreleased]\r\n'), sprintf('## [Unreleased]\r\n\r\n\r\n\r\n## [%s] - %s\r\n\r\n### Added\r\n\r\n- \r\n\r\n### Changed\r\n\r\n- \r\n\r\n### Deprecated\r\n\r\n- \r\n\r\n### Removed\r\n\r\n- \r\n\r\n### Fixed\r\n\r\n- \r\n\r\n### Security\r\n\r\n- \r\n\r\n### Performance\r\n\r\n- \r\n', new_version, datestr(now, 'yyyy-mm-dd')));
    data = strrep(data, ['[Unreleased]: https://gitlab.com/jtholmi/wit_io/-/compare/v' old_version '...develop'], ['[Unreleased]: https://gitlab.com/jtholmi/wit_io/-/compare/v' new_version '...develop' sprintf('\r\n') '[' new_version ']: https://gitlab.com/jtholmi/wit_io/-/compare/v' old_version '...v' new_version]);
    
    % Write to file
    fid = fopen(file, 'w');
    if fid == -1, error('Cannot open ''%s'' for writing.', file); end
    fwrite(fid, data, 'uint8');
    fclose(fid);
    
    %% UPDATE README.md
    file = 'README.md';
    
    % Read from file
    fid = fopen(file, 'r');
    if fid == -1, error('Cannot open ''%s'' for reading.', file); end
    data = reshape(fread(fid, inf, 'uint8=>char'), 1, []);
    fclose(fid);
    
    % Update file
    data = strrep(data, ['wit_io v' old_version ' Changelog Badge'], ['wit_io v' new_version ' Changelog Badge']);
    data = strrep(data, ['https://img.shields.io/badge/changelog-wit__io_v' old_version '-0000ff.svg'], ['https://img.shields.io/badge/changelog-wit__io_v' new_version '-0000ff.svg']);
    
    % Write to file
    fid = fopen(file, 'w');
    if fid == -1, error('Cannot open ''%s'' for writing.', file); end
    fwrite(fid, data, 'uint8');
    fclose(fid);
    
    %% UPDATE wit_io.prj
    file = 'wit_io.prj';
    
    % Read from file
    fid = fopen(file, 'r');
    if fid == -1, error('Cannot open ''%s'' for reading.', file); end
    data = reshape(fread(fid, inf, 'uint8=>char'), 1, []);
    fclose(fid);
    
    % Update file
    data = strrep(data, ['<param.version>' old_version '</param.version>'], ['<param.version>' new_version '</param.version>']);
    
    % Write to file
    fid = fopen(file, 'w');
    if fid == -1, error('Cannot open ''%s'' for writing.', file); end
    fwrite(fid, data, 'uint8');
    fclose(fid);
end
