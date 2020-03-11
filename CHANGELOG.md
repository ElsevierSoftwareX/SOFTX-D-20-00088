# Changelog
All **notable** changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

### Types of changes:
- **Added** for new features.
- **Changed** for changes in existing functionality.
- **Deprecated** for soon-to-be removed features.
- **Removed** for now removed features.
- **Fixed** for any bug fixes.
- **Security** in case of vulnerabilities.
- **Performance** for any performance improvements.



## [Unreleased]



## [1.2.0] - 2020-03-11

### Added
- Add this changelog to the project.
- Experimental support to legacy file versions **v0&endash;v4**, all of which will be read and written technically as **v5** due to the way WITec software ignores unused and unrelated WIT-tags.
- Demo to show measurement regions in the microscope image.
- New plot_position functionality and added '-position'-option to plot-function.
- New plot_scalebar functionality and added '-scalebar'-option to plot-function.
- Add 'regexp' and 'search' functions for wit object ancestors.
- Added clear notes on MATLAB toolbox dependencies in each related file.
- New dev tools to quickly get file Versions or unique wid Type diversity.
- Feature: Get number's digits and 10th power exponent up to the specified number of significant digits.
- Add: Describe BSD license in dialog with checkbox to not show again.
- Feature: Permanent user preferences (with related get, rm and set -functionality).
- Feature: Wrapper for msgbox with auto-enabled TeX text enrichment using mytextwrap.
- Add helper function to mask automatically bad fitting results or near noise results.
- New feature to abort file reading by the given error criteria.
- New feature to read file Version (quickly without loading the whole file into memory).
- Added skip_Data_criteria_for_obj to customize (and speedup) the file reading for specific needs.
- Add: Example of configuring permanent toolbox user preferences.
- Add: Example of plotting scalebar and marking data positions on each other.
- Add: Scripts to quickly open the main and New Issue pages at GitLab.
- New wip-class properties: OnWriteRemoveViewers and OnWriteRemoveDuplicateTransformations.
- New '-outliers'-option to mark outliers in the image. @wid/unpattern_video_stitching_helper.m
- (1) Allow A's and u's search special characters Å's (U+00C5) and µ's (U+00B5) in units. (2) Fix ForceDataUnit usage issues and utilize its changes better.
- (1) New destroy_duplicate_Transformations wip-class method. (2) New related helper functions to get linked wits (to wid-objects) and owner ids (of wit-objects).
- Add copy_Others_if_shared_and_unshare to wid-class.
- Add mtrapz-functionality for fit_lineshape_automatic_guess.
- Short note for future on how to improve the window filtering algorithm.

### Changed
- For MATLAB R2019b or newer: Replace Java-based GUI with HTML5-based GUI, fixing JAVACOMPONENT warnings. For example, [Project Manager][1.2.0,C1] now uses [HTML5-based JList-like code][1.2.0,C2] to create its window.
- Allow special the multiple-dashed strings for 'varargin dashed string parsers' under the 'helper' folder. Usage examples of double-dashed string options.
- Permanently remember the latest folder in the wit_io's file browsing ui.
- Make wit-class basic functionality Octave-compatible.
- Improve regexp renaming with data listing
- Remove waitbar in '-nopreview'-mode.
- Enable manager -Type and -SubType with multiple inputs and added some usage examples.
- Moved the developer's tools under 'dev' folder and renamed them to have 'dev'-prefix.
- Renamed the toolbox setup functions to have 'wit_io'-prefixes. Better names for alphabetically ordered file listing.
- Change: New Tex-enriched dialogs with wit_io_msgbox.
- Added tag 'wit_io_project_manager_gcf' to find manager's main window handle.
- Update: New screenshot with updated features like uihtml-based gui.
- Update: Latest version of the 3rd party code 'export_fig'.
- Doc: New changelog and license badges to README.md.
- Renamed wid-class Links to LinksToOthers and added LinksToThis.
- Add copying of IDLists. @wid/copy_LinksToOthers.m
- From now on, *.wip writing removes all the Viewer windows (shown on the WITec software side). This avoids possible corruption of modified files, because wit_io mostly ignores Viewers. Set wip-object's OnWriteResetViewers-property to false to disable this.
- Now 'crop' properly copies shared Transformations and modifies their unshared versions.
- Simplified the guessing procedure. Fixed few lurking bugs. Added assumptions. helper/fitting/fit_lineshape_automatic_guess.m

