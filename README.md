# [wit_io: Toolbox for WITec Project/Data (\*.wip/\*.wid) files](https://se.mathworks.com/matlabcentral/fileexchange/70983-wit_io-toolbox-for-witec-project-data-wip-wid-files)

Toolbox can directly **read**/**write** [WITec](https://witec.de/) Project/Data (\*.wip/\*.wid)
files in [MATLAB](https://www.mathworks.com/products/matlab.html) with or without
GUI. It also provides data analysis tools.

![Example image](https://gitlab.com/jtholmi/wit_io/raw/master/example.png)



## Overview

### Description
This [MATLAB](https://www.mathworks.com/products/matlab.html) toolbox is intended
for users of [WITec](https://witec.de/) microscopes (i.e. Raman or SNOM), who work
with **\*.wip**/**\*.wid** files (**v5**, **v6** or **v7**) and wish to directly
**read**/**write** and **analyze** them in MATLAB. The main aim of this project
is to reduce the time consumed by importing, exporting and various post-processing
steps. Toolbox can also [read/write **any** WIT-tag formatted files](#any-wit-tag-formatted-file).

### Background
The **wit_io** (or earlier *wip_reader*) project began in 2016 as a side product
of MATLAB analysis of huge Raman spectroscopic datasets obtained from WITec Raman
Alpha 300 RA. The main aim of this project is to reduce the time consumed by importing,
exporting and various post-processing steps. During its development author worked
for prof. Harri Lipsanen's group in Aalto University, Finland.



## Usage

### License
This is published under **free** and **permissive** [BSD 3-Clause License](https://gitlab.com/jtholmi/wit_io/blob/master/LICENSE).
All exceptions to this license are listed under [*'helper/3rd party'*](https://gitlab.com/jtholmi/wit_io/tree/master/helper/3rd%20party) folder.

### Installation
Download [the latest zip file](https://gitlab.com/jtholmi/wit_io/-/archive/master/wit_io-master.zip)
and extract it as a new folder (i.e. *'wit_io'*) to your workfolder.

**For the first time**, go to the created folder and run *(or F5)* [*'load_or_addpath_permanently.m'*](https://gitlab.com/jtholmi/wit_io/blob/master/load_or_addpath_permanently.m)
to **permanently** add it and its subfolders to MATLAB path so that the toolbox
can be called from anywhere. **This requires administration rights.**
* Without the rights, do one of the following once per MATLAB instance to make **wit_io**
findable:
    1. Execute `addpath(genpath('toolbox_path'));`, where `'toolbox_path'` is **wit_io**'s
full installation path.
    2. Manually right-click **wit_io**'s main folder in "Current Folder"-view and
from the context menu left-click "Add to Path" and "Selected Folders and Subfolders".

**Optionally**, run *(or F5)* also [*'update_wip_and_wid_context_menus.m'*](https://gitlab.com/jtholmi/wit_io/blob/master/update_wip_and_wid_context_menus.m)
to add *'MATLAB'*-option to the **\*.wip** and **\*.wid** file right-click context
menus to enable a quick call to `[C_wid, C_wid, HtmlNames] = wip.read(file);`. **This
also requires administration rights.**

### Example cases
Run *(or F5)* interactive code (*\*.m*) under [*'EXAMPLE cases'*](/./EXAMPLE cases)
folder to learn **wit_io**. Begin by opening and running *'E_01_A_import_file_to_get_started.m'*.

### Semi-automated scripts
Consider using semi-automated scripts under [*'SCRIPT cases'*](/./SCRIPT cases)
folder on your WITec Project/Data files. They will read the given file, interact
with the user, process the relevant file contents and finally write back to the
original file.

### Requirements and compatibility:
* Requires [Image Processing Toolbox](https://se.mathworks.com/products/image.html).
* Compatible with MATLAB R2011a (or newer) in Windows, macOS and Linux operating systems.

## Advanced users

### Any WIT-tag formatted file
Toolbox can also **read** from and **write** to **arbitrary** WIT-tag formatted
files with use of `obj = wit.read(file);` and `obj.write();`, respectively. Any
WIT-tag tree content can be modified using `S_DT = wit.DataTree_get(obj);` and `wit.DataTree_set(obj, S_DT);`
class functions. Trees can also be viewed in collapsed form from workspace after
call to `S = obj.collapse();` (read-only) or `obj = wit_debug(obj);` (read+write).

### Format details of \*.wip/\*.wid-files
For more information, read [*'README on WIT-tag formatting.txt'*](https://gitlab.com/jtholmi/wit_io/blob/master/README%20on%20WIT-tag%20formatting.txt).
Please note that it is by no means an all exhaustive list, but rather consists of
formatting for the relevant WIT-tags.



## Bugs
Please report any bugs in [Issues](https://gitlab.com/jtholmi/wit_io/issues)-page.



## Additional information

### Citation *(optional)*
J. T. Holmi (2019). wit_io: Toolbox for WITec Project/Data (\*.wip/\*.wid) files (https://gitlab.com/jtholmi/wit_io), GitLab. Retrieved June 25, 2019.

### 3rd party content
* [export_fig](https://se.mathworks.com/matlabcentral/fileexchange/23629-export_fig)
* [mpl colormaps](https://bids.github.io/colormap/)
* [The Voigt/complex error function (second version)](https://se.mathworks.com/matlabcentral/fileexchange/47801-the-voigt-complex-error-function-second-version)

### Acknowledgments
[*] [jtholmi](https://gitlab.com/jtholmi)'s supervisor: [Prof. Harri Lipsanen](https://people.aalto.fi/harri.lipsanen), Aalto University, Finland  
[1] [*'clever_statistics_and_outliers.m'*](https://gitlab.com/jtholmi/wit_io/blob/master/helper/clever_statistics_and_outliers.m): G. Buzzi-Ferraris and F. Manenti (2011) "Outlier detection in large data sets", http://dx.doi.org/10.1016/j.compchemeng.2010.11.004  
[2] [*'apply_MRLCM.m'*](https://gitlab.com/jtholmi/wit_io/blob/master/helper/corrections/apply_MRLCM.m) (and deprecated *wip_reader*): J. T. Holmi (2016) "Determining the number of graphene layers by Raman-based Si-peak analysis", pp. 27–28,35, freely available to download at: http://urn.fi/URN:NBN:fi:aalto-201605122027
