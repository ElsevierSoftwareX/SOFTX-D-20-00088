% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Use this function to generate new toolbox installer using R2014b!
function package_toolbox(),
    % Get current MATLAB version and release number
    [v, d] = builtin('version');
    tokens = regexp(v, '(\d+\.\d+\.\d+)[^\(]*\(([^\)]*)\)', 'tokens', 'once');
    
    % Error if not R2014b
    if ~strcmp(tokens{2}, 'R2014b'),
        error('Please package the toolbox using MATLAB R2014b in order to ensure that *.mltbx is backward compatible!');
    end
    
    % Change folder
    old_folder = cd;
    ocu = onCleanup(@() cd(old_folder)); % Return to old folder on exit
    WITio_folder = WITio.tbx.path;
    cd(WITio_folder); % Temporarily change folder
    
    %% GET VERSION NUMBER from Contents.m
    file_v = 'Contents.m';
    
    % Read from file
    fid_v = fopen(file_v, 'r');
    if fid_v == -1, error('Cannot open ''%s'' for reading.', file_v); end
    data = reshape(fread(fid_v, inf, 'uint8=>char'), 1, []);
    WITio_version = regexprep(data, '^.*Version\s(\d+(\.\d+)*)\s.*$', '$1');
    fclose(fid_v);
    
    %% GENERATE MINIMAL WITio.prj
    file_prj = 'WITio.prj';
    file_mltbx = 'WITio.mltbx';
    
    WITio_appname = 'WITio';
    WITio_authnamewatermark = 'Joonas T. Holmi';
    WITio_email = 'jtholmi@gmail.com';
    WITio_company = 'Aalto University';
    WITio_summary = 'Toolbox can directly read/write WITec Project/Data (*.wip/*.wid) files in MATLAB with or without GUI. It also provides data analysis tools.';
    WITio_screenshot = fullfile(WITio_folder, 'README.png');
    WITio_description = {'This MATLAB toolbox is intended for users of WITec.de microscopes (i.e. Raman or SNOM), who work with *.wip/*.wid files (v0 -- v7) and wish to directly read/write and analyze them in MATLAB. The main aim of this project is to reduce the time consumed by importing, exporting and various post-processing steps. Toolbox can also read/write any WIT-tag formatted files.', ...
        '', ...
        'For installation and usage details or more information, go to: https://gitlab.com/jtholmi/wit_io/#readme.', ...
        '', ...
        'For broader version history, go to: https://gitlab.com/jtholmi/wit_io/CHANGELOG.md.', ...
        '', ...
        'Please report any bugs in https://gitlab.com/jtholmi/wit_io/issues.'};
    WITio_exclude_filters = {'.git/*', '*.sh'};
    
    % Write to file
    fid_prj = fopen(file_prj, 'w');
    if fid_prj == -1, error('Cannot open ''%s'' for writing.', file_prj); end
    fprintf(fid_prj, '<deployment-project plugin="plugin.toolbox" plugin-version="1.0">\n');
    fprintf(fid_prj, '  <configuration build-checksum="" file="%s" location="" name="%s" target="target.toolbox" target-name="Package Toolbox">\n', file_prj, WITio_appname);
    fprintf(fid_prj, '    <param.appname>%s</param.appname>\n', WITio_appname);
    fprintf(fid_prj, '    <param.authnamewatermark>%s</param.authnamewatermark>\n', WITio_authnamewatermark);
    fprintf(fid_prj, '    <param.email>%s</param.email>\n', WITio_email);
    fprintf(fid_prj, '    <param.company>%s</param.company>\n', WITio_company);
    fprintf(fid_prj, '    <param.summary>%s</param.summary>\n', WITio_summary);
    fprintf(fid_prj, '    <param.description>%s</param.description>\n', WITio.fun.indep.mystrjoin(WITio_description, sprintf('\n')));
    fprintf(fid_prj, '    <param.screenshot>%s</param.screenshot>\n', WITio_screenshot);
    fprintf(fid_prj, '    <param.version>%s</param.version>\n', WITio_version);
    fprintf(fid_prj, '    <param.output>%s</param.output>\n', fullfile(WITio_folder, file_mltbx));
    fprintf(fid_prj, '    <param.products.name><item>MATLAB</item></param.products.name>\n');
    fprintf(fid_prj, '    <param.products.id><item>1</item></param.products.id>\n');
    fprintf(fid_prj, '    <param.products.version><item>8.4</item></param.products.version>\n');
    fprintf(fid_prj, '    <param.exclude.filters>%s</param.exclude.filters>\n', WITio.fun.indep.mystrjoin(WITio_exclude_filters, sprintf('\n')));
    fprintf(fid_prj, '    <fileset.rootdir><file>%s</file></fileset.rootdir>\n', WITio_folder);
    fprintf(fid_prj, '  </configuration>\n');
    fprintf(fid_prj, '</deployment-project>');
    fclose(fid_prj);
    
    %% GENERATE WITio.mltbx
    matlab.apputil.package(file_prj);
    
    %% DELETE WITio.prj
    delete(file_prj);
    
    %% TRY UPDATE WITio.mltbx for 'third party'-folder
    % THE FOLLOWING TWO LINES MAY NEED TO BE UPDATED!
    exe = 'C:\Program Files\7-Zip\7z.exe'; % Full path to 7z

    % Full absolute path to the toolbox installer
    file_mltbx = fullfile(WITio_folder, file_mltbx);
    
    str = sprintf('Attempting to update configuration.xml in ''%s'' to include subfolders as addpath!', file_mltbx);
    fprintf('%s\n%s\n%s\n', repmat('-', size(str)), str, repmat('-', size(str)));
    
    % First extract metadata\configuration.xml from toolbox installer
    str = 'Extracting ''metadata\configuration.xml'' ...';
    fprintf('%s\n%s\n%s\n', repmat('-', size(str)), str, repmat('-', size(str)));
    
    [status1, result1] = system(['"' exe '" x "' file_mltbx '" metadata\configuration.xml -aoa']);
    disp(result1);
    if status1 ~= 0, error('System command failed with status %d.', status1); end
    
    % Then load and modify it
    str = 'Loading and modifying ''metadata\configuration.xml'' ...';
    fprintf('%s\n%s\n%s\n', repmat('-', size(str)), str, repmat('-', size(str)));
    
    % Read from file
    fid = fopen('metadata\configuration.xml', 'r');
    if fid == -1, error('Cannot open ''metadata\configuration.xml'' for reading.'); end
    data = reshape(fread(fid, inf, 'uint8=>char'), 1, []);
    fclose(fid);
    
    % Get all relevant subfolders
    strs = strrep(genpath(fullfile(WITio_folder, 'third party')), WITio_folder, ''); % From absolute to relative paths
    strs = strrep(strs, '\', '/'); % Convert \'s to /'s
    strs = strrep(strs, ';', '</matlabPath><matlabPath>'); % Convert ;'s
    strs = strrep(strs, '<matlabPath>/metadata</matlabPath>', ''); % Remove metadata-folder
    strs = regexprep(strs, '^</matlabPath>', ''); % Remove first </matlabPath>
    strs = regexprep(strs, '<matlabPath>$', ''); % Remove last <matlabPath>
    data = strrep(data, '<matlabPath>/</matlabPath>', ['<matlabPath>/</matlabPath>' strs]); % Append these paths to the current list
    
    % Write to file
    fid = fopen('metadata\configuration.xml', 'w');
    if fid == -1, error('Cannot open ''metadata\configuration.xml'' for writing.'); end
    fwrite(fid, data, 'uint8');
    fclose(fid);
    
    % Then update toolbox installer
    str = 'Replacing old ''metadata\configuration.xml'' with new ...';
    fprintf('%s\n%s\n%s\n', repmat('-', size(str)), str, repmat('-', size(str)));
    
    [status2, result2] = system(['"' exe '" u "' file_mltbx '" metadata\configuration.xml']);
    disp(result2);
    if status2 ~= 0, error('System command failed with status %d.', status2); end
    
    % Then remove configuration.xml and its temporary folder
    delete('metadata\configuration.xml');
    rmdir('metadata');
    
    str = 'Update successful!';
    fprintf('%s\n%s\n%s\n', repmat('-', size(str)), str, repmat('-', size(str)));
    
    % Change folder back to the original folder
    clear cd_onCleanup;
end
