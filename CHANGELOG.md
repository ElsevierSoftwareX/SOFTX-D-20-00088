# Changelog
All notable changes to this project will be documented in this file.

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



## [1.2.0] - 2020-03-10

- Fixed error due to typo.
- Made wit-class basic functionality Octave-compatible.
- Made wit-class basic functionality Octave-compatible.
- Disabled unused 'Volume'-feature due to major performance bottle-neck.
- Improved Octave-compatible code. Fix preallocation typo of 'ones' by 'zeros'.
- Fixed indenting and fixed Octave's constructor error.
- Call to cat(2, ...) replaced by horzcat for Octave-compatibility.
- Add tester function to recognize Octave instance.
- Add Octave-compatible horzcat, vertcat and reshape.
- Fix horzcat and vertcat "empty-object-array"-bug in Octave.
- Fix typo in horzcat and vertcat.
- Fix error-causing typo.
- Fix inconsistency with new MATLAB versions.
- Fix corrupted written files due to same-Id-bug (due to Octave-compatible code).
- Demo to show measurement regions in the microscope image.
- Fix error when no working solution can exist.
- Improve regexp renaming with data listing
- Remove waitbar in '-nopreview'-mode.
- Enable manager -Type and -SubType with multiple inputs and added some usage examples.
- Fix missing img height and width, required by R2019b or newer.
- Use nargout to reduce computation burden if only using first output argument.
- Removed cellfun's and reduced use of cells to improve performance.
- Add mtrapz-functionality for fit_lineshape_automatic_guess.
- Added support to NaN valued inputs.
- Added usePrevCstd to fix performance issue in loops with changing data dimensions.
- Handled all-nan-valued cases and fixed jacobian_helper performance issue.
- Simplified the guessing procedure. Fixed few lurking bugs. Added assumptions.
- Added helper function to mask automatically bad fitting results or near noise results.
- Made wip.read to remember the latest folder being browsed.
- First pilot implementation of HTML5-based listbox in order to replace the... 
- Pilot version to replace Java with HTML5 (for R2019b or newer).
- First completed and working version of HTML5 listbox implementation. Updated the documentation.
- Updated documentation, polished code, fixed bug and corrected misunderstanding... 
- Better numerical stability at extremes. Validity double-checked. Fixed pure Gaussian issues.
- Restored the original approach due to superior numerical stability. The... 
- Added special feature for the multiple-dashed strings.
- Fixed uifigure's header (and commented on sending a R2019b bug report on... 
- Remember the latest save folder.
- Added tag 'wit_io_project_manager_gcf' to find manager's main window handle.
- Finalized the show_Position functionality and added 'position'-option to plot-function.
- Test file for uihtml_JList.html.
- New '-outliers'-option to mark outliers in the image.
- show_Position's 'no output'-bug fixed.
- Usage examples of double-dashed string options.
- Added the missing space transformation update.
- New feature: Items with 'noid'-class cannot be selected.
- Finalized uihtml-implemenation for R2019b or newer. Some code cleanup.
- Bug fix (for v5 *.wip): Added bitmap write/read row-padding to nearest 4-byte boundary.
- Added regexp and search functions for ancestors.
- Renamed wid-class Links to LinksToOthers and added LinksToThis.
- Added copying of IDLists.
- Minuscule notation fix.
- Fixed error due to a copy-paste typo.
- (1) Allow A's and u's search special characters Å's (U+00C5) and µ's (U+00B5)... 
- (1) New destroy_duplicate_Transformations wip-class method. (2) New related... 
- Reverted to uicontrol's slider due to the upcoming removal of JAVACOMPONENT... 
- New feature to abort file reading by the given error criteria.
- New feature to read file Version (quickly without loading the whole file into memory).
- Added short notes on (1) usage, (2) Symbolic Math Toolbox requirement and (3)... 
- Added note on Image Processing Toolbox requirement.
- Added note on Image Processing Toolbox requirement.
- Removed the dependency on Statistics and Machine Learning Toolbox.
- Removed the dependency on Image Processing Toolbox.
- Removed the dependency on 'padarray' of Image Processing Toolbox.
- Added special plot cases, where areas look like lines and lines look like points.
- Removed the dependency on 'ordfilt2' of Image Processing Toolbox.
- Fixed some document typos.
- Minuscule notation update.
- Minuscule reduction of calculus.
- Removed the dependency on 'stdfilt' of Image Processing Toolbox.
- Short note for future on how to improve the window filtering algorithm.
- Added experimental support to v0-v4 after observing v2 minuscule differences... 
- Combined the legacy version (v1-v5) implementations, because WITec software... 
- Accidentally committed.
- Moved the developer's tools under 'dev' folder and renamed them to have 'dev'-prefix.
- Renamed the toolbox setup functions to have 'wit_io'-prefixes.
- Added skip_Data_criteria_for_obj to customize (and speedup) the file reading for specific needs.
- Fixed typos in new function definitions.
- Speedup using wit-class read's new skip_Data_criteria_for_obj-feature.
- New dev tools to quickly get file Versions or unique wid Type diversity.
- Added that TDLUTTransformation is not in legacy versions v0,v2.
- From now on, *.wip writing removes all the Viewer windows (shown on the WITec... 
- Fixed error due to a missing variable.
- (1) Added copy_Others_if_shared_and_unshare to wid-class. (2) Fixed some typos.
- New wip-class properties: OnWriteRemoveViewers and OnWriteRemoveDuplicateTransformations.
- (1) Now 'crop' properly copies shared Transformations and modifies their...
- Feature: Get number's digits and 10th power exponent up to the specified number of significant digits.
- (1) Rename: From show_Position to plot_position and plot's '-position' to '-positions'. (2) Add: Axes as input to anonymous functions.
- Fix: Prioritize Standard Unit search first and only then widen the search.
- Fix: Removed unnecessary ()-brackets around Standard Unit searches.
- Feature: Customizable scalebar plotting on images.
- Fix: Typo in -Thickness configuration.
- Add: Separate helper functions for plot_position.
- Fix: Show scalebar only when -scalebar stated.
- Add: Describe BSD license in dialog with checkbox to not show again.
- Rename: Better names for alphabetically ordered file listing.
- (1) Feature: Permanent user preferences (with related get, rm and set -functionality). (2) Update: Its usage in wip-class constructor.
- Add: Accept a struct of pref-value pairs.
- Update: User preference 'license_dialog' is now converted to boolean.
- Add: Is-function for permanent user preferences.
- Feature: Wrapper for msgbox with auto-enabled TeX text enrichment.
- (1) Deprecate: reset_Viewers replaced by destroy_all_Viewers. (2) Rename: OnWrite-properties. (3) Remove: storeState. (4) Update: LIFO functions.
- Doc: New changelog and license badges.
- Fix: Cancel the msgbox's automatic text wrapping, which caused problems with Tex-enriched texts.
- Fix: Typo causing an error.
- Feature: use mytextwrap in wit_io_msgbox for Tex-enriched text wrapping.
- Fix: Replaced the flawed text wrapping algorithm with a new more robust approach.
- Fix: To avoid weird datatype icon listings in Project Manager, force-minimized the first column width.
- Change: New Tex-enriched dialogs with wit_io_msgbox.
- Add: Example of configuring permanent toolbox user preferences.
- Add: Example of plotting scalebar and marking data positions on each other.
- Fix: enable single-line text wrapping.
- (1) Change: From fixed input to variable input. (2) Doc: Documented the extra inputs. (3) Fix: Setting of the dialog WindowStyle. (4) Fix: Anomalous dialog box width (with respect to the text width).
- (1) Fix: Rewrote the GUI positioning code to solve all the remaining issues. (2) Fix: -TextWrapping 2nd input 'Units' works now as expected.
- Add: Scripts to quickly open the main and New Issue pages at GitLab.
- Feature: Remember the latest browsed folder permanently and store it to 'latest_folder'-preference.
- Feature: Figure input now optional in 'plot_position' and 'plot_scalebar' and also accept Axes input.
- Fix: Handle no input case properly.
- Fix: Handle shared transformation in 'crop_Graph' like in 'crop'.
- Change: Better colored positions through fewer indices.
- (1) Fix: E_v5.wip corrupted space transformations (and update changed examples). (2) Fix: Lower-case the E_v5.wip file extension due to the errors in case-sensitive file systems.
- Deprecated: Replaced by E_v5.wip.
- Update: New screenshot with updated features like uihtml-based gui.
- Fix: File reading gui now include all the case-sensitive file extension permutations.



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