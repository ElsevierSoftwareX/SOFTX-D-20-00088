# [WITio: A MATLAB toolbox for WITec Project/Data (\*.wip/\*.wid) files][file-exchange]

[![WITio v2.0.0 Changelog Badge][changelog-badge]][changelog] [![BSD License Badge][license-badge]][license]

[changelog-badge]: https://img.shields.io/badge/changelog-WITio_v2.0.0-0000ff.svg

Toolbox can directly **read**/**write** [WITec] Project/Data (\*.wip/\*.wid)
files in [MATLAB] with or without GUI. It also provides data analysis tools.

![Example image](README.png)



## Overview

### Description
This [MATLAB] toolbox is intended for users of [WITec.de][WITec] microscopes
(i.e. Raman or SNOM), who work with **\*.wip**/**\*.wid** files (**v0** &ndash; **v7**)
and wish to directly **read**/**write** and **analyze** them in MATLAB. The
main aim of this project is to reduce the time consumed by importing, exporting
and various post-processing steps. Toolbox can also [read/write **any** WIT-tag
formatted files](#any-wit-tag-formatted-file).

### Background
The **WITio** or **wit_io** (or earlier *wip_reader*) project began in 2016 as a side product
of MATLAB analysis of huge Raman spectroscopic datasets obtained by WITec Raman
Alpha 300 RA. The hope was to reduce time spent to manual exporting (from WITec
software) and importing (in MATLAB software) and benefit from MATLAB's many
libraries, scriptability, customizability and better suitability to BIG data
analysis. During its development author worked for prof. Harri Lipsanen's group
in Aalto University, Finland.



## Usage

### License
This is published under **free** and **permissive** [BSD 3-Clause License][license].
Only exceptions to this license can be found in the *'[third party]'* folder.

### Installation to MATLAB (for R2014b or newer)
Download [the latest toolbox installer] and double-click it to
install it.

### Installation to MATLAB (from R2011a to R2014a)
Download [the latest zip archive] and extract it as a new folder (i.e. *'wit_io'*)
to your workfolder.

**For the first time**, go to the created folder and run *(or F5)* *'[WITio.m]'*
to **permanently** add it and its subfolders to MATLAB path so that the toolbox
can be called from anywhere. **This requires administration rights.**
* Without the rights, do one of the following once per MATLAB instance to make
**wit_io** findable:
    1. Execute `addpath(genpath('toolbox_path'));`, where `'toolbox_path'`
is **wit_io**'s full installation path.
    2. Manually right-click **wit_io**'s main folder in "Current Folder"-view
and from the context menu left-click "Add to Path" and "Selected Folders and
Subfolders".

### Installation to context menus (for MATLAB R2011a or newer)
**Optionally**, run *(or F5)* also *'[WITio.update_context_menus_for_wip_and_wid_files.m]'*
to add *'MATLAB'*-option to the **\*.wip** and **\*.wid** file right-click
context menus to enable a quick call to `[O_wid, O_wip, O_wid_HtmlNames] = WITio.read(file);`.
**This also requires administration rights.**

### Example cases
Run *(or F5)* interactive code (*\*.m*) under *'[EXAMPLE cases]'* folder to
learn **WITio**. Begin by opening and running *'WITio.examples.A1_import_file_to_get_started.m'*.

### Semi-automated scripts
Consider using semi-automated scripts under *'[SCRIPT cases]'* folder on your
WITec Project/Data files. They will read the given file, interact with the
user, process the relevant file contents and finally write back to the original
file.

### Requirements and compatibility:
* Requires [MATLAB](https://www.mathworks.com/products/matlab.html).
* Compatible with MATLAB R2011a (or newer) in Windows, macOS and Linux operating
systems.

## Advanced users

### Any WIT-tag formatted file
Toolbox can also **read** from and **write** to **arbitrary** WIT-tag formatted
files with use of `O_wit = WITio.wit.read(file);` and `O_wit.write();`, respectively.
Any WIT-tag tree content can be modified using `S_DT = WITio.wit.DataTree_get(O_wit);`
and `WITio.wit.DataTree_set(O_wit, S_DT);` class functions. Trees can also be viewed
in collapsed form from workspace after call to `S = O_wit.collapse();` (read-only)
or `O_wit_debug = WITio.wit.debug(O_wit);` (read+write).

### Format details of \*.wip/\*.wid-files
For more information, read *'[README on WIT-tag format.txt]'*. Please note
that it is by no means an all exhaustive list, but rather consists of formatting
for the relevant WIT-tags.



## Bugs
Please report any bugs in [Issues](https://gitlab.com/jtholmi/wit_io/issues)-page.



## Additional information

### Citation *(optional)*
J. T. Holmi (2019). WITio: A MATLAB toolbox for WITec Project/Data (\*.wip/\*.wid) files (https://gitlab.com/jtholmi/wit_io), GitLab. Version \<x.y.z\>. Retrieved \<Month\> \<Day\>, \<Year\>.

### 3rd party content
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
[third party]: ./+WITio/+lib
[EXAMPLE cases]: ./+WITio/+examples
[SCRIPT cases]: ./+WITio/+scripts
[WITio.m]: ./WITio.m
[WITio.update_context_menus_for_wip_and_wid_files.m]: ./+WITio/update_context_menus_for_wip_and_wid_files.m
[README on WIT-tag format.txt]: ./+WITio/+doc/README%20on%20WIT-tag%20format.txt
[clever_statistics_and_outliers.m]: ./+WITio/+fun/clever_statistics_and_outliers.m
[myinpolygon.m]: ./+WITio/+fun/myinpolygon.m
[apply_MRLCM.m]: ./+WITio/+fun/+correct/apply_MRLCM.m