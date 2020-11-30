# [WITio: A MATLAB data evaluation toolbox for WITec Project/Data (\*.wip/\*.wid) files][file-exchange]

[![WITio v2.0.0 Changelog Badge][changelog-badge]][changelog] [![BSD License Badge][license-badge]][license]

[changelog-badge]: https://img.shields.io/badge/changelog-WITio_v2.0.0-0000ff.svg

**WITio** is a [MATLAB] data evaluation toolbox to **read**/**write** [WITec] Project/Data (\*.wip/\*.wid)
files with GUI or without.

![Example image](README.png)



## Overview

### Description
**WITio** is intended for users of [WITec] microscopes, who work with
**\*.wip**/**\*.wid** files (from **v0** to **v7**) and want to enrich
their data evaluation within [MATLAB] environment. **WITio** makes it
possible to use the best of both [WITec] software and [MATLAB], because of
its bidirectional read/write capabilities. It not only reduces the time
spent at exporting data from [WITec] software and importing to other data
evaluation software like [MATLAB], but also provides a platform to automate
data analysis and post-processing by scripting.

### Background
**WITio** (or formerly *wit_io* for v1 or *wip_reader* for v0) project began
in 2016 as a by-product of on-going [MATLAB] data evaluation of large Raman
spectroscopic datasets obtained by *WITec Raman Alpha 300 RA*. The initial
purpose was to reduce time spent at manual exporting and importing, and benefit
from MATLAB's many libraries, script language and improved suitability to big
data evaluation. During its development author has worked for prof. Harri
Lipsanen's group in Aalto University, Finland.

## Usage

### License
This is published under **free** and **permissive** [BSD 3-Clause License][license].
Only exceptions to this license can be found in the *'[third party]'*-folder.

### Installation to MATLAB (for R2014b or newer)
Download [the latest toolbox installer] and double-click it to install it.

### Installation to MATLAB (from R2011a to R2014a)
Download [the latest zip archive] and extract it as a new folder (i.e. *'wit_io'*)
to your workfolder.

**For the first time**, go to the created folder and run (or press *F5*-key)
*'[WITio.m]'* to **permanently** add its folder to the MATLAB path so that the
toolbox packages are found. **This requires administration rights.**
* Without the rights, do one of the following once per MATLAB instance to make
**WITio** findable:
    1. Execute `addpath('toolbox_path');`, where `'toolbox_path'` is **WITio**'s 
    full installation path.
    2. Manually right-click **WITio**'s main folder in "Current Folder"-view and 
    from the context menu left-click "Add to Path" and "Selected Folders and Subfolders".

### Installation to context menus (for MATLAB R2011a or newer)
**Optionally**, run also *'[WITio.tbx.wip_wid_context_menus.m]'* to add
*'MATLAB'*-option to the **\*.wip** and **\*.wid** file right-click context
menus to enable a quick call to `[O_wid, O_wip, O_wit] = WITio.read(file);`.
**This also requires administration rights.**

### Demo cases
Execute `WITio.demo` in *Command Window* to list all available demo cases and
left-mouse click to run `WITio.demo.A1_import_file_to_get_started` and so on.

### Semi-automated batch scripts
Consider using semi-automated batch scripts under *'[batch]'*-package on your
WITec Project/Data files. They will read the given file, interact with the
user, process the relevant file contents and finally write back to the original
file.

### Backward compatibility with *wit_io* v1.4.0.1 (or older) scripts
Transition from v1.4.0.1 to v2.0.0 involves **major and minor breaking changes**,
all described in [CHANGELOG.md][changelog]. It is highly recommended to go through
all renewed demo cases and inspect *'[WITio.tbx.backward_compatible.m]'* as well. Pass
on any questions to jtholmi@gmail.com

### Requirements and compatibility:
* Requires [MATLAB] on Windows, macOS and Linux operating systems.
* Compatible with MATLAB R2011a (or newer), but in the future may be limited
MATLAB R2014b to ensure improved OOP performance.

## Advanced users