[1.2.0,C1]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wip/manager.m
[1.2.0,C2]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/icons/uihtml_JList.html

### Deprecated
- Supersede reset_Viewers of wip-class by [destroy_all_Viewers][1.2.0,D1].

[1.2.0,D1]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wip/destroy_all_Viewers.m

### Removed
- Some dependencies on Image Processing Toolbox.
- Remove unintentional dependency on Statistics and Machine Learning Toolbox.
- Remove unused storeState- and restoreState-functions of wip-class. From now on, rely on the LIFO-concept push- and pop-functions.

### Fixed
- @wid/wid_Data_get_Bitmap.m and @wid/wid_Data_set_Bitmap.m: For **v5** files, add bitmap write/read row-padding to nearest 4-byte boundary.
- @wip/interpret.m: Prioritize Standard Unit search first and only then widen the search. Removed unnecessary ()-brackets around Standard Unit searches.
- E_v5.wip: Fix corrupted TDSpaceTransformations and update affected examples.
- @wid/crop.m and @wid/crop_Graph.m: Properly handles shared transformations now.
- The file browsing GUI is now case-insensitive to *.wid and *.wip file extensions even though the file system is case-sensitive.
- @wid/unpattern_video_stitching_helper.m: Fix error when no working solution can exist.
- @wid/spatial_average.m: Properly updates TDSpaceTransformations now.
- S_rename_by_regexprep.m: Properly gets uifigure handle now although usage is limited by MATLAB R2019b's 'inputdlg's forced uifigure modality'-bug.
- helper/fitting/fit_lineshape_arbitrary.m: Properly handles all-nan-valued case now.
- helper/fitting/fun_lineshape_voigtian.m: Validity meticulously checked and alternatives considered. Fix pure Gaussian issues.
- Fix typos causing bugs.

[1.2.0,F1]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wip/destroy_all_Viewers.m

### Performance
- @wid/wid_SubType_get.m: Disable unused 'Volume'-feature due to major performance bottleneck.
- @wip/read_Version.m: Speedup using @wit/read.m's new skip_Data_criteria_for_obj-feature.
- helper/fitting/bw2lines.m: Reduce computation burden when using only the first output argument.
- helper/dim_size_consistent_repmat.m: Remove cellfun's and reduced use of cells to improve performance.
- helper/fitting/jacobian_helper.m and helper/fitting/fit_lineshape_arbitrary.m: Add usePrevCstd to fix performance issue in loops with changing data dimensions.



## [1.1.2] - 2019-08-08

### Added
- New convenient [toolbox installer][1.1.2,A1] (for MATLAB R2014b or newer).
- New [example case 5][1.1.2,A2] (and [related functionality][1.1.2,A3]) demonstrating Video Stitching image unpatterning. It is noteworthy that [its documentation][1.1.2,A4] describes dozens of extra customization options.
- [helper/clever_statistics_and_outliers.m][1.1.2,A5]: Support to multiple dims input with an ability to negate the selection with negative values. Fix the known bug cases.
- Allow [manager][1.1.2,A6]-calls for wid objects like previously for wip objects. This can be used to quickly glance through the wid objects and see their corresponding index value.
- New [varargin dashed string parsers][1.1.2,A7] under the [helper][1.1.2,A8] folder.
- [@wid/crop.m][1.1.2,A9]: Add isDataCropped-feature and validate inputs.
- Add LIFO (first in = push, last out = pop) concept to wip-class to simplify all the state-related code.
- New memory conservative way to generate indices via [helper/generic_sub2ind.m][1.1.2,A10], merging calls to ndgrid, sub2ind and cast. It can be customized with extra options: '-isarray', '-nobsxfun', '-truncate', '-replace', '-mirror', '-circulate'.
- New [helper/rolling_window_analysis.m][1.1.2,A11]-function that is used by the Video Stitching image unpatterning code.
- New [shell script][1.1.2,A12] to merge release to master.

