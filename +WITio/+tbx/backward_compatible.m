% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This script imports all the necessary WITec toolbox packages and
% functions in order to make the old example cases of wit_io v1.x.x work.

%% Define wid, wip and wip classes
import WITio.tbx.*;

%% Define anonymous functions
wit_io_edit = @WITio.tbx.edit;
wit_io_license = @WITio.tbx.license;
wit_io_msgbox = @WITio.tbx.msgbox;
wit_io_uiwait = @WITio.tbx.uiwait;

wit_io_pref_get = @WITio.tbx.pref.get;
wit_io_pref_is = @WITio.tbx.pref.is;
wit_io_pref_rm = @WITio.tbx.pref.rm;
wit_io_pref_set = @WITio.tbx.pref.set;

wit_io_compress = @WITio.fun.file.compress;
wit_io_decompress = @WITio.fun.file.decompress;

apply_CMDLCA = @WITio.fun.image.apply_CMDLCA;
apply_CMRLCM = @WITio.fun.image.apply_CMRLCM;
apply_MDLCA = @WITio.fun.image.apply_MDLCA;
apply_MRLCM = @WITio.fun.image.apply_MRLCM;

data_true_and_nan_collective_hole_reduction = @WITio.fun.image.data_true_and_nan_collective_hole_reduction;
