% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This helper script can be called after packaging a new version of toolbox
% into an mltbx-formatted installer. This adds all relevant subfolders to
% its addpath procedure using 7-zip. Call this only once per installer.
% This essentially does same as 'load_or_addpath_permanently.m' (upon
% toolbox installation) and 'unload_or_rmpath_permanently.m' (upon toolbox
% uninstallation) but behind the scenes.



% THE FOLLOWING TWO LINES MAY NEED TO BE UPDATED!
exe = 'C:\Program Files\7-Zip\7z.exe'; % Full path to 7z
toolbox = 'wit_io.mltbx'; % Full path to the toolbox installer



str = sprintf('Attempting to update configuration.xml in ''%s'' to include subfolders as addpath!', toolbox);
fprintf('%s\n%s\n%s\n', repmat('-', size(str)), str, repmat('-', size(str)));

% First extract metadata\configuration.xml from toolbox installer
str = 'Extracting ''metadata\configuration.xml'' ...';
fprintf('%s\n%s\n%s\n', repmat('-', size(str)), str, repmat('-', size(str)));

[status1, result1] = system(['"' exe '" x "' toolbox '" metadata\configuration.xml -aoa']);
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
[toolbox_path, ~, ~] = fileparts([mfilename('fullpath') '.m']);
toolbox_paths_wo_git = regexprep(genpath(toolbox_path), '[^;]*(?<=\.git)[^;]*;', ''); % Exclude all .git folders from addpath
strs = strrep(toolbox_paths_wo_git, toolbox_path, ''); % From absolute to relative paths
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

[status2, result2] = system(['"' exe '" u "' toolbox '" metadata\configuration.xml']);
disp(result2);
if status2 ~= 0, error('System command failed with status %d.', status2); end

% Then remove configuration.xml and its temporary folder
delete('metadata\configuration.xml');
rmdir('metadata');

str = 'Update successful!';
fprintf('%s\n%s\n%s\n', repmat('-', size(str)), str, repmat('-', size(str)));
