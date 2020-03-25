% READ FROM ZIP
file_zip = 'example_04_write_customized_data.zip';
[Files, Datas] = wit_io_file_decompress(file_zip, '-FilterExtension', '.wip', '.wid');
% [Files, Datas] = wit_io_file_decompress(file_zip, '-FilterRegexp', '\.[wW][iI][pPdP]$');

% WRITE TO ZIP
wit_io_file_compress([file_zip '.zip'], Files, Datas);