### Any WIT-tag formatted file
**WITio* can also **read** from and **write** to **arbitrary** WIT-tag formatted
files by `O_wit = WITio.obj.wit.read(file);` and `O_wit.write();`, respectively.
Any WIT-tag tree content can be modified using `S_DT = WITio.obj.wit.DataTree_get(O_wit);`
and `WITio.obj.wit.DataTree_set(O_wit, S_DT);`.

### Format details of \*.wip/\*.wid-files
For more information, read *'[README on WIT-tag format.txt]'*. Please note
that it is by no means an all exhaustive list, but rather consists of formatting
for the relevant WIT-tags.



## Bugs
Please report any bugs in [Issues](https://gitlab.com/jtholmi/wit_io/issues)-page.



## Additional information

### Citation *(optional)*
J. T. Holmi (2019). WITio: A MATLAB toolbox for WITec Project/Data (\*.wip/\*.wid) files (https://gitlab.com/jtholmi/wit_io), GitLab. Version \<x.y.z\>. Retrieved \<Month\> \<Day\>, \<Year\>.

### Third party content
* [export_fig](https://se.mathworks.com/matlabcentral/fileexchange/23629-export_fig)
* [mpl colormaps](https://bids.github.io/colormap/)
* [The Voigt/complex error function (second version)](https://se.mathworks.com/matlabcentral/fileexchange/47801-the-voigt-complex-error-function-second-version)
* [3D Euclidean Distance Transform for Variable Data Aspect Ratio](https://www.mathworks.com/matlabcentral/fileexchange/15455-3d-euclidean-distance-transform-for-variable-data-aspect-ratio)
* [Label connected components in 2-D array](https://www.mathworks.com/matlabcentral/fileexchange/26946-label-connected-components-in-2-d-array)

### Acknowledgments
[*] [jtholmi](https://gitlab.com/jtholmi)'s supervisor: [Prof. Harri Lipsanen](https://people.aalto.fi/harri.lipsanen), Aalto University, Finland  
[1] *'[clever_statistics_and_outliers.m]'*: G. Buzzi-Ferraris and F. Manenti (2011) "Outlier detection in large data sets", http://dx.doi.org/10.1016/j.compchemeng.2010.11.004  
[2] *'[myinpolygon.m]'*: J. Hao et al. (2018) "Optimal Reliable Point-in-Polygon Test and Differential Coding Boolean Operations on Polygons", https://doi.org/10.3390/sym10100477  
[3] *'[apply_MRLCM.m]'* (and deprecated *wip_reader*): J. T. Holmi (2016) "Determining the number of graphene layers by Raman-based Si-peak analysis", pp. 27&ndash;28,35, freely available to download at: http://urn.fi/URN:NBN:fi:aalto-201605122027  

[file-exchange]: https://se.mathworks.com/matlabcentral/fileexchange/70983-wit_io
[changelog]: ./CHANGELOG.md
[license]: ./LICENSE
[license-badge]: https://img.shields.io/badge/license-BSD-ff0000.svg
[WITec]: https://witec.de/
[MATLAB]: https://www.mathworks.com/products/matlab.html
[the latest toolbox installer]: ./WITio.mltbx
[the latest zip archive]: https://gitlab.com/jtholmi/wit_io/-/archive/master/wit_io-master.zip
[third party]: ./third party/
[demo]: ./+WITio/+demo
[batch]: ./+WITio/+batch
[WITio.m]: ./WITio.m
[WITio.tbx.wip_wid_context_menus.m]: ./+WITio/+tbx/wip_wid_context_menus.m
[WITio.tbx.backward_compatible.m]: ./+WITio/+tbx/backward_compatible.m
[README on WIT-tag format.txt]: ./+WITio/+doc/README%20on%20WIT-tag%20format.txt
[clever_statistics_and_outliers.m]: ./+WITio/+fun/clever_statistics_and_outliers.m
[myinpolygon.m]: ./+WITio/+fun/+indep/myinpolygon.m
[apply_MRLCM.m]: ./+WITio/+fun/+image/apply_MRLCM.m