[1.1.2,A1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/wit_io.mltbx
[1.1.2,A2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/EXAMPLE%20cases/E_05_unpattern_video_stitching.m
[1.1.2,A3]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/@wid/unpattern_video_stitching.m
[1.1.2,A4]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/@wid/unpattern_video_stitching_helper.m
[1.1.2,A5]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/helper/clever_statistics_and_outliers.m
[1.1.2,A6]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/@wid/manager.m
[1.1.2,A7]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/helper/varargin_dashed_str.m
[1.1.2,A8]: https://gitlab.com/jtholmi/wit_io/-/tree/v1.1.2/helper
[1.1.2,A9]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/@wid/crop.m
[1.1.2,A10]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/helper/generic_sub2ind.m
[1.1.2,A11]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/helper/rolling_window_analysis.m
[1.1.2,A12]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/git_release_to_master.sh

### Changed
- Notation change for wid, wip and wit objects. For instance, C_wid, C_wip, C_wit and HtmlNames (or n) are now O_wid, O_wip, O_wit and O_wid_HtmlNames, respectively.
- [helper/fitting/fit_lineshape_arbitrary.m][1.1.2,C1]: Verbose iteration progress by showing total and delta sum of squared residuals. This can be disabled by providing extra input '-silent'.
- [S_rename_by_regexprep.m][1.1.2,C2]: Verbose progress in Command Window.
- Remove last '\n' from TDText plot's clipboard string.
- [README.md][1.1.2,C3]: Update Title and Background. Generalize Cite As. Remove typos. Change absolute links to relative links.

[1.1.2,C1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/helper/fitting/fit_lineshape_arbitrary.m
[1.1.2,C2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/SCRIPT%20cases/S_rename_by_regexprep.m
[1.1.2,C3]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/README.md

### Fixed
- [helper/fitting/fit_lineshape_arbitrary.m][1.1.2,F1]: Fix '-lowOnMemory' error.
- Fix typos causing bugs.

[1.1.2,F1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/helper/fitting/fit_lineshape_arbitrary.m



## [1.1.1] - 2019-06-25

### Added
- Example cases for [spectral stitching][1.1.1,A1] and [data cropping][1.1.1,A2].
- Interactive scripts to [rename datas by regexprep][1.1.1,A3] and [normalize spectra][1.1.1,A4].
- Notes on improving the arbitrary fitting algorithm in the future.
- [load_or_addpath_permanently.m][1.1.1,A5]: Allow toolbox and its subfolders to be added non-permanently.

[1.1.1,A1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.1/EXAMPLE%20cases/E_04_stitch_spectra.m
[1.1.1,A2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.1/EXAMPLE%20cases/E_02_C_crop_data.m
[1.1.1,A3]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.1/SCRIPT%20cases/S_rename_by_regexprep.m
[1.1.1,A4]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.1/SCRIPT%20cases/S_divide_by_local_max.m
[1.1.1,A5]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.1/load_or_addpath_permanently.m

### Changed
- More and simpler [example cases][1.1.1,C1].
- Shorter [example][1.1.1,C1] and [script][1.1.1,C2] names for improved [Tab-key completion][1.1.1,C3] experience in MATLAB's Command Window.
- Replace zip files with folders in the [icons][1.1.1,C4] folder for MATLAB File Exchange compatibility.
- [@wid/get_HtmlName.m][1.1.1,C5]: Use small icons for wid objects in Workspace and larger for wid objets in Project Manager.
- Rename all wid-class reduce-prefixed functions as crop for consistency with WITec software.
- [@wid/crop.m][1.1.1,C6]: Accept variable number of inputs. Fix TDSpaceTransformation error.
- Update [README.md][1.1.1,C7] links and citation.

[1.1.1,C1]: https://gitlab.com/jtholmi/wit_io/-/tree/v1.1.1/EXAMPLE%20cases
[1.1.1,C2]: https://gitlab.com/jtholmi/wit_io/-/tree/v1.1.1/SCRIPT%20cases
[1.1.1,C3]: https://www.mathworks.com/company/newsletters/articles/avoiding-repetitive-typing-with-tab-completion.html
[1.1.1,C4]: https://gitlab.com/jtholmi/wit_io/-/tree/v1.1.1/icons
[1.1.1,C5]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.1/@wid/get_HtmlName.m
[1.1.1,C6]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.1/@wid/crop.m
[1.1.1,C7]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.1/README.md

### Fixed
- Fix 'ID of Data Object "..." is 0!'-issue at WITec software with  generated *.WID files by enforcing all IDs to int32, required by WITec software.
- Fix the license texts.
- [helper/get_unique_names.m][1.1.1,F1]: Fix cell array size issues.
- [git_develop_to_release.sh][1.1.1,F2]: Add git mergetool to resolve conflicts before proceeding.

[1.1.1,F1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.1/helper/get_unique_names.m
[1.1.1,F2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.1/git_develop_to_release.sh



## [1.1.0] - 2019-04-17

### Added
- New [spectral stitching -feature][1.1.0,A1] for the TDGraph wid objects.
- Support to MATLAB R2011a version.
- Support to STT==2 (polynomial transformation) case in TDSpectralTransformation.
- New test files for the 'ID of Data Object "..." is 0!'-issue.
- Add [git bash script][1.1.0,A2] for semi-automated merging.
- New 'DEVELOP'-folder to 'develop'-branch for any experimental code.

[1.1.0,A1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.0/@wid/spectral_stitch.m
[1.1.0,A2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.0/git_develop_to_release.sh

### Changed
- Improve the icon PDF compatibility by removing the SVG filter effects.
- Improve initial values of [newly created TDSpaceTransformations][1.1.0,C1].
- Exclude all .git folders in the [addpath][1.1.0,C2]- and [rmpath][1.1.0,C3]-functions.

[1.1.0,C1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.0/@wid/new_Transformation_Space.m
[1.1.0,C2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.0/load_or_addpath_permanently.m
[1.1.0,C3]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.0/unload_or_rmpath_permanently.m

### Removed
- Remove dependencies on MATLAB R2014a version.
- Remove dependencies on Statistics and Machine Learning Toolbox.

### Fixed
- Improve support to network drive working.
- Fix wit-class file reading errors in older MATLAB versions.
- Fix TDText plot's 'copy selection to clipboard'-feature.
- Fix usage of get_Root_Version in wid-class.
- Improve documentations of some example cases, the arbitrary fitting algorithm and the formatting readme.



## [1.0.4] - 2019-04-02



[Unreleased]: https://gitlab.com/jtholmi/wit_io/-/compare/v1.2.0...develop
[1.2.0]: https://gitlab.com/jtholmi/wit_io/-/compare/v1.1.2...v1.2.0
[1.1.2]: https://gitlab.com/jtholmi/wit_io/-/compare/v1.1.1...v1.1.2
[1.1.1]: https://gitlab.com/jtholmi/wit_io/-/compare/v1.1.0...v1.1.1
[1.1.0]: https://gitlab.com/jtholmi/wit_io/-/compare/v1.0.4...v1.1.0
[1.0.4]: https://gitlab.com/jtholmi/wit_io/-/tree/v1.0.4