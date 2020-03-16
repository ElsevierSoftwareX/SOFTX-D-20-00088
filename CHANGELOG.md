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

[//]: # "Changelog entry should add value with minimized implementation details and concisely provide descriptive context on where and why the change was made or how it benefits the user."



## [Unreleased]



## [1.2.0] - 2020-03-13

### Added
- Add this changelog to the project.
- Experimental support to legacy file versions **v0&ndash;v4**, all of which will be read and written technically as **v5** due to the way WITec software ignores unused and unrelated WIT-tags.
- New example case on [plotting scalebar and marking measurement locations with respect to each other][1.2.0,A1] using updated [plot][1.2.0,A2] and new [plot_position][1.2.0,A3] and [plot_scalebar][1.2.0,A4] functions.
- New example case on [configuring toolbox by permanent user preferences][1.2.0,A5] using new [wit_io_pref_get][1.2.0,A6], [wit_io_pref_is][1.2.0,A7], [wit_io_pref_rm][1.2.0,A8] and [wit_io_pref_set][1.2.0,A9] functions.
- Enrich help dialogs of [all example cases][1.2.0,A10] with TeX content using new [wit_io_msgbox][1.2.0,A11] and [mytextwrap][1.2.0,A12] functions.
- Feature to [destroy duplicate Transformations][1.2.0,A13] in the project. Update example case on [data cropping][1.2.0,A14].
- New wip-class [write][1.2.0,A15] behaviour via OnWriteDestroyAllViewers and OnWriteDestroyDuplicateTransformations states. New related functions to get linked wits (to wid-objects) and owner ids (of wit-objects).
- Features to [abort wit file reading or skip file contents by the given criterias][1.2.0,A16]. This can be used to customize and speedup the file reading for specific needs. For example, [file Version reading][1.2.0,A17] is now much quicker because it only loads small portion of the file into memory.
- Scripts to quickly open the main and New Issue pages at GitLab: [wit_io_gitlab][1.2.0,A18] and [wit_io_gitlab_new_issue][1.2.0,A19].
- [@wid/unpattern_video_stitching_helper.m][1.2.0,A20]: New '-outliers'-option to provide outliers in the image.
- New helper function, [mask_bad_results_and_noise.m][1.2.0,A21] to mask automatically bad fitting results or near noise results.
- Add [regexp][1.2.0,A22] and [search][1.2.0,A23] functions for wit object ancestors.
- New [dev tools][1.2.0,A24] to quickly get [file Versions][1.2.0,A25] or [unique wid Type diversity][1.2.0,A26].
- Add clear notes on MATLAB toolbox dependencies in each related file.
- Short note for future on how to improve the window filtering algorithms [mynanmaxfilt2.m][1.2.0,A27] and [mynanstdfilt2.m][1.2.0,A28].

[1.2.0,A1]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/EXAMPLE%20cases/E_02_D_plot_data_position_and_scalebar.m
[1.2.0,A2]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wid/plot.m
[1.2.0,A3]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wid/plot_position.m
[1.2.0,A4]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wid/plot_scalebar.m
[1.2.0,A5]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/EXAMPLE%20cases/E_01_D_permanent_user_preferences.m
[1.2.0,A6]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/wit_io_pref_get.m
[1.2.0,A7]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/wit_io_pref_is.m
[1.2.0,A8]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/wit_io_pref_rm.m
[1.2.0,A9]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/wit_io_pref_set.m
[1.2.0,A10]: https://gitlab.com/jtholmi/wit_io/-/tree/develop/EXAMPLE%20cases
[1.2.0,A11]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/wit_io_msgbox.m
[1.2.0,A12]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/helper/plotting/mytextwrap.m
[1.2.0,A13]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wip/destroy_duplicate_Transformations.m
[1.2.0,A14]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/EXAMPLE%20cases/E_02_C_crop_data.m
[1.2.0,A15]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wip/write.m
[1.2.0,A16]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wit/read.m
[1.2.0,A17]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wip/read_Version.m
[1.2.0,A18]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/wit_io_gitlab.m
[1.2.0,A19]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/wit_io_gitlab_new_issue.m
[1.2.0,A20]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wid/unpattern_video_stitching_helper.m
[1.2.0,A21]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/helper/fitting/mask_bad_results_and_noise.m
[1.2.0,A22]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wit/regexp_ancestors.m
[1.2.0,A23]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wit/regexp_ancestors.m
[1.2.0,A24]: https://gitlab.com/jtholmi/wit_io/-/tree/develop/dev
[1.2.0,A25]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/dev/dev_get_Versions.m
[1.2.0,A26]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/dev/dev_get_unique_wid_Types.m
[1.2.0,A27]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/helper/mynanmaxfilt2.m
[1.2.0,A28]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/helper/mynanstdfilt2.m

### Changed
- For MATLAB R2019b or newer: Replace Java-based GUI with HTML5-based GUI, fixing JAVACOMPONENT warnings. For example, [Project Manager][1.2.0,C1] now uses [HTML5-based JList-like code][1.2.0,C2] to create its window.
- Allow special the multiple-dashed strings for [varargin dashed string parsers][1.2.0,C3] under the [helper][1.2.0,C4] folder. Updated all example cases, where extra arguments were passed to '-manager' via [wip.read][1.2.0,C5].
- Example cases now describe BSD license in dialog with checkbox to not show again.
- Permanently remember the latest folder in the wit_io's file browsing ui.
- Rename [wid][1.2.0,C6]-class Links-property to LinksToOthers and add LinksToThis-property. Rename related copy_Links to [copy_LinksToOthers][1.2.0,C7] (and add copying of IDLists).
- Make [wit][1.2.0,C8]-class basic functionality Octave-compatible.
- [S_rename_by_regexprep.m][1.2.0,C9]: Improve regexp renaming with data listing. Usage is limited in MATLAB R2019b due to its 'inputdlg's forced uifigure modality'-bug.
- [@wip/manager.m][1.2.0,C10]: Remove waitbar in '-nopreview'-mode. Allow -Type and -SubType with multiple inputs. Add tag 'wit_io_project_manager_gcf' to find its latest main window handle (whether figure or uifigure).
- [helper/fitting/fit_lineshape_automatic_guess.m][1.2.0,C11]: (1) Simplify the process. (2) More robust lineshape center estimation by integration via new [mtrapz][1.2.0,C12] function. (3) Fix few lurking bugs. (4) Notes on assumptions.
- From now on, *.wip writing removes all the Viewer windows (shown on the WITec software side). This avoids possible corruption of modified files, because wit_io mostly ignores Viewers. Set wip-object's OnWriteDestroyAllViewers-property to false to disable this.
- Move the toolbox developer's functions under the [dev][1.2.0,C13] folder and give them 'dev'-prefix.
- Rename the [toolbox's main folder][1.2.0,C14] functions to have 'wit_io'-prefix and better names for alphabetically ordered file listing.
- Upload latest version of the 3rd party code [export_fig][1.2.0,C15].
- [example.png][1.2.0,C16]: New screenshot with updated features like uihtml-based gui.
- [README.md][1.2.0,C17]: New changelog and license badges.

[1.2.0,C1]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wip/manager.m
[1.2.0,C2]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/icons/uihtml_JList.html
[1.2.0,C3]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/helper/varargin_dashed_str.m
[1.2.0,C4]: https://gitlab.com/jtholmi/wit_io/-/tree/develop/helper
[1.2.0,C5]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wip/read.m
[1.2.0,C6]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wid/wid.m
[1.2.0,C7]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wid/copy_LinksToOthers.m
[1.2.0,C8]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wit/wit.m
[1.2.0,C9]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/SCRIPT%20cases/S_rename_by_regexprep.m
[1.2.0,C10]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wip/manager.m
[1.2.0,C11]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/helper/fitting/fit_lineshape_automatic_guess.m
[1.2.0,C12]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/helper/mtrapz.m
[1.2.0,C13]: https://gitlab.com/jtholmi/wit_io/-/tree/develop/dev
[1.2.0,C14]: https://gitlab.com/jtholmi/wit_io/-/tree/develop
[1.2.0,C15]: https://gitlab.com/jtholmi/wit_io/-/tree/develop/helper%2F3rd%20party%2Fexport_fig
[1.2.0,C16]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/example.png
[1.2.0,C17]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/README.md

### Deprecated
- Supersede reset_Viewers of wip-class by [destroy_all_Viewers][1.2.0,D1].

[1.2.0,D1]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wip/destroy_all_Viewers.m

### Removed
- Some dependencies on Image Processing Toolbox.
- Remove unintentional dependency on Statistics and Machine Learning Toolbox.
- Remove unused storeState- and restoreState-functions of wip-class. From now on, rely on the LIFO-concept push- and pop-functions.

### Fixed
- [@wid/wid_Data_get_Bitmap.m][1.2.0,F1] and [@wid/wid_Data_set_Bitmap.m][1.2.0,F2]: For **v5** files, add bitmap write/read row-padding to nearest 4-byte boundary.
- [@wip/interpret.m][1.2.0,F3]: Prioritize Standard Unit search first and only then widen the search. Removed unnecessary ()-brackets around Standard Unit searches.
- [E_v5.wip][1.2.0,F4]: Fix corrupted TDSpaceTransformations and update affected examples.
- [@wid/crop.m][1.2.0,F5] and [@wid/crop_Graph.m][1.2.0,F6]: Properly copy shared transformations and modifies their unshared versions using new [copy_Others_if_shared_and_unshare][1.2.0,F7] function.
- The file browsing GUI is now case-insensitive to *.wid and *.wip file extensions even though the file system is case-sensitive.
- [@wid/unpattern_video_stitching_helper.m][1.2.0,F8]: Fix error when no working solution can exist.
- [@wid/spatial_average.m][1.2.0,F9]: Properly updates TDSpaceTransformations now.
- [helper/fitting/fit_lineshape_arbitrary.m][1.2.0,F10]: Properly handles all-nan-valued case now.
- [helper/fitting/fun_lineshape_voigtian.m][1.2.0,F11]: Validity meticulously checked and alternatives considered. Fix pure Gaussian issues.
- Fix wip.ForceDataUnit usage issues and utilize its changes better.
- Fix typos causing bugs.

[1.2.0,F1]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wid/wid_Data_get_Bitmap.m
[1.2.0,F2]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wid/wid_Data_set_Bitmap.m
[1.2.0,F3]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wip/interpret.m
[1.2.0,F4]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/EXAMPLE%20cases/E_v5.wip
[1.2.0,F5]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wid/crop.m
[1.2.0,F6]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wid/crop_Graph.m
[1.2.0,F7]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wid/copy_Others_if_shared_and_unshare.m
[1.2.0,F8]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wid/unpattern_video_stitching_helper.m
[1.2.0,F9]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wid/spatial_average.m
[1.2.0,F10]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/helper/fitting/fit_lineshape_arbitrary.m
[1.2.0,F11]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/helper/fitting/fun_lineshape_voigtian.m

### Performance
- [@wid/wid_SubType_get.m][1.2.0,P1]: Disable unused 'Volume'-feature due to major performance bottleneck.
- [@wip/read_Version.m][1.2.0,P2]: Speedup using @wit/read.m's new skip_Data_criteria_for_obj-feature.
- [helper/fitting/bw2lines.m][1.2.0,P3]: Reduce computation burden when using only the first output argument.
- [helper/dim_size_consistent_repmat.m][1.2.0,P4]: Remove cellfun's and reduced use of cells to improve performance.
- [helper/fitting/jacobian_helper.m][1.2.0,P5] and [helper/fitting/fit_lineshape_arbitrary.m][1.2.0,P6]: Add usePrevCstd to fix performance issue in loops with changing data dimensions.

[1.2.0,P1]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wid/wid_SubType_get.m
[1.2.0,P2]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wip/read_Version.m
[1.2.0,P3]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/helper/fitting/bw2lines.m
[1.2.0,P4]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/helper/dim_size_consistent_repmat.m
[1.2.0,P5]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/helper/fitting/jacobian_helper.m
[1.2.0,P6]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/helper/fitting/fit_lineshape_arbitrary.m



## [1.1.2] - 2019-08-08

### Added
- New convenient [toolbox installer][1.1.2,A1] (for MATLAB R2014b or newer).
- New [example case][1.1.2,A2] (and [related functionality][1.1.2,A3]) demonstrate Video Stitching image unpatterning. It is noteworthy that [its documentation][1.1.2,A4] describes dozens of extra customization options.
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