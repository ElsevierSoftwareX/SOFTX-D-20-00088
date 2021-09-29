# Changelog
All **notable** changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Explicit Versioning][ExpVer,1], summarized by [![**Release.Breaking.Feature.Fix**][ExpVer,badge,1]][ExpVer,2] or [![**Disruptive.Incompatible.Compatible.Fix**][ExpVer,badge,2]][ExpVer,3] numbering definitions, where any trailing zeros may be omitted.

[ExpVer,1]: https://github.com/exadra37-versioning/explicit-versioning
[ExpVer,2]: https://medium.com/p/92fc1f6bc73c
[ExpVer,3]: https://github.com/exadra37-versioning/explicit-versioning/blob/master/TERMS_SCOPE.md
[ExpVer,badge,1]: https://img.shields.io/badge/version-Release.Breaking.Feature.Fix-0000ff.svg
[ExpVer,badge,2]: https://img.shields.io/badge/version-Disruptive.Incompatible.Compatible.Fix-ff0000.svg

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



## [2.0.1] - 2021-09-29

### Added

- New high-performance [`@wit/sort_by_Name_Data`][2.0.1,A1] and [`@wit/unique_by_Name_Data`][2.0.1,A2] methods for `wit Tree` object arrays.
- [`@wit/disp`][2.0.1,A3]: New interactive display method to show `wit Tree` object array content in Command Window. In Desktop-mode, user interaction via html-links updates `ans`-variable.
- [`@wit/char`][2.0.1,A4]: New high-performance method to convert `wit Tree` object array to a cell of char arrays, enabling the built-in MATLAB calls like `sort` with superior performance.
- [`@wit/hash`][2.0.1,A5] and [`WITio.obj.wit.xxh3_64`][2.0.1,A6]: New [XXH3 (64-bit) hash algorithm](https://cyan4973.github.io/xxHash/). For example, the `hash`-method can summarize the `wit Tree` object content into a fixed-length output, enabling new more detailed `WITio.dev.tests` in the future.
- [`@wid/unpattern_video_stitching` (and its `WITio.obj.wid.unpattern_video_stitching_helper`)][2.0.1,A7]: New optional extra argument, `'-IgnoreEdges'` to skip the edge regions in the corrections. It enables iterative procedure, e.g., for the sample's in and out regions with help of the `'-Outliers'` option after masking them by [`WITio.fun.indep.myinpolygon`][2.0.1,A8].
- [`@wit/disp_cmp`][2.0.1,A9]: New method to compare `wit Tree` objects side-by-side in Command Window.

[2.0.1,A1]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+obj/@wit/sort_by_Name_Data.m
[2.0.1,A2]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+obj/@wit/unique_by_Name_Data.m
[2.0.1,A3]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+obj/@wit/disp.m
[2.0.1,A4]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+obj/@wit/char.m
[2.0.1,A5]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+obj/@wit/hash.m
[2.0.1,A6]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+obj/@wit/xxh3_64.m
[2.0.1,A7]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+obj/@wid/unpattern_video_stitching_helper.m
[2.0.1,A8]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+fun/+indep/myinpolygon.m
[2.0.1,A9]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+obj/@wit/disp_cmp.m

### Changed

- [`WITio.tbx.wip_wid_context_menus`][2.0.1,C1]: From now on, the context menu for *.wip/*.wid files calls WITio.read with '-ifall'.
- [`third-party`][2.0.1,C2]: Update the third-party files of `export_fig` to v3.16 and `zstd-jni` to v1.5.0-4.
- [`WITio.tbx.rmpath_addpath`][2.0.1,C3]: From now on, require the latest WITio version folder as input, fixing the `WITio`-call's addpath issue in R2011a.

[2.0.1,C1]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+tbx/wip_wid_context_menus.m
[2.0.1,C2]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/third%20party/
[2.0.1,C3]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+tbx/rmpath_addpath.m

### Fixed

- `wip`-class: Robustify the `wip Project` autoupdating and make it correctly get rid of the destroyed `wid Data` objects.
- Avoid direct sorting of object handle arrays, which caused some nasty non-deterministic bugs in [`@wid/write`][2.0.1,F2], [`WITio.obj.wip.get_Data_DataClassName_pairs`][2.0.1,F3] and [`WITio.obj.wip.get_Viewer_ViewerClassName_pairs`][2.0.1,F4]. 
- No more file browsing errors due to the incorrectly used `path`-output of `uiputfile`/`uigetfile`-calls.
- [`@wid/get_HtmlName`][2.0.1,F5]: Solve the filesystem encoding error preventing `Project Manager` from loading icons due to misbehaving built-in `imfinfo` only in R2017b.
- Remove typos in the function definitions of [`WITio.fun.image.apply_CMDLCA`][2.0.1,F6] and [`WITio.fun.image.apply_CMRLCM`][2.0.1,F7].
- [`WITio.tbx.pref.get`][2.0.1,F8], [`rm`][2.0.1,F9] and [`set`][2.0.1,F10]: Make them compatible with R2016a.
- [`WITio`][2.0.1,F11]: Fix the search of other WITio versions and the broken link.
- [`WITio.tbx.rmpath_addpath`][2.0.1,F12]: In R2011a, no more error on failed `savepath`.
- [`WITio.tbx.wip_wid_context_menus`][2.0.1,F13]: Resolve the context menu installer issues.
- [`WITio.fun.generic_sub2ind`][2.0.1,F14]: Add missing `end`.
- [`WITio.dev.tools`-functions][2.0.1,F15]: Add missing package-prefixes and make them handle subdirectories.
- [`README on WIT-tag format.txt`][2.0.1,F16]: Add the missing file format description.
- [`README.md`][2.0.1,F17]: Improve the text and fix the broken links.

[2.0.1,F1]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+obj/@wip/wip.m
[2.0.1,F2]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+obj/@wid/write.m
[2.0.1,F3]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+obj/@wip/get_Data_DataClassName_pairs.m
[2.0.1,F4]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+obj/@wip/get_Viewer_ViewerClassName_pairs.m
[2.0.1,F5]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+obj/@wid/get_HtmlName.m
[2.0.1,F6]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+fun/+image/apply_CMDLCA.m
[2.0.1,F7]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+fun/+image/apply_CMRLCM.m
[2.0.1,F8]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+tbx/+pref/get.m
[2.0.1,F9]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+tbx/+pref/rm.m
[2.0.1,F10]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+tbx/+pref/set.m
[2.0.1,F11]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/WITio.m
[2.0.1,F12]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+tbx/rmpath_addpath.m
[2.0.1,F13]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+tbx/wip_wid_context_menus.m
[2.0.1,F14]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+fun/generic_sub2ind.m
[2.0.1,F15]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+dev/+tools/
[2.0.1,F16]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+doc/README%20on%20WIT-tag%20format.txt
[2.0.1,F17]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/README.md

### Performance

- [`@wip/destroy_duplicate_Transformations`][2.0.1,P1]: Fix **major performance bottleneck** prior to writing big data back to file. The method was rewritten using the `wit`-class [`unique_by_Name_Data`][2.0.1,P2] and [`regexp_all_Names`][2.0.1,P3] methods, the `wid`-class [`delete_siblings`][2.0.1,P4]-method and index mapping by sparse matrices.
- [`@wit/delete_siblings`][2.0.1,P5] and [`@wit/delete_children`][2.0.1,P5]: New destructor methods for much faster deletion of the related `wit Tree` objects.
- [`@wid/delete_siblings`][2.0.1,P6]: New high-performance destructor method to remove large `wid Data` object array at once from the same underlying tree branch.
- [`wit`-class methods][2.0.1,P7]: Boost dozens of methods like `search` and `regexp` using much faster read-only `NameNow`, `DataNow`, `ChildrenNow` and `ParentNow` properties.
- [`@wid/find_linked_wits_to_this_wid`][2.0.1,P8]: Improve performance by replacing underlying `regexp` with `regexp_all_Names`.
- [`@wid/wid.m`][2.0.1,P9]: Speed-up slightly the constructor method by reducing the unnecessary object indexing.

[2.0.1,P1]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+obj/@wip/destroy_duplicate_Transformations.m
[2.0.1,P2]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+obj/@wit/unique_by_Name_Data.m
[2.0.1,P3]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+obj/@wit/regexp_all_Names.m
[2.0.1,P4]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+obj/@wid/wid.m
[2.0.1,P5]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+obj/@wit/wit.m
[2.0.1,P6]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+obj/@wid/wid.m
[2.0.1,P7]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+obj/@wit/
[2.0.1,P8]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+obj/@wid/find_linked_wits_to_this_wid.m
[2.0.1,P9]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.1/+WITio/+obj/@wid/wid.m



## [2.0.0] - 2020-11-28

### Added

- New `WITio`, `WITio.batch`, `WITio.demo`, `WITio.dev`, `WITio.doc`, `WITio.fun`, `WITio.obj` and `WITio.tbx` functions to quickly show new package contents as a traversable and clickable list using new [`WITio.fun.href_dir`][2.0.0,A1] function. See *Changes* for **major and minor breaking changes**.
- [`WITio.read`][2.0.0,A2]: New wrapper function to replace legacy `WITio.obj.wip.read`, formerly `wip.read`.
- [`WITio.tbx.backward_compatible`][2.0.0,A3]: New function imports all needed classes and functions to run [WITio v1.4.0.1 example cases][2.0.0,A4] in WITio v2.0.0.
- [`handle_listener`][2.0.0,A5]-class: New class (used by redesigned `wip`-class) to track any handle object without preventing its automated garbage collection.
- `wit`-class: Add `disableObjectModified`, `enableObjectModified` and `notifyObjectModified` methods to more easily control the event firing outside the class. For the first two, if an output is stored, then the effect will be temporary until the output cleanup.
- [`@wit/addlistener`][2.0.0,A6]: Accept `PreSet`, `PostSet`, `PreGet`, `PostGet` property events and store the created listeners to new `PropListeners`-property.
- [`@wid/delete_wrapper`][2.0.0,A7]: New destructor method to only destroy the wid object but not its underlying `wit Tree` objects.
- `wid`-class: New `Parent`-field to `Tag`-property struct.
- `wid`-class: Its constructor now accepts numeric size input to preallocate objects similar to built-in `zeros`.
- [`WITio.dev.package_toolbox`][2.0.0,A8]: New function to generate new toolbox installer, requiring MATLAB R2014b.
- New output option to make [`WITio.tbx.pref.set`][2.0.0,A9] changes temporary by storing its optional `resetOnCleanup` output to a variable.

[2.0.0,A1]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+fun/href_dir.m
[2.0.0,A2]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/read.m
[2.0.0,A3]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+tbx/backward_compatible.m
[2.0.0,A4]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.4.0.1/EXAMPLE%20cases/
[2.0.0,A5]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+obj/@handle_listener/handle_listener.m
[2.0.0,A6]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+obj/@wit/wit.m
[2.0.0,A7]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+obj/@wid/wid.m
[2.0.0,A8]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+dev/package_toolbox.m
[2.0.0,A9]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+tbx/+pref/+set.m

### Changed

- **Major breaking change**: Package the whole WITio toolbox as [`WITio`][2.0.0,C1]-package and distribute everything under [`batch`][2.0.0,C2], [`demo`][2.0.0,C3], [`dev`][2.0.0,C4], [`doc`][2.0.0,C5], [`fun`][2.0.0,C6], [`obj`][2.0.0,C7] and [`tbx`][2.0.0,C8] subpackages. It is *highly recommended* to go through [the updated example cases][2.0.0,C3]. The most notable **breaking changes** are as follows:
  - Move the classes under `WITio.obj`-package and rename `wit_debug`-class to `debug`-class.
  - Move the content of `helper`-folder under `WITio.fun`-package and its new subpackages, and rename some like the `varargin_dashed_str`-prefixed functions.
  - Move `wit_io_compress` and `wit_io_decompress` as renamed under [`WITio.fun.file`][2.0.0,C9]-package.
  - Move the content of `ui`-folder as renamed under [`WITio.tbx.ui`][2.0.0,C10]-package.
  - Move the content of `icons`-folder under [`WITio.tbx.icons`][2.0.0,C11]-package.
  - Move the content of `dev`-folder as renamed under `WITio.dev`-package and its new subpackages.
  - Move the old example cases as renamed under `WITio.demo`-package: remove the filename `'E_'`-prefixes and change the filename numbering system.
  - Move the old script cases as renamed under `WITio.batch`-package: remove the filename `'S_'`-prefixes.
- **Minor breaking changes**:
  1. When reading multiple files by `WITio.read`, make new default behaviour to keep files in separate `wip Project` objects. **For legacy behaviour**, new `'-append'`-parameter was added to replicate the old behaviour, where subsequent projects were appended to the first project. Warn when appending mixed version (v5-v7) WIT-formatted files and disable `'-append'`-flag, avoiding the corruption of such saved files!
  2. Encourage use of `manager`-method by changing the 3rd output `O_wid_HtmlNames` to `O_wit` in `WITio.read`, `WITio.obj.wid.read` and `WITio.obj.wip.read`.
  3. Simplify use of [`wip`][2.0.0,C12]-class `AutoNanInvalid` (formerly `UseLineValid`), `AutoCreateObj`, `AutoCopyObj` and `AutoModifyObj` properties by making their values globally shared among all `wip Project` objects with `WITio.tbx.pref`-package functions and abandoning use of more complicated pop/push-functions.
  4. Rename [`wip`][2.0.0,C12]-class `OnWriteDestroyAllViewers` and `OnWriteDestroyDuplicateTransformations` properties as `AutoDestroyDuplicateTransformations` and `AutoDestroyViewers`, respectively, and make them globally shared like above.
- `wip`-class: Transition to *event-oriented programming* in order to **synchronize** the created objects with the underlying `wit Tree` objects and fix the garbage collection issues. From now on, create only one `wip Project` object instance per one root of an `wit Tree` object. In effect, `add_Data`, `destroy_Data` and `update` methods are not anymore needed to manually update the `wip Project` object.
- Rename the toolbox from **wit_io** to **WITio**, but keep the code repository folder name as is, because it has been cited.
- [`wit`][2.0.0,C13]-class: Make `Listeners`-property return an array of objects rather than a cell array of objects.
- [`wid`][2.0.0,C14]-class: Its constructor now accepts a `wip Project` object as input and returns empty for invalid or deleted input.
- `wip`-class: Its constructor now accepts a `wid Data` object array as input and returns empty for invalid or deleted input.

[2.0.0,C1]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/
[2.0.0,C2]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+batch/
[2.0.0,C3]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+demo/
[2.0.0,C4]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+dev/
[2.0.0,C5]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+doc/
[2.0.0,C6]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+fun/
[2.0.0,C7]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+obj/
[2.0.0,C8]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+tbx/
[2.0.0,C9]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+fun/+file/
[2.0.0,C10]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+tbx/+ui/
[2.0.0,C11]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+tbx/+icons/
[2.0.0,C12]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+obj/@wip/wip.m
[2.0.0,C13]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+obj/@wit/wit.m
[2.0.0,C14]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+obj/@wid/wid.m

### Deprecated

- [`wip`][2.0.0,D1]-class: New event-based synchronization makes `add_Data`, `destroy_Data` and `update` methods obsolete, which from now on do nothing and warn if used.
- [`@wip/destroy_all_Viewers`][2.0.0,D2]: Supercede by [`@wip/destroy_Viewers`][2.0.0,D3].

[2.0.0,D1]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+tests/demo.m
[2.0.0,D2]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+obj/@wip/destroy_all_Viewers.m
[2.0.0,D3]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+obj/@wip/destroy_Viewers.m

### Removed

- Delete previously deprecated `colormaps_mpl`, `@wit/adopt`, `@wit/binary`, `@wit/binaryread`, `@wit/binaryread_Data`, `@wit/collapse`, `@wit/destroy`, `@wid/copy_Links`, `@wid/destroy`, `@wid/destroy_Links` and `@wip/reset_Viewers`.
- Replace [`wit_io_for_code_ocean_compute_capsule`][2.0.0,R1] with [`WITio.tests.demo`][2.0.0,R2] and [`WITio.tests`][2.0.0,R3]. Here former is more verbose and accepts strings as input in order to manually run only the selected example cases.

[2.0.0,R1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.4.0.1/wit_io_for_code_ocean_compute_capsule.m
[2.0.0,R2]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+tests/demo.m
[2.0.0,R3]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/tests.m

### Fixed

- Fix many incompatibility issues with MATLAB R2011a by avoiding `event.proplistener` in [`WITio.tbx.msgbox`][2.0.0,F1], correcting the concatenation of empty variables everywhere and the use of dot-notation (with handles and structs), `fullfile`, `imfinfo`, `zeros`, `ones`, `axes`, `text`, `line`, `patch` and `delete` (with user-defined classes) here and there.
- Remove unintentional dependency on `MATLAB R2013b` or newer by replacing occurences of `strjoin` with new [`WITio.fun.indep.mystrjoin`][2.0.0,F2].
- Remove the toolbox installer dependency on `Image Processing Toolbox`.
- [`@wip/manager`][2.0.0,F3]: Correct passing of `varargin`.
- Improve non-interactive mode by new [`WITio.tbx.edit`][2.0.0,F4] and [`WITio.tbx.verbose`][2.0.0,F5] functions, which make running the demo cases faster for testing purposes. Also, add missing support to the non-interactive testing mode in [`WITio.tbx.license`][2.0.0,F6].
- [`WITio.fun.misc.dim_first_ipermute`][2.0.0,F7] and [`WITio.fun.misc.dim_first_permute`][2.0.0,F8]: Correct permutation of 2-D matrices with dim set to 3 or larger.
- [`WITio.fun.clever_statistics_and_outliers`][2.0.0,F9], [`WITio.fun.fit.fit_lineshape_arbitrary`][2.0.0,F10] and [`WITio.fun.fit.fit_lineshape_automatic_guess`][2.0.0,F11]: Fix error when providing empty input.
- Make demo cases to ignore user preferences regarding `wip_AutoCreateObj`, `wip_AutoCopyObj` and `wip_AutoModifyObj`.
- Many bug fixes when running MATLAB with -nodesktop flag (like [Code Ocean compute capsule][2.0.0,F12]).

[2.0.0,F1]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+tbx/msgbox.m
[2.0.0,F2]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+fun/+indep/mystrjoin.m
[2.0.0,F3]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+obj/@wip/manager.m
[2.0.0,F4]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+tbx/edit.m
[2.0.0,F5]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+tbx/verbose.m
[2.0.0,F6]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+tbx/license.m
[2.0.0,F7]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+fun/+misc/dim_first_ipermute.m
[2.0.0,F8]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+fun/+misc/dim_first_permute.m
[2.0.0,F9]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+fun/clever_statistics_and_outliers.m
[2.0.0,F10]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+fun/+fit/fit_lineshape_arbitrary.m
[2.0.0,F11]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+fun/+fit/fit_lineshape_automatic_guess.m
[2.0.0,F12]: https://codeocean.com/

### Performance

- [`wid`][2.0.0,P1]-class: Construction and copying of objects is now much faster.
- [**Demo cases**][2.0.0,P2]: Solve major performance bottleneck (especially with R2011a) by pre-wrapping text inputs of [`WITio.tbx.msgbox`][2.0.0,P3], obtained using its new 2nd output.

[2.0.0,P1]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+obj/@wid/wid.m
[2.0.0,P2]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+demo/
[2.0.0,P3]: https://gitlab.com/jtholmi/wit_io/-/blob/v2.0.0/+WITio/+tbx/msgbox.m



## [1.4.0.1] - 2020-11-26

### Added

- [`@wit/write`][1.4.0,A1] and [`@wit/fwrite`][1.4.0,A2]: Hotfix of file writing corruption. Typo from commit `f9ec61d` of v1.2.3 forced `write` to call `fwrite`, which since commit `b487cf4` of v1.2.3 has been faulty at writing `Type == 9`, corrupting the written file.

[1.4.0.1,A1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.4.0.1/@wit/write.m
[1.4.0.1,A2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.4.0.1/@wit/fwrite.m



## [1.4.0] - 2020-11-11

### Added

- [`wit_io_for_code_ocean_compute_capsule`][1.4.0,A1]: New function to **non-interactively** run all the example cases by auto-closing with the specified delay any opened msgboxes, managers and plots requiring user interaction. It also summarizes timings and whether or not errors were captured. This can and will be used for the toolbox codebase testing in order to make the community contributions less difficult. This is also a step towards [Code Ocean compute capsule][1.4.0,A2] for publication purposes.
- [`wit_io_uiwait`][1.4.0,A3]: New function to replace all occurrences of built-in `uiwait` and enable the non-interactive mode mentioned above.

[1.4.0,A1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.4.0/wit_io_for_code_ocean_compute_capsule.m
[1.4.0,A2]: https://codeocean.com/
[1.4.0,A3]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.4.0/wit_io_uiwait.m

### Changed

- `wit`-class: Simplify setting of `Root`-property by making it to set new Root as parent of old Root.
- `wit`-class: Make its `ObjectBeingDestroyed` and `ObjectModified` events listenable by external code: a step towards event-oriented programming.

### Deprecated

- [`@wid/destroy`][1.4.0,D1]: Supercede by `delete` of [`wid`][1.4.0,D2]-class.

[1.4.0,D1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.4.0/@wid/destroy.m
[1.4.0,D2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.4.0/@wid/wid.m

### Removed

- Special folder `DEVELOP` in `develop`-branch is removed to better support *GitFlow* workflow in the future and avoid merging issues.

### Fixed

- [`@wit`][1.4.0,F1]-class: Getting of `Root`-property no longer errors due to certain multiple changes to the tree structure prior to the call.
- [`@wip`][1.4.0,F2]-class: Implement the missing destructor of `wip`-class to fix `wid`-class delete errors.

[1.4.0,F1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.4.0/@wit/wit.m
[1.4.0,F2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.4.0/@wip/wip.m

### Performance

- [`@wit/regexp_children`][1.4.0,P1] and [`@wit/search_children`][1.4.0,P2]: Slight speed-up of performance critical parts of wit-class.

[1.4.0,P1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.4.0/@wit/regexp_children.m
[1.4.0,P2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.4.0/@wit/search_children.m



## [1.3.2.1] - 2020-11-10

### Fixed

- [`README.md`][1.3.2.1,F1]: Hotfix to the Acknowledgments section with a missing link and some newline issues.
- `CHANGELOG.md`: Corrected the incorrect release date of v1.3.2.
- [`dev_update_version`][1.3.2.1,F2]: Hotfix an error-causing missing `strcmp` in the first if-clause.

[1.3.2.1,F1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.2.1/README.md
[1.3.2.1,F2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.2.1/dev/dev_update_version.m



## [1.3.2] - 2020-11-08

### Added

- Add example case on [scanline error correction][1.3.2,A1] that demonstrate the use of median-based [`apply_MDLCA`][1.3.2,A2], [`apply_MRLCM`][1.3.2,A3], [`apply_CMDLCA`][1.3.2,A4] and [`apply_CMRLCM`][1.3.2,A5] algorithms.
- During the file and binary reading/writing, show the current object's `FullName` below the updating progress bar in Command Window, similar to WITec software.
- [`@wit/progress_bar`][1.3.2,A6]: Add fourth output `fun_now_text` to optionally display text below the progress bar.

[1.3.2,A1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.2/EXAMPLE%20cases/E_06_scanline_error_correction.m
[1.3.2,A2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.2/helper/corrections/apply_MDLCA.m
[1.3.2,A3]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.2/helper/corrections/apply_MRLCM.m
[1.3.2,A4]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.2/helper/corrections/apply_CMDLCA.m
[1.3.2,A5]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.2/helper/corrections/apply_CMDLCA.m
[1.3.2,A6]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.2/@wit/progress_bar.m

### Changed

- From now on, automatically open each ran example case in Editor.
- `wip`-class: Modifying project's `Type`-property will now change the underlying tree structure. For example, `'WITec Project'` and be changed to `'WITec Data'` and vice versa.
- [`@wit/progress_bar`][1.3.2,C1]: The `fun_now` of built-in progress bar now accepts two optional function inputs to execute them right before and right after the progress bar update.
- Simplify code by replacing all `wid.Empty` with `wid.empty`.
- Renamed dozen internal methods of `wid`-class.

[1.3.2,C1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.2/@wit/progress_bar.m

### Removed

- **Remove `Image Processing Toolbox` dependency**:
   - Rewrote [`@wid/image_mask_editor`][1.3.2,R1] to include basic `Freehand`, `Contour` and `Fill` masking modes with help of new [`myinpolygon`][1.3.2,R2] function.
   - Replace use of built-in `bwdist` by the third party [`bwdistsc2d`][1.3.2,R3].
   - Replace use of built-in `bwlabel` by the third party [`label`][1.3.2,R4].
   - Replace use of built-in `regionprops` by [`myregionprops`][1.3.2,R5].

[1.3.2,R1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.2/@wid/image_mask_editor.m
[1.3.2,R2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.2/helper/myinpolygon.m
[1.3.2,R3]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.2/helper/3rd%20party/bwdistsc/bwdistsc2d.m
[1.3.2,R4]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.2/helper/3rd%20party/label/label.m
[1.3.2,R5]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.2/helper/myregionprops.m

### Fixed

- Correct the dot-notated chained use of `wit`-class `Children`-property, which can be `[]` at times.
- [`@wit/fread`][1.3.2,F1]: Add missing handling of `swap_endianess` at the file stream reading.

[1.3.2,F1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.2/@wit/fread.m



## [1.3.1] - 2020-11-02

### Added

- **Big data space-savings**: Add example case on [file compression and decompression][1.3.1,A1] that uses **new** documented [`wit_io_file_compress`][1.3.1,A2] and [`wit_io_file_decompress`][1.3.1,A3] functions based on Java libraries to demonstrate reproducable 3:1 compression ratios with the WITec software files at minimum compression level.
- Add ability to read/write `*.wid`/`*.wip` files directly within **new** `*.zip`/`*.zst` formats. Here `*.zip` and `*.zst` rely on *de facto* standard [Zlib Deflate][1.3.1,A4] and modern superior-in-speed [Zstandard][1.3.1,A5] compression algorithms, respectively. More details and benchmarks can be found at [Zstandard's website][1.3.1,A6].

[1.3.1,A1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.1/EXAMPLE%20cases/E_01_E_compress_and_decompress_files.m
[1.3.1,A2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.1/wit_io_file_compress.m
[1.3.1,A3]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.1/wit_io_file_decompress.m
[1.3.1,A4]: https://doi.org/10.17487/RFC1950
[1.3.1,A5]: https://doi.org/10.17487/rfc8478
[1.3.1,A6]: https://facebook.github.io/zstd/

### Changed

- [`@wip/get_Data_DataClassName_pairs`][1.3.1,C1] (and **new**  [`@wip/get_Viewer_ViewerClassName_pairs`][1.3.1,C2]): Return all found valid pairs as first output and return all found Roots as **new** second output.

[1.3.1,C1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.1/@wip/get_Data_DataClassName_pairs.m
[1.3.1,C2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.1/@wip/get_Viewer_ViewerClassName_pairs.m

### Fixed

- `wid`-class: Fix typo in the [`new_`][1.3.1,F1]-prefixed methods causing errors.
- [`@wip/append`][1.3.1,F2]: Fix issues with empty inputs and make it more robust to incomplete tree structures.
- [`@wip/get_Data_DataClassName_pairs`][1.3.1,F3]: Fix bug due to typo.
- Correct the dot-notated chained use of `wit`-class `Parent`-property, which can be `[]` at times.

[1.3.1,F1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.1/@wid
[1.3.1,F2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.1/@wip/append.m
[1.3.1,F3]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.1/@wip/get_Data_DataClassName_pairs.m

### Performance

- [`@wip/get_Data_DataClassName_pairs`][1.3.1,P1]: Improved performance with huge files by removing a bottleneck within the code that finds `Data`-`DataClassName`-pairs.
- [`@wip/append`][1.3.1,P2]: Much faster with big datasets, mainly after replacing [`search`][1.3.1,P3]/[`regexp`][1.3.1,P4]-methods with faster [`search_children`][1.3.1,P5]/[`regexp_children`][1.3.1,P6] counterparts where possible.

[1.3.1,P1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.1/@wip/get_Data_DataClassName_pairs.m
[1.3.1,P2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.1/@wip/append.m
[1.3.1,P3]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.1/@wit/search.m
[1.3.1,P4]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.1/@wit/regexp.m
[1.3.1,P5]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.1/@wit/search_children.m
[1.3.1,P6]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.1/@wit/regexp_children.m



## [1.3.0] - 2020-11-01

### Added

- Show file and binary reading/writing progress in Command Window using new documented [`progress_bar`][1.3.0,A1]-function, customizable by extra inputs `'-Width'`, `'-Character'`, `'-FlipStartEnd'`, `'-Reverse'`, `'-OnlyIncreasing'` and `'-OnlyDecreasing'`.
- `wit`-class: Add new performance-optimized *read-only* `Modified<X>`-properties that allow tracing of branch-related modifications within the `wit` `Tree` object and can be used to determine if and where a change has occurred. These can be used to speed-up `wid`- and `wip`-classes in the upcoming releases.
- `wit`-class: Add `'ObjectBeingDestroyed'` and `'ObjectModified'` events to `wit`-class, intended for internal use for now. This is preparation to possible transition to *event-oriented programming* in the future.
- Unify the four main properties of `wit`-, `wid`- and `wip`-classes by adding missing `Name`-property (= the project file name) and `Type`-property (= the project root name) to `wip`-class and `File`-property (= the data full file name) to `wid`-class.
- [`@wit/search_children`][1.3.0,A2] and [`@wit/regexp_children`][1.3.0,A3]: New rapid methods to find the specific children of `wit` `Tree` objects, being faster than [`@wit/search`][1.3.0,A4] and [`@wit/regexp`][1.3.0,A5]. Conveniently, multiple subsequent calls can be chained with dot-notation. These can be used to speed-up `wid`- and `wip`-classes in the upcoming releases.
- [`@wit/regexp_all_Names`][1.3.0,A6]: New fast regexp method to find all `wit` `Tree` objects by matching a `Name`-pattern. This can be used to speed-up the ID search of the tree structure in the future.
- [`@wit/binary_ind2obj`][1.3.0,A7]: New debugging method to find `wit` `Tree` objects that correspond to the given binary positions (= binary buffer indices).
- [`@wit/read`][1.3.0,A8]: Add missing method documentation.
- [`dev_update_version`][1.3.0,A9]: New developer's function to quickly update all the files mentioning the toolbox version before the next release.

[1.3.0,A1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.0/@wit/progress_bar.m
[1.3.0,A2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.0/@wit/search_children.m
[1.3.0,A3]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.0/@wit/regexp_children.m
[1.3.0,A4]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.0/@wit/search.m
[1.3.0,A5]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.0/@wit/regexp.m
[1.3.0,A6]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.0/@wit/regexp_all_Names.m
[1.3.0,A7]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.0/@wit/binary_ind2obj.m
[1.3.0,A8]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.0/@wit/read.m
[1.3.0,A9]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.0/dev/dev_update_version.m

### Changed

- Make `wit`-class **self-consistent** and **usage-safe** by enforcing **(1)** syncronization of parent-children connections (meaning that the parent now always knows of its children and vice versa), and **(2)** prevention of loop creation within the tree structure. The former removes difficult to detect bugs. The latter quarantees that any `wit` `Tree` object can always be written to a file.
- Due to optimizations, any new object created by `wit()`-call has `Data = []` and `Type = 2` instead of `Data = wit.empty` and `Type = 0`.
- `wit`-class: As a side effect of optimization, the initial values for `Children` and `Parent` properties are now `[]`, what can break any code not taking this into account when using these properties.
- `wid`-class: Make `Info`, `LinksToOthers`, `AllLinksToOthers`, `LinksToThis` and `AllLinksToThis` properties *read-only* as they already effectively were.
- `wip`-class: Make `File`-property *read-only* to allow its modifications only by the file operations.
- Allow variable number of inputs to the write/read methods of `wit`-class in order to enable customizations like progress bar and compression/decompression (in the future).
- Due to format-specific reasons, default to the little endian ordering during the file and binary reading/writing.
- `wit`-class: Make `Children`, `Root`, `Siblings`, `Next` and `Prev` dependent properties *read-write* to enable more diverse ways to alter the tree structure.
- `wit`-class: Hide secondary file format properties, namely `NameLength`, `Start` and `End`.
- [`@wit/update`][1.3.0,C1]: Hide the second input, which was intended only for internal use.
- By default, auto-update `wit` `Tree` objects right before writing.
- Reduced Octave-compatibility **at speed-critical components** in order to prioritize the big data performance.

[1.3.0,C1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.0/@wit/update.m

### Deprecated

- [`@wit/destroy`][1.3.0,D1]: Supersede it by `delete`.
- [`@wit/adopt`][1.3.0,D2]: To be removed in the future.
- `wit`-class: Supersede [`binaryread`][1.3.0,D3] and [`binary`][1.3.0,D4] by [`bread`][1.3.0,D5] and [`bwrite`][1.3.0,D6], respectively.

[1.3.0,D1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.0/@wit/destroy.m
[1.3.0,D2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.0/@wit/adopt.m
[1.3.0,D3]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.0/@wit/binaryread.m
[1.3.0,D4]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.0/@wit/binary.m
[1.3.0,D5]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.0/@wit/bread.m
[1.3.0,D6]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.0/@wit/bwrite.m

### Fixed

- Fix incomplete support of string arrays (`Type == 9`) in file and binary reading/writing.
- [`@wit/bread`][1.3.0,F1]: Add unintentionally missing `skip_Data_criteria_for_obj`-feature to binary reading.
- [`@wit/fwrite`][1.3.0,F2]: Add unintentionally missing `swap_endianess`-feature to file writing.
- File reading/writing: Fix the low-on-memory scheme so that it properly catches the error messages previously uncaught.
- From now on, prevent setting of siblings to the root `wit` `Tree` objects.
- [`wip`][1.3.0,F3]- and [`wid`][1.3.0,F4]-classes: Reorganized their properties in more clean and concise way.
- Improved Octave-compatibility of file and binary read/write code.

[1.3.0,F1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.0/@wit/bread.m
[1.3.0,F2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.0/@wit/fwrite.m
[1.3.0,F3]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.0/@wip/wip.m
[1.3.0,F4]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.0/@wid/wid.m

### Performance

- [`wit`][1.3.0,P1]-class: Towards **big data suitability** by dramatic improvements in the performance of **(1)** file and binary reading/writing of huge files, **(2)** copying of `wit` `Tree` objects, and **(3)** getting and setting values of any `wit`-class property. Vast majority of these were achieved by minimizing redundant code everywhere with help of hidden secondary properties, disabling automatic file stream flushing, avoiding of cell arrays and avoiding of Octave-compatible overloaded functions.

[1.3.0,P1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.3.0/@wit/wit.m



## [1.2.3] - 2020-10-30

### Added
- Add more perceptually uniform colormaps like `'cividis'` and grayscale options.
- Show this toolbox when calling `help`, `doc` or `ver` in Command Window.
- `wid`-class: Add static `read`-method, equivalent to that of `wip`-class.
- [`README on WIT-tag formatting.txt`][1.2.3,A1]: More information to `TDTransformation`'s UnitKind-section.
- Add advanced tools to work with Java classes on MATLAB side on-demand, such as [`java_objects_from_varargin`][1.2.3,A2], [`java_objects_to_varargout`][1.2.3,A3] and [`java_class_method_call`][1.2.3,A4] to mention. These were used to experiment with adding/updating/removing `jar`-libraries at MATLAB.

[1.2.3,A1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.3/README%20on%20WIT-tag%20formatting.txt
[1.2.3,A2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.3/helper/java/java_objects_from_varargin.m
[1.2.3,A3]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.3/helper/java/java_objects_to_varargout.m
[1.2.3,A4]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.3/helper/java/java_class_method_call.m

### Changed
- `CHANGELOG.md`: Transition from **Semantic Versioning** to **Explicit Versioning** for more clarity and less rigidity.
- [`image_mask_editor`][1.2.3,C1]: Fix typos. From now on, error if given more than one wid Data objects.

[1.2.3,C1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.3/@wid/image_mask_editor.m

### Deprecated
- Deprecate `colormap_mpl` by replacing it with `perceptually_uniform_colormap`. Rename and update related functions like `ui_sidebar_for_perceptually_uniform_colormaps`.

### Removed
- Delete unused `handle_struct`-class from the project.
- `export_fig`-library: Remove unused files.

### Fixed
- Remove unintentional dependency on MATLAB R2013b by changing any occurrence of `flip` to `fliplr`.
- `export_fig`-library: Update it to v3.12 and stop it from warning about new updates and promoting consulting services once a week!



## [1.2.2] - 2020-10-29

### Fixed
- Hotfix reported error on local disks. (Code was unintentionally only tuned to network disks.)



## [1.2.1] - 2020-10-29

### Fixed
- Hotfix to properly add paths upon toolbox installation by wit_io.mltbx.



## [1.2.0] - 2020-03-19

### Added
- Add this `CHANGELOG.md` file to the GitLab project.
- Add experimental support to legacy file `Versions` **v0 &ndash; v4** via **v5**, enabled by the way the WITec software ignores the unused `wit` tag objects.
- Add example case on [plotting scalebar and marking measurement positions on one other][1.2.0,A1] using either new `'-scalebar'` and `'-position'` options of [`@wid/plot`][1.2.0,A2] or new [`@wid/plot_scalebar`][1.2.0,A3] and [`@wid/plot_position`][1.2.0,A4] functions.
- Add example case on [configuring toolbox by permanent user preferences][1.2.0,A5] using new [`wit_io_pref_get`][1.2.0,A6], [`wit_io_pref_is`][1.2.0,A7], [`wit_io_pref_rm`][1.2.0,A8] and [`wit_io_pref_set`][1.2.0,A9] functions. For example, permanently remember the latest folder in the **wit_io**'s file browsing UI.
- Add TeX-enriched help dialogs to [all example cases][1.2.0,A10] using new [`wit_io_msgbox`][1.2.0,A11] and [`mytextwrap`][1.2.0,A12] functions.
- Add ability to [destroy duplicate Transformations][1.2.0,A13] in the opened `wip` project object. (Update affected example case on [data cropping][1.2.0,A14].)
- `wit`-class: Add features to [abort `wit` tag file reading or skip its contents by the given criterias][1.2.0,A15] in order to customize and speed up the file reading for specific needs. For example, [file `Version` reading][1.2.0,A16] is now much quicker because it only loads small portion of the file into memory.
- Add scripts to quickly open the main and New Issue pages at GitLab: [`wit_io_gitlab`][1.2.0,A17] and [`wit_io_gitlab_new_issue`][1.2.0,A18].
- [`@wid/unpattern_video_stitching_helper`][1.2.0,A19]: Add new `'-outliers'` option to provide known outliers in the image to the algorithm.
- Add ability to automatically mask bad fitting results or near noise results using new [`mask_bad_results_and_noise`][1.2.0,A20] helper function.
- `wit`-class: Add ability to search `wit` tag object ancestors using new [`regexp_ancestors`][1.2.0,A21] and [`search_ancestors`][1.2.0,A22] functions.
- Add [developer's functions][1.2.0,A23] to quickly get [`Versions`][1.2.0,A24] or [unique `wid`-class `Types`][1.2.0,A25] of multiple files.
- Add notes on MATLAB toolbox dependencies in the beginning of each dependent file.

[1.2.0,A1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/EXAMPLE%20cases/E_02_D_plot_data_position_and_scalebar.m
[1.2.0,A2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wid/plot.m
[1.2.0,A3]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wid/plot_scalebar.m
[1.2.0,A4]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wid/plot_position.m
[1.2.0,A5]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/EXAMPLE%20cases/E_01_D_permanent_user_preferences.m
[1.2.0,A6]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/wit_io_pref_get.m
[1.2.0,A7]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/wit_io_pref_is.m
[1.2.0,A8]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/wit_io_pref_rm.m
[1.2.0,A9]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/wit_io_pref_set.m
[1.2.0,A10]: https://gitlab.com/jtholmi/wit_io/-/tree/v1.2.0/EXAMPLE%20cases
[1.2.0,A11]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/wit_io_msgbox.m
[1.2.0,A12]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/helper/plotting/mytextwrap.m
[1.2.0,A13]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wip/destroy_duplicate_Transformations.m
[1.2.0,A14]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/EXAMPLE%20cases/E_02_C_crop_data.m
[1.2.0,A15]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wit/read.m
[1.2.0,A16]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wip/read_Version.m
[1.2.0,A17]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/wit_io_gitlab.m
[1.2.0,A18]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/wit_io_gitlab_new_issue.m
[1.2.0,A19]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wid/unpattern_video_stitching_helper.m
[1.2.0,A20]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/helper/fitting/mask_bad_results_and_noise.m
[1.2.0,A21]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wit/regexp_ancestors.m
[1.2.0,A22]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wit/search_ancestors.m
[1.2.0,A23]: https://gitlab.com/jtholmi/wit_io/-/tree/v1.2.0/dev
[1.2.0,A24]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/dev/dev_get_Versions.m
[1.2.0,A25]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/dev/dev_get_unique_wid_Types.m

### Changed
- For MATLAB R2019b or newer, replace Java-based GUI with HTML5-based GUI, fixing `JAVACOMPONENT` warnings. For example, [`Project Manager`][1.2.0,C1] now uses [HTML5-based JList-like code][1.2.0,C2] to create its window.
- `wip`-class: Add `OnWrite`-tasks to [**\*.wip** file writing][1.2.0,C3] via new properties `OnWriteDestroyAllViewers` (`= true` by default) and `OnWriteDestroyDuplicateTransformations` (`= true` by default). The former avoids possible corruption of modified **\*.wip** files, because **wit_io** does not update the file tree `Viewer`-section. The latter allows data analysis across the affected datasets in the WITec software. To change the default behaviour, refer to [this new example case][1.2.0,C4].
- [helper][1.2.0,C5]-folder: For subfunction customizations, make multiple-dashed strings a special case in [varargin dashed string parsers][1.2.0,C6], so that the first dash is always removed during parsing. Updated all example cases, where extra arguments were passed to `'-manager'` via [@wip/read][1.2.0,C7].
- Example cases now describe [`BSD license`][1.2.0,C8] in dialog with checkbox to not show again.
- [`fit_lineshape_automatic_guess`][1.2.0,C9]: Simplify the process and describe the assumptions. Change to more robust lineshape center estimation by integration via new [`mtrapz`][1.2.0,C10] function.
- `wit`-class: Make basic functionality Octave-compatible.
- [`S_rename_by_regexprep`][1.2.0,C11]: Improve regexp renaming by listing data via `Project Manager`. (However, the usage is limited in MATLAB R2019b due to a reported `inputdlg's forced uifigure modality`-bug.)
- [`@wip/manager`][1.2.0,C12]: Remove waitbar in `'-nopreview'`-mode.
- [`@wip/manager`][1.2.0,C12]: Allow `'-Type'` and `'-SubType'` with multiple inputs.
- [`@wip/manager`][1.2.0,C12]: Add tag `'wit_io_project_manager_gcf'` to find its latest main window handle (whether `figure` or `uifigure`) without gcf.
- [`wid`][1.2.0,C13]-class: Rename `Links`-property to `LinksToOthers` and add `LinksToThis`-property. Rename related `copy_Links` to [`copy_LinksToOthers`][1.2.0,C14] (and add copying of `IDLists`).
- Move the toolbox developer's functions under [dev][1.2.0,C15]-folder and give them `dev`-prefix.
- Rename the [toolbox's main folder][1.2.0,C16] functions to have `wit_io`-prefix and better names for alphabetically ordered file listing.
- [`export_fig`][1.2.0,C17]: Upload latest version of this 3rd party code.

[1.2.0,C1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wip/manager.m
[1.2.0,C2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/icons/uihtml_JList.html
[1.2.0,C3]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wip/write.m
[1.2.0,C4]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/EXAMPLE%20cases/E_01_D_permanent_user_preferences.m
[1.2.0,C5]: https://gitlab.com/jtholmi/wit_io/-/tree/v1.2.0/helper
[1.2.0,C6]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/helper/varargin_dashed_str.m
[1.2.0,C7]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wip/read.m
[1.2.0,C8]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/LICENSE
[1.2.0,C9]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/helper/fitting/fit_lineshape_automatic_guess.m
[1.2.0,C10]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/helper/mtrapz.m
[1.2.0,C11]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/SCRIPT%20cases/S_rename_by_regexprep.m
[1.2.0,C12]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wip/manager.m
[1.2.0,C13]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wid/wid.m
[1.2.0,C14]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wid/copy_LinksToOthers.m
[1.2.0,C15]: https://gitlab.com/jtholmi/wit_io/-/tree/v1.2.0/dev
[1.2.0,C16]: https://gitlab.com/jtholmi/wit_io/-/tree/develop
[1.2.0,C17]: https://gitlab.com/jtholmi/wit_io/-/tree/v1.2.0/helper/3rd%20party/export_fig

### Deprecated
- `@wip/reset_Viewers`: Supercede by [`@wip/destroy_all_Viewers`][1.2.0,D1].

[1.2.0,D1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wip/destroy_all_Viewers.m

### Removed
- Remove some dependencies on [`Image Processing Toolbox`][1.2.0,R1].
- Remove unintentional dependency on [`Statistics and Machine Learning Toolbox`][1.2.0,R2].
- `wip`-class: Remove unused `storeState`- and `restoreState`-functions and, from now on, rely on the LIFO-concept `push`- and `pop`-functions.
- `clever_statistics`: Remove this deprecated function. Use [`clever_statistics_and_outliers`][1.2.0,R3] instead.
- `wid`-class: Remove all deprecated `reduce`-prefixed functions.

[1.2.0,R1]: https://www.mathworks.com/products/image.html
[1.2.0,R2]: https://www.mathworks.com/products/statistics.html
[1.2.0,R3]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/helper/clever_statistics_and_outliers.m

### Fixed
- [`@wid/wid_Data_get_Bitmap`][1.2.0,F1] and [`@wid/wid_Data_set_Bitmap`][1.2.0,F2]: For **v5** files, add unimplemented bitmap write/read row-padding to nearest 4-byte boundary.
- [`@wip/interpret`][1.2.0,F3]: Prioritize [`Standard Unit`][1.2.0,F4] search first and only then widen the search. Remove unnecessary `()`-brackets around [`Standard Unit`][1.2.0,F4] searches. Allow A's and u's search special characters Å's (U+00C5) and µ's (U+00B5).
- [`E_v5.wip`][1.2.0,F5]: Fix corrupted `TDSpaceTransformations` and update affected example cases.
- [`@wid/crop`][1.2.0,F6] and [`@wid/crop_Graph`][1.2.0,F7]: Properly copy shared transformations and modify only their unshared versions using new [`@wid/copy_Others_if_shared_and_unshare`][1.2.0,F8] function.
- The file browsing GUI is now case-insensitive to **\*.wid** and **\*.wip** file extensions even though the file system is case-sensitive.
- [`@wid/unpattern_video_stitching_helper`][1.2.0,F9]: Fix error when no working solution can exist.
- [`@wid/spatial_average`][1.2.0,F10]: Properly update `TDSpaceTransformations` now.
- [`fit_lineshape_arbitrary`][1.2.0,F11]: Properly handle all-`NaN`-valued case now.
- [`fun_lineshape_voigtian`][1.2.0,F12]: Double-check algorithm validity meticulously and consider alternatives. Fix pure Gaussian issues.
- [`fit_lineshape_automatic_guess`][1.2.0,F13]: Fix few lurking bugs.
- Fix `wip`-class `ForceDataUnit`-property usage issues and utilize its changes better.
- Fix typos causing bugs.

[1.2.0,F1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wid/wid_Data_get_Bitmap.m
[1.2.0,F2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wid/wid_Data_set_Bitmap.m
[1.2.0,F3]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wip/interpret.m
[1.2.0,F4]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wip/interpret_StandardUnit.m
[1.2.0,F5]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/EXAMPLE%20cases/E_v5.wip
[1.2.0,F6]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wid/crop.m
[1.2.0,F7]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wid/crop_Graph.m
[1.2.0,F8]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wid/copy_Others_if_shared_and_unshare.m
[1.2.0,F9]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wid/unpattern_video_stitching_helper.m
[1.2.0,F10]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wid/spatial_average.m
[1.2.0,F11]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/helper/fitting/fit_lineshape_arbitrary.m
[1.2.0,F12]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/helper/fitting/fun_lineshape_voigtian.m
[1.2.0,F13]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/helper/fitting/fit_lineshape_automatic_guess.m

### Performance
- [`@wid/wid_SubType_get`][1.2.0,P1]: Disable unused `'Volume'`-feature due to major performance bottleneck.
- [`jacobian_helper`][1.2.0,P2] and [`fit_lineshape_arbitrary`][1.2.0,P3]: Add `usePrevCstd`-flag to fix performance issue in loops with changing data dimensions.
- [`@wip/read_Version`][1.2.0,P4]: Speed it up using `@wit/read`'s new `skip_Data_criteria_for_obj`-feature.
- [`bw2lines`][1.2.0,P5]: Reduce computation burden when using only the first output argument.
- [`dim_size_consistent_repmat`][1.2.0,P6]: Remove [`cellfun`][1.2.0,P7]'s and reduce use of cells to improve performance.

[1.2.0,P1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wid/wid_SubType_get.m
[1.2.0,P2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/helper/fitting/jacobian_helper.m
[1.2.0,P3]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/helper/fitting/fit_lineshape_arbitrary.m
[1.2.0,P4]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/@wip/read_Version.m
[1.2.0,P5]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/helper/fitting/bw2lines.m
[1.2.0,P6]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.2.0/helper/dim_size_consistent_repmat.m
[1.2.0,P7]: https://www.mathworks.com/help/matlab/ref/cellfun.html



## [1.1.2] - 2019-08-08

### Added
- For MATLAB R2014b or newer, add convenient [toolbox installer][1.1.2,A1].
- Add [example case][1.1.2,A2] and [related functionality][1.1.2,A3] to demonstrate Video Stitching image unpatterning. It is noteworthy that [its documentation][1.1.2,A4] describes dozens of extra customization options.
- [`clever_statistics_and_outliers`][1.1.2,A5]: Add support to multiple dims input with an ability to negate the selection with negative values.
- `wid`-class: Add feature to open [`Project Manager`][1.1.2,A6] for the `wid` objects like previously for the `wip` object. This can be used to quickly glance through the selected `wid` objects and see their corresponding array index value.
- [helper][1.1.2,A7]-folder: Add [varargin dashed string parsers][1.1.2,A8] for easier function customizations.
- [`@wid/crop`][1.1.2,A9]: Add `isDataCropped`-flag (if `wid` object Data was already cropped elsewhere) and validate inputs.
- `wip`-class: Add LIFO (first in = push, last out = pop) concept to simplify all the state-related code.
- Add feature to generate indices via [`generic_sub2ind`][1.1.2,A10], merging calls to [`ndgrid`][1.1.2,A11], [`sub2ind`][1.1.2,A12] and [`cast`][1.1.2,A13] and being memory conservative. It can be customized with extra options: `'-isarray'`, `'-nobsxfun'`, `'-truncate'`, `'-replace'`, `'-mirror'`, `'-circulate'`.
- Add feature to perform [`rolling window analysis`][1.1.2,A14] that is used by the Video Stitching image unpatterning code.
- Add [git bash script][1.1.2,A15] for semi-automated merging from **release**-tag to **master**-branch.

[1.1.2,A1]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/wit_io.mltbx
[1.1.2,A2]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/EXAMPLE%20cases/E_05_unpattern_video_stitching.m
[1.1.2,A3]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/@wid/unpattern_video_stitching.m
[1.1.2,A4]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/@wid/unpattern_video_stitching_helper.m
[1.1.2,A5]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/helper/clever_statistics_and_outliers.m
[1.1.2,A6]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/@wid/manager.m
[1.1.2,A7]: https://gitlab.com/jtholmi/wit_io/-/tree/v1.1.2/helper
[1.1.2,A8]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/helper/varargin_dashed_str.m
[1.1.2,A9]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/@wid/crop.m
[1.1.2,A10]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/helper/generic_sub2ind.m
[1.1.2,A11]: https://www.mathworks.com/help/matlab/ref/ndgrid.html
[1.1.2,A12]: https://www.mathworks.com/help/matlab/ref/sub2ind.html
[1.1.2,A13]: https://www.mathworks.com/help/matlab/ref/cast.html
[1.1.2,A14]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/helper/rolling_window_analysis.m
[1.1.2,A15]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.2/git_release_to_master.sh

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
- [`icons`][1.1.1,C4]-folder: Replace **\*.zip** files with folders for MATLAB [`File Exchange`][1.1.1,C5] compatibility.
- [`@wid/get_HtmlName`][1.1.1,C6]: Use small icons for `wid` object names in MATLAB's `Workspace` and larger icons for `wid` object names in `Project Manager`.
- [`@wid/crop`][1.1.1,C7]: Accept variable number of inputs.

[1.1.1,C1]: https://gitlab.com/jtholmi/wit_io/-/tree/v1.1.1/EXAMPLE%20cases
[1.1.1,C2]: https://gitlab.com/jtholmi/wit_io/-/tree/v1.1.1/SCRIPT%20cases
[1.1.1,C3]: https://www.mathworks.com/company/newsletters/articles/avoiding-repetitive-typing-with-tab-completion.html
[1.1.1,C4]: https://gitlab.com/jtholmi/wit_io/-/tree/v1.1.1/icons
[1.1.1,C5]: https://www.mathworks.com/matlabcentral/fileexchange
[1.1.1,C6]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.1/@wid/get_HtmlName.m
[1.1.1,C7]: https://gitlab.com/jtholmi/wit_io/-/blob/v1.1.1/@wid/crop.m

### Deprecated
- `wid`-class: Supersede all `reduce`-prefixed functions by that of `crop`-prefixed for consistency with the WITec software.

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



[Unreleased]: https://gitlab.com/jtholmi/wit_io/-/compare/v2.0.1...develop
[2.0.1]: https://gitlab.com/jtholmi/wit_io/-/compare/v2.0.0...v2.0.1
[2.0.0]: https://gitlab.com/jtholmi/wit_io/-/compare/v1.4.0.1...v2.0.0
[1.4.0.1]: https://gitlab.com/jtholmi/wit_io/-/compare/v1.4.0...v1.4.0.1
[1.4.0]: https://gitlab.com/jtholmi/wit_io/-/compare/v1.3.2.1...v1.4.0
[1.3.2.1]: https://gitlab.com/jtholmi/wit_io/-/compare/v1.3.2...v1.3.2.1
[1.3.2]: https://gitlab.com/jtholmi/wit_io/-/compare/v1.3.1...v1.3.2
[1.3.1]: https://gitlab.com/jtholmi/wit_io/-/compare/v1.3.0...v1.3.1
[1.3.0]: https://gitlab.com/jtholmi/wit_io/-/compare/v1.2.3...v1.3.0
[1.2.3]: https://gitlab.com/jtholmi/wit_io/-/compare/v1.2.2...v1.2.3
[1.2.2]: https://gitlab.com/jtholmi/wit_io/-/compare/v1.2.1...v1.2.2
[1.2.1]: https://gitlab.com/jtholmi/wit_io/-/compare/v1.2.0...v1.2.1
[1.2.0]: https://gitlab.com/jtholmi/wit_io/-/compare/v1.1.2...v1.2.0
[1.1.2]: https://gitlab.com/jtholmi/wit_io/-/compare/v1.1.1...v1.1.2
[1.1.1]: https://gitlab.com/jtholmi/wit_io/-/compare/v1.1.0...v1.1.1
[1.1.0]: https://gitlab.com/jtholmi/wit_io/-/compare/v1.0.4...v1.1.0
[1.0.4]: https://gitlab.com/jtholmi/wit_io/-/tree/v1.0.4