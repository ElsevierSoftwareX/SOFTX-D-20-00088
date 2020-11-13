% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO EXAMPLE CASE 1 E: COMPRESS AND DECOMPRESS FILES
% Simple examples of (E1E) compressing and decompressing files to save
% hard disk space. This is beneficial because the WIT-formatted files can
% often be significantly compressed in size.

wit_io_edit(); % Open this code in Editor
close all; % Close figures

% Example file
pathstr = fileparts([mfilename('fullpath') '.m']); % Get folder of this script
file = fullfile(pathstr, 'E_v5.wip'); % Construct full path of the example file
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
wit_io_license;

h = wit_io_msgbox({'{\bf\fontsize{12}\color{magenta}EXAMPLE CASE 1 E:}' ...
    '{\bf\fontsize{12}COMPRESS AND DECOMPRESS FILES}'});
wit_io_uiwait(h); % Wait for wit_io_msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = wit_io_msgbox({'{\bf\fontsize{12}{\color{magenta}(E1E)} Compress and decompress files:}' ...
    '' ...
    '\bullet Decompressing is done automatically if ''.zip'' or ''.zst'' extension is detected:' ...
    '{\bf\fontname{Courier}[O\_wid, O\_wip, O\_wid\_HtmlNames] = wip.read(''example.wip.zip'', ''-all'');}' ...
    '' ...
    '\bullet Compressing is done automatically if ''.zip'' or ''.zst'' extension is detected:' ...
    '{\bf\fontname{Courier}O\_wip.write(''example.wip.zip'');}' ...
    '' ...
    '\bullet The latter ''.zst'' stands for {\bf\fontname{Courier}ZStandard} and is a modern real-time compression algorithm that has both high compression ratios and high compression speed. It is {\bf\fontname{Courier}highly recommended} for big datas due to its speed superiority over *.zip format with comparable compression ratios.' ...
    '' ...
    '\bullet Read the code for more details.' ...
    '' ...
    '\ldots Close this dialog to END.'});
wit_io_uiwait(h); % Wait for wit_io_msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Load example file as uncompressed
fprintf('\n----------------------\nINITIAL PREPARATION...\n----------------------\n');
[O_wid, O_wip, O_wid_HtmlNames] = wip.read(file, '-all');
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Compress the example file
fprintf('\n--------------\nCOMPRESSING...\n--------------\n');
O_wip.write('E_v5.wip.zip'); % By default, use minimum compression for *.zip
O_wip.write('E_v5.wip.zst'); % By default, use minimum compression for *.zst

% Please note that the performance benefits of *.zst become evident with
% larger file sizes than this.

% Minimum compression level of 1 already achieve significant space savings
% for some WITec software files. At best, the compressed files has been
% seen to reduce down to 20% of their original uncompressed sizes, even
% when they contain hyperspectral Image Scan datas!

% The compression level can be changed as shown below as commented lines:
% O_wip.write('E_v5.wip.zip', '-Params', '--CompressionLevel', 0); % No compression for *.zip
% O_wip.write('E_v5.wip.zip', '-Params', '--CompressionLevel', 1); % Minimum compression for *.zip
% O_wip.write('E_v5.wip.zip', '-Params', '--CompressionLevel', []); % Built-in default compression for *.zip
% O_wip.write('E_v5.wip.zip', '-Params', '--CompressionLevel', 9); % Maximum compression for *.zip
% O_wip.write('E_v5.wip.zst', '-Params', '--CompressionLevel', 1); % Minimum compression for *.zst
% O_wip.write('E_v5.wip.zst', '-Params', '--CompressionLevel', []); % Built-in default compression for *.zst
% O_wip.write('E_v5.wip.zst', '-Params', '--CompressionLevel', 22); % Maximum compression for *.zst

% For more customization details, see to wit_io_file_compress.m. The
% second dash '-' in front, like in '--CompressionLevel', is needed because
% the function is not called directly. For direct calls,
% '-CompressionLevel' is the correct way.

% It is worth noting that the above uses wit_io_file_compress.m that
% performs dataset compression directly in memory.

% The commented lines below demonstrates another way to do the same:
% binary = O_wip.Tree.bwrite(); % First convert wip Project object to binary
% wit_io_file_compress('E_v5.wip.zip', 'E_v5.wip', binary); % Then compress the binary as *.zip
% wit_io_file_compress('E_v5.wip.zst', 'E_v5.wip', binary); % Then compress the binary as *.zst
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Decompress the compressed example file
fprintf('\n----------------\nDECOMPRESSING...\n----------------\n');
[O_wid2, O_wip2, O_wid_HtmlNames2] = wip.read('E_v5.wip.zip', '-all');
[O_wid2, O_wip2, O_wid_HtmlNames2] = wip.read('E_v5.wip.zst', '-all');

% By default, only the *.wid and *.wip are decompressed from *.zip and
% *.zst files and all the others are ignored. For *.zip, if there are
% multiple files, then they are all loaded and merged into one wip Project
% object. This does not apply to *.zst, because it only contains a single
% file in it.

% If it is important to load only certain files from *.zip file, then
% filter the files extra parameter '--Files' like commented below:
% [O_wid2, O_wip2, O_wid_HtmlNames2] = wip.read('E_v5.wip.zip', '-all', '-Params', '--Files', 'E_v5.wip'); % Find and load 'E_v5.wip'

% For more customization details, see to wit_io_file_decompress.m. The
% second dash '-' in front, like in '--Files', is needed because the
% function is not called directly. For direct calls, '-Files' is the
% correct way.

% The compressed file names can also be loaded with one of the following lines:
files_in_zip = wit_io_file_decompress('E_v5.wip.zip'); % This loads files BUT SKIPS DATA DECOMPRESSION
[files_in_zip, datasizes_in_zip] = wit_io_file_decompress('E_v5.wip.zip', '-DataSizes'); % This loads files and data sizes BUT SKIPS DATA DECOMPRESSION

% The commented lines below demonstrates the actual decompression call:
% [files_in_zip, datas_in_zip] = wit_io_file_decompress('E_v5.wip.zip'); % This loads files and their DECOMPRESSED datas
%-------------------------------------------------------------------------%


