% READ FROM ZIP
file_zip = 'example_04_write_customized_data.zip';
[Files, Datas] = myunzip(file_zip, '-FilterExt', '.wip', '.wid');

% WRITE TO ZIP
myzip([file_zip '.zip'], Files, Datas);
