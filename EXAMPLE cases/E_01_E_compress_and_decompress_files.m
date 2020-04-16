% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO EXAMPLE CASE 1 E: COMPRESS AND DECOMPRESS FILES
% Simple examples of (E1E) compressing and decompressing files to save
% hard disk space. This is beneficial because the WIT-formatted files can
% often be significantly compressed in size.

clear all; % Clear workspace
close all; % Close figures

% Example file
pathstr = fileparts([mfilename('fullpath') '.m']); % Get folder of this script
file = fullfile(pathstr, 'E_v5.wip'); % Construct full path of the example file
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
wit_io_license;

h = wit_io_msgbox({'{\bf\fontsize{12}\color{magenta}EXAMPLE CASE 1 E:}' ...
    '{\bf\fontsize{12}COMPRESS AND DECOMPRESS FILES}'});
if ishandle(h), figure(h); uiwait(h); end % Wait for helpdlg to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = wit_io_msgbox({'{\bf\fontsize{12}{\color{magenta}(E1E)} Compress and decompress files:}' ...
    '' ...
    '\bullet Decompressing is done automatically if ''.zip''-extension is detected:' ...
    '{\bf\fontname{Courier}[O\_wid, O\_wip, O\_wid\_HtmlNames] = wip.read(''example.wip.zip'', ''-all'');}' ...
    '' ...
    '\bullet Compressing is done automatically if ''.zip''-extension is detected:' ...
    '{\bf\fontname{Courier} O\_wip.write(''example.wip.zip'');}' ...
    '' ...
    '\bullet Read the code for more details.' ...
    '' ...
    '\ldots Close this dialog to END.'});
if ishandle(h), figure(h); uiwait(h); end
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Load example file as uncompressed
[O_wid, O_wip, O_wid_HtmlNames] = wip.read(file, '-all');

% Compress
O_wip.write('E_v5.wip.zip'); % By default, use compression level of 1
% O_wip.write('E_v5.wip.zip', '-Params', '--CompressionLevel', []); % Built-in default compression level
% O_wip.write('E_v5.wip.zip', '-Params', '--CompressionLevel', 9); % Maximum compression level

% For more customization details, see to wit_io_file_compress.m.

% Decompress
[O_wid2, O_wip2, O_wid_HtmlNames2] = wip.read('E_v5.wip.zip', '-all');

% For more customization details, see to wit_io_file_decompress.m.
%-------------------------------------------------------------------------%


