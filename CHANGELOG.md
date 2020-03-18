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
- Add this `CHANGELOG.md` file to the GitLab project.
- Add experimental support to legacy file `Versions` **v0 &ndash; v4** via **v5**, enabled by the way the WITec software ignores the unused `wit` tag objects.
- Add example case on [plotting scalebar and marking measurement positions on one other][1.2.0,A1] using either new `'-scalebar'` and `'-position'` options of [`@wid/plot`][1.2.0,A2] or new [`@wid/plot_scalebar`][1.2.0,A3] and [`@wid/plot_position`][1.2.0,A4] functions.
- Add example case on [configuring toolbox by permanent user preferences][1.2.0,A5] using new [`wit_io_pref_get`][1.2.0,A6], [`wit_io_pref_is`][1.2.0,A7], [`wit_io_pref_rm`][1.2.0,A8] and [`wit_io_pref_set`][1.2.0,A9] functions. For example, permanently remember the latest folder in the **wit_io**'s file browsing UI.
- Add TeX-enriched help dialogs to [all example cases][1.2.0,A10] using new [`wit_io_msgbox`][1.2.0,A11] and [`mytextwrap`][1.2.0,A12] functions.
- Add ability to [destroy duplicate Transformations][1.2.0,A13] in the opened projects. Update affected example case on [data cropping][1.2.0,A14].
- `wip`-class: Add `OnWrite`-tasks to [**\*.wip** file writing][1.2.0,A15] via new properties `OnWriteDestroyAllViewers` (`= true` by default) and `OnWriteDestroyDuplicateTransformations` (`= false` by default). The former avoids possible corruption of modified **\*.wip** files, because **wit_io** does not update the file tree `Viewer`-section.
- `wit`-class: Add features to [abort `wit` tag file reading or skip its contents by the given criterias][1.2.0,A16] in order to customize and speed up the file reading for specific needs. For example, [file `Version` reading][1.2.0,A17] is now much quicker because it only loads small portion of the file into memory.
- Add scripts to quickly open the main and New Issue pages at GitLab: [`wit_io_gitlab`][1.2.0,A18] and [`wit_io_gitlab_new_issue`][1.2.0,A19].
- [`@wid/unpattern_video_stitching_helper`][1.2.0,A20]: Add new `'-outliers'` option to provide known outliers in the image to the algorithm.
- Add ability to automatically mask bad fitting results or near noise results using new [`mask_bad_results_and_noise`][1.2.0,A21] helper function.
- `wit`-class: Add ability to search `wit` tag object ancestors using new [`regexp_ancestors`][1.2.0,A22] and [`search_ancestors`][1.2.0,A23] functions.
- Add [developer's functions][1.2.0,A24] to quickly get [`Versions`][1.2.0,A25] or [unique `wid`-class `Types`][1.2.0,A26] of multiple files.
- Add notes on MATLAB toolbox dependencies in the beginning of each dependent file.

[1.2.0,A1]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/EXAMPLE%20cases/E_02_D_plot_data_position_and_scalebar.m
[1.2.0,A2]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wid/plot.m
[1.2.0,A3]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wid/plot_scalebar.m
[1.2.0,A4]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wid/plot_position.m
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
[1.2.0,A23]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wit/search_ancestors.m
[1.2.0,A24]: https://gitlab.com/jtholmi/wit_io/-/tree/develop/dev
[1.2.0,A25]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/dev/dev_get_Versions.m
[1.2.0,A26]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/dev/dev_get_unique_wid_Types.m

### Changed
- For MATLAB R2019b or newer, replace Java-based GUI with HTML5-based GUI, fixing `JAVACOMPONENT` warnings. For example, [`Project Manager`][1.2.0,C1] now uses [HTML5-based JList-like code][1.2.0,C2] to create its window.
- Allow special the multiple-dashed strings for [varargin dashed string parsers][1.2.0,C3] under [helper][1.2.0,C4]-folder. Updated all example cases, where extra arguments were passed to `'-manager'` via [@wip/read][1.2.0,C5].
- Example cases now describe [`BSD license`][1.2.0,C6] in dialog with checkbox to not show again.
- [`wid`][1.2.0,C7]-class: Rename `Links`-property to `LinksToOthers` and add `LinksToThis`-property. Rename related `copy_Links` to [`copy_LinksToOthers`][1.2.0,C8] (and add copying of `IDLists`).
- `wit`-class: Make basic functionality Octave-compatible.
- [`S_rename_by_regexprep`][1.2.0,C9]: Improve regexp renaming with data listing. Usage is limited in MATLAB R2019b due to its `inputdlg's forced uifigure modality`-bug.
- [`@wip/manager`][1.2.0,C10]: (1) Remove waitbar in '-nopreview'-mode. (2) Allow `'-Type'` and `'-SubType'` with multiple inputs. (3) Add tag `'wit_io_project_manager_gcf'` to find its latest main window handle (whether `figure` or `uifigure`).
- [`fit_lineshape_automatic_guess`][1.2.0,C11]: (1) Simplify the process and describe the assumptions. (2) Change to more robust lineshape center estimation by integration via new [`mtrapz`][1.2.0,C12] function.
- Move the toolbox developer's functions under [dev][1.2.0,C13]-folder and give them `dev`-prefix.
- Rename the [toolbox's main folder][1.2.0,C14] functions to have **wit_io**-prefix and better names for alphabetically ordered file listing.
- [`export_fig`][1.2.0,C15]: Upload latest version of this 3rd party code.

[1.2.0,C1]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wip/manager.m
[1.2.0,C2]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/icons/uihtml_JList.html
[1.2.0,C3]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/helper/varargin_dashed_str.m
[1.2.0,C4]: https://gitlab.com/jtholmi/wit_io/-/tree/develop/helper
[1.2.0,C5]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wip/read.m
[1.2.0,C6]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/LICENSE
[1.2.0,C7]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wid/wid.m
[1.2.0,C8]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wid/copy_LinksToOthers.m
[1.2.0,C9]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/SCRIPT%20cases/S_rename_by_regexprep.m
[1.2.0,C10]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wip/manager.m
[1.2.0,C11]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/helper/fitting/fit_lineshape_automatic_guess.m
[1.2.0,C12]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/helper/mtrapz.m
[1.2.0,C13]: https://gitlab.com/jtholmi/wit_io/-/tree/develop/dev
[1.2.0,C14]: https://gitlab.com/jtholmi/wit_io/-/tree/develop
[1.2.0,C15]: https://gitlab.com/jtholmi/wit_io/-/tree/develop/helper%2F3rd%20party%2Fexport_fig

### Deprecated
- `@wip/reset_Viewers`: Supercede by [`@wip/destroy_all_Viewers`][1.2.0,D1].

[1.2.0,D1]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wip/destroy_all_Viewers.m

### Removed
- Remove some dependencies on [`Image Processing Toolbox`][1.2.0,R1].
- Remove unintentional dependency on [`Statistics and Machine Learning Toolbox`][1.2.0,R2].
- `wip`-class: Remove unused `storeState`- and `restoreState`-functions and, from now on, rely on the LIFO-concept `push`- and `pop`-functions.

[1.2.0,R1]: https://www.mathworks.com/products/image.html
[1.2.0,R2]: https://www.mathworks.com/products/statistics.html

### Fixed
- [`@wid/wid_Data_get_Bitmap`][1.2.0,F1] and [`@wid/wid_Data_set_Bitmap`][1.2.0,F2]: For **v5** files, add unimplemented bitmap write/read row-padding to nearest 4-byte boundary.
- [`@wip/interpret`][1.2.0,F3]: Prioritize `Standard Unit` search first and only then widen the search. Removed unnecessary `()`-brackets around `Standard Unit` searches.
- [`E_v5.wip`][1.2.0,F4]: Fix corrupted `TDSpaceTransformations` and update affected example cases.
- [`@wid/crop`][1.2.0,F5] and [`@wid/crop_Graph`][1.2.0,F6]: Properly copy shared transformations and modify their unshared versions using new [`@wid/copy_Others_if_shared_and_unshare`][1.2.0,F7] function.
- The file browsing GUI is now case-insensitive to **\*.wid** and **\*.wip** file extensions even though the file system is case-sensitive.
- [`@wid/unpattern_video_stitching_helper`][1.2.0,F8]: Fix error when no working solution can exist.
- [`@wid/spatial_average`][1.2.0,F9]: Properly update `TDSpaceTransformations` now.
- [`fit_lineshape_arbitrary`][1.2.0,F10]: Properly handle all-`NaN`-valued case now.
- [`fun_lineshape_voigtian`][1.2.0,F11]: Double-check algorithm validity meticulously and consider alternatives. Fix pure Gaussian issues.
- [`fit_lineshape_automatic_guess`][1.2.0,F12]: Fix few lurking bugs.
- Fix `wip`-class `ForceDataUnit`-property usage issues and utilize its changes better.
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
[1.2.0,F12]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/helper/fitting/fit_lineshape_automatic_guess.m

### Performance
- [`@wid/wid_SubType_get`][1.2.0,P1]: Disable unused `'Volume'`-feature due to major performance bottleneck.
- [`@wip/read_Version`][1.2.0,P2]: Speed it up using `@wit/read`'s new `skip_Data_criteria_for_obj`-feature.
- [`bw2lines`][1.2.0,P3]: Reduce computation burden when using only the first output argument.
- [`dim_size_consistent_repmat`][1.2.0,P4]: Remove [`cellfun`][1.2.0,P5]'s and reduce use of cells to improve performance.
- [`jacobian_helper`][1.2.0,P6] and [`fit_lineshape_arbitrary`][1.2.0,P7]: Add `usePrevCstd`-flag to fix performance issue in loops with changing data dimensions.

[1.2.0,P1]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wid/wid_SubType_get.m
[1.2.0,P2]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/@wip/read_Version.m
[1.2.0,P3]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/helper/fitting/bw2lines.m
[1.2.0,P4]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/helper/dim_size_consistent_repmat.m
[1.2.0,P5]: https://www.mathworks.com/help/matlab/ref/cellfun.html
[1.2.0,P6]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/helper/fitting/jacobian_helper.m
[1.2.0,P7]: https://gitlab.com/jtholmi/wit_io/-/blob/develop/helper/fitting/fit_lineshape_arbitrary.m



## [1.1.2] - 2019-08-08

### Added
- Add convenient [toolbox installer][1.1.2,A1] (for MATLAB R2014b or newer).
- Add [example case][1.1.2,A2] (and [related functionality][1.1.2,A3]) to demonstrate Video Stitching image unpatterning. It is noteworthy that [its documentation][1.1.2,A4] describes dozens of extra customization options.
- [`clever_statistics_and_outliers`][1.1.2,A5]: Add support to multiple dims input with an ability to negate the selection with negative values.
- Allow [`manager`][1.1.2,A6]-calls for `wid` objects like previously for `wip` objects. This can be used to quickly glance through the `wid` objects and see their corresponding index value.
- Add [varargin dashed string parsers][1.1.2,A7] under [helper][1.1.2,A8]-folder.
- [`@wid/crop`][1.1.2,A9]: Add `isDataCropped`-feature and validate inputs.
- `wip`-class: Add LIFO (first in = push, last out = pop) concept to simplify all the state-related code.
- Add feature to generate indices via [`generic_sub2ind`][1.1.2,A10], merging calls to `ndgrid`, `sub2ind` and `cast` and being memory conservative. It can be customized with extra options: `'-isarray'`, `'-nobsxfun'`, `'-truncate'`, `'-replace'`, `'-mirror'`, `'-circulate'`.
- Add feature to perform [`rolling window analysis`][1.1.2,A11] that is used by the Video Stitching image unpatterning code.
- Add [git bash script][1.1.2,A12] for semi-automated merging from **release**-tag to **master**-branch.

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
- Change notation for `wid`, `wip` and `wit` objects. For instance, `C_wid`, `C_wip`, `C_wit` (and `HtmlNames` or `n`) are now `O_wid`, `O_wip`, `O_wit` (and `O_wid_HtmlNames`), respectively.
- [`fit_lineshape_arbitrary`][1.1.2,C1]: Change to verbose iteration progress by showing total and delta sum of squared residuals. This can be disabled by providing extra input `'-silent'`.
- [`S_rename_by_regexprep`][1.1.2,C2]: Change to verbose progress in `Command Window`.
- Remove last `'\n'` from the clipboard strings of `TDText` plots.
- [`README.md`][1.1.2,C3]: Update Background and Citation sections.

[1.1.2,C1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/helper/fitting/fit_lineshape_arbitrary.m
[1.1.2,C2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/SCRIPT%20cases/S_rename_by_regexprep.m
[1.1.2,C3]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/README.md

### Fixed
- [`fit_lineshape_arbitrary.m`][1.1.2,F1]: Fix `'-lowOnMemory'` error.
- [`clever_statistics_and_outliers`][1.1.2,F2]: Fix the known bug cases.
- Fix typos causing bugs.

[1.1.2,F1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/helper/fitting/fit_lineshape_arbitrary.m
[1.1.2,F2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/helper/clever_statistics_and_outliers.m



## [1.1.1] - 2019-06-25

### Added
- Add example cases for [spectral stitching][1.1.1,A1] and [data cropping][1.1.1,A2].
- Add interactive scripts to [rename datas by regexprep][1.1.1,A3] and [normalize spectra][1.1.1,A4].
- Add notes on improving the arbitrary lineshape fitting algorithm in the future.
- [`load_or_addpath_permanently`][1.1.1,A5]: Allow toolbox and its subfolders to also be added non-permanently.

[1.1.1,A1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.1/EXAMPLE%20cases/E_04_stitch_spectra.m
[1.1.1,A2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.1/EXAMPLE%20cases/E_02_C_crop_data.m
[1.1.1,A3]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.1/SCRIPT%20cases/S_rename_by_regexprep.m
[1.1.1,A4]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.1/SCRIPT%20cases/S_divide_by_local_max.m
[1.1.1,A5]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.1/load_or_addpath_permanently.m

### Changed
- Rewrite [example cases][1.1.1,C1] with simplicity in mind and split into more files.
- Shorten [example][1.1.1,C1] and [script][1.1.1,C2] case names for improved [Tab-key completion][1.1.1,C3] experience in MATLAB's `Command Window`.
- Replace **\*.zip** files under [`icons`][1.1.1,C4]-folder with folders for MATLAB [`File Exchange`][1.1.1,C5] compatibility.
- [`@wid/get_HtmlName`][1.1.1,C6]: Use small icons for `wid` objects in `Workspace` and larger for `wid` objects in `Project Manager`.
- Rename all `wid`-class `reduce`-prefixed functions as `crop`-prefixed for consistency with the WITec software.
- [`@wid/crop`][1.1.1,C7]: Accept variable number of inputs.

[1.1.1,C1]: https://gitlab.com/jtholmi/wit_io/-/tree/v1.1.1/EXAMPLE%20cases
[1.1.1,C2]: https://gitlab.com/jtholmi/wit_io/-/tree/v1.1.1/SCRIPT%20cases
[1.1.1,C3]: https://www.mathworks.com/company/newsletters/articles/avoiding-repetitive-typing-with-tab-completion.html
[1.1.1,C4]: https://gitlab.com/jtholmi/wit_io/-/tree/v1.1.1/icons
[1.1.1,C5]: https://www.mathworks.com/matlabcentral/fileexchange
[1.1.1,C6]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.1/@wid/get_HtmlName.m
[1.1.1,C7]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.1/@wid/crop.m

### Fixed
- Fix `ID of Data Object "..." is 0!`-issue at the WITec software side with generated **\*.wid** files by enforcing all `IDs` to `int32`, required by the WITec software.
- [`@wid/crop`][1.1.1,F1]: Fix `TDSpaceTransformation` error.
- Fix the license texts.
- [`get_unique_names`][1.1.1,F2]: Fix cell array size issues.
- [`git_develop_to_release.sh`][1.1.1,F3]: Add [`git mergetool`][1.1.1,F4] to resolve conflicts before proceeding with merging.

[1.1.1,F1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.1/@wid/crop.m
[1.1.1,F2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.1/helper/get_unique_names.m
[1.1.1,F3]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.1/git_develop_to_release.sh
[1.1.1,F4]: https://git-scm.com/docs/git-mergetool



## [1.1.0] - 2019-04-17

### Added
- Add feature to [stitch spectra][1.1.0,A1] for the `TDGraph` `wid` objects.
- Add support to MATLAB R2011a version.
- Implement polynomial transformation case of `TDSpectralTransformation`.
- Add generated **\*.wid** files for the `ID of Data Object "..." is 0!`-issue at the WITec software side.
- Add [git bash script][1.1.0,A2] for semi-automated merging from **develop**-branch to **release**-tag.
- For **develop**-branch, add DEVELOP-folder, which can have contents like unfinished experimental code that will not be merged to **master**-branch.

[1.1.0,A1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.0/@wid/spectral_stitch.m
[1.1.0,A2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.0/git_develop_to_release.sh

### Changed
- Remove the SVG filter effects from the **\*.svg** icon files to improve their PDF compatibility.
- [`@wid/new_Transformation_Space`][1.1.0,C1]: Make its initial values more self-consistent.
- [`load_or_addpath_permanently`][1.1.0,C2] and [`unload_or_rmpath_permanently`][1.1.0,C3]: Exclude all .git folders from the path.

[1.1.0,C1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.0/@wid/new_Transformation_Space.m
[1.1.0,C2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.0/load_or_addpath_permanently.m
[1.1.0,C3]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.0/unload_or_rmpath_permanently.m

### Removed
- Remove dependencies on MATLAB R2014a version.
- Remove dependencies on [`Statistics and Machine Learning Toolbox`][1.1.0,R1].

[1.1.0,R1]: https://www.mathworks.com/products/statistics.html

### Fixed
- Improve support to network drive working.
- `wit`-class: Fix file reading errors in older MATLAB versions.
- Fix `copy selection to clipboard`-feature of `TDText` plots.
- `wid`-class: Fix usage of `@wip/get_Root_Version`.
- Improve documentations of some example cases, the arbitrary lineshape fitting algorithm and the file formatting readme.



## [1.0.4] - 2019-04-02



[Unreleased]: https://gitlab.com/jtholmi/wit_io/-/compare/v1.2.0...develop
[1.2.0]: https://gitlab.com/jtholmi/wit_io/-/compare/v1.1.2...v1.2.0
[1.1.2]: https://gitlab.com/jtholmi/wit_io/-/compare/v1.1.1...v1.1.2
[1.1.1]: https://gitlab.com/jtholmi/wit_io/-/compare/v1.1.0...v1.1.1
[1.1.0]: https://gitlab.com/jtholmi/wit_io/-/compare/v1.0.4...v1.1.0
[1.0.4]: https://gitlab.com/jtholmi/wit_io/-/tree/v1.0.4