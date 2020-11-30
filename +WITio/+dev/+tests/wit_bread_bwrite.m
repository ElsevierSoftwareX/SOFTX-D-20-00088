% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This tests WITio.obj.wit file reading and writing through bread/bwrite.
function wit_bread_bwrite(debug),
    file_ref = fullfile(WITio.tbx.path.demo, 'A_v5.wip');
    file = fullfile(WITio.tbx.path, 'A_v5.wip');
    
    fid = fopen(file_ref, 'r');
    if fid == -1, error('Cannot open ''%s'' for reading.', file_ref); end
    data_ref = reshape(fread(fid, inf, 'uint8=>uint8'), [], 1);
    fclose(fid);
    
    O_wit = WITio.obj.wit.read(file_ref); % Use fread-bread combo
    data = reshape(O_wit.bwrite, [], 1); % Try to replicate data_ref
    
    N_data_ref = numel(data_ref);
    N_data = numel(data);
    N_min = min(N_data_ref, N_data);
    N_diff = sum(data_ref(1:N_min) ~= data(1:N_min)) + abs(N_data_ref-N_data);
    ind_diff_first = find(data_ref(1:N_min) ~= data(1:N_min), 1);
    
    if N_data_ref ~= N_data || N_diff ~= 0,
        error('Number of bytes in file (= %d) and bread-bwrite (= %d) differ by %d bytes and the first difference begins at %d.', N_data_ref, N_data, N_diff, ind_diff_first);
    end
    
    O_wit.write(file); % Uses bwrite-fwrite combo
    
    if nargin ~= 1 || ~debug,
        ocu = onCleanup(@() delete(file)); % Delete the created file on exit
    end
    
    fid = fopen(file, 'r');
    if fid == -1, error('Cannot open ''%s'' for reading.', file); end
    data = reshape(fread(fid, inf, 'uint8=>uint8'), [], 1);
    fclose(fid);
    
    N_data_ref = numel(data_ref);
    N_data = numel(data);
    N_min = min(N_data_ref, N_data);
    N_diff = sum(data_ref(1:N_min) ~= data(1:N_min)) + abs(N_data_ref-N_data);
    ind_diff_first = find(data_ref(1:N_min) ~= data(1:N_min), 1);

    if N_data_ref ~= N_data || N_diff ~= 0,
        error('Number of bytes in file (= %d) and bread-bwrite-fopen (= %d) differ by %d bytes and the first difference begins at %d.', N_data_ref, N_data, N_diff, ind_diff_first);
    end
end
