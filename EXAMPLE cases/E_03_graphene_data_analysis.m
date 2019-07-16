% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO EXAMPLE CASE 3: GRAPHENE DATA ANALYSIS
% Graphene data analysis case with examples of (E3 i.) laser line
% recalibration, (E3 ii.) lineshape fitting, (E3 iii.) result cleaning and
% (E3 iv.) histogram generation.

clear all; % Clear workspace
close all; % Close figures

% Example file
pathstr = fileparts([mfilename('fullpath') '.m']); % Get folder of this script
file = fullfile(pathstr, 'E_v5.wip'); % Construct full path of the example file
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'EXAMPLE CASE 3: GRAPHENE DATA ANALYSIS' ...
    '' ...
    '* Using ''E_v5.wip'' WITec Project -file, which has Raman data from exfoliated graphene with 1-, 2- and 3-layer areas on 285 nm SiO2/Si-substrate.' ...
    '' ...
    '* Please note that MOST of this ''wit_io'' code is OPEN-SOURCED under simple and permissive BSD 3-Clause License and is FREE-TO-USE like described in LICENSE.txt!'});
if ishandle(h), figure(h); uiwait(h); end % Wait for helpdlg to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% This opens the specified file. Then automatically loads all.
[O_wid, O_wip, O_HtmlNames] = wip.read(file, '-all', '-SpectralUnit', '(rel. 1/cm)');

C_ImageScan = O_wid(3); % Get object of "Reduced<Image Scan 1 (Data)" at index 3
C_Point = O_wid(17); % Get object of "1-layer Gr<Point Scan 1 (Data)" at index 17
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'!!! (E3 i.) Recalibrating the Rayleigh-peak to zero position:' ...
    '' ...
    '* The Rayleigh-peak (or the laser line or the 0-peak) has Gaussian intensity distribution and may be shifted from zero due to instrumental reasons. Misaligned 0-peak offsets all other Raman peak position information, for which reason it should be recalibrated.' ...
    '' ...
    '* Misalignment is found by fitting a Gaussian function to the 0-peak. The found Gaussian peak center (in nm) is the new laser line wavelength. The data objects of interest are then dynamically modified to re-zero the 0-peak permanently.' ...
    '' ...
    '* Close this to continue.'});
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% !!! (E3 i.) SINGLE GAUSS FITTING OF THE RAYLEIGH-PEAK and RECALIBRATION OF THE RAYLEIGH-PEAK
Range_0 = [-25 25]; % Rayleigh-peak or 0-peak
C_Point_old = C_Point.copy(); % Store the old data for comparison purposes
C_0 = C_Point.filter_gaussian({'-silent'}, Range_0); % Gauss filtering with removal of linear background. Returns also Intensity, Center, FWHM and Offset.
[~, Rayleigh_rel_invcm] = clever_statistics_and_outliers(C_0(2).Data, [], 4); % Calculate mean using clever 4-sigmas statistics (Robust against outliers)
Rayleigh_nm = C_Point.interpret_Graph('(nm)', Rayleigh_rel_invcm); % Calculate mean excitation wavelength
C_Point.Info.GraphInterpretation.Data.TDSpectralInterpretation.ExcitationWaveLength = Rayleigh_nm; % Permanently recalibrate the Rayleigh peak to zero!
C_ImageScan.Info.GraphInterpretation.Data.TDSpectralInterpretation.ExcitationWaveLength = Rayleigh_nm; % Permanently recalibrate the Rayleigh peak to zero!

% Alternatively, try and run an semi-automated script under scripts-folder
% on your file contents of interest: recalibrate_rayleigh_peak_to_zero.m

C_Point.Name = sprintf('Zeroed<%s', C_Point.Name);
figure; C_Point_old.plot('-compare', C_Point); % Show fitting results % Image<TDGraph with sidebar
xlim(Range_0); ylim('auto'); % Show only the region near the 0-peak

if ishandle(h), figure(h); uiwait(h); end % Wait for helpdlg to be closed before continuing.
close all;
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'!!! (E3 ii.) Lorentzians are fitted to the D-, G- and 2D-peaks.' ...
    '' ...
    '* Ideal Raman peaks have Lorentzian function form, but may sometimes consist of multiple peaks like graphene 2D-peak.' ...
    '' ...
    '* Wait until the fitting has completed and preview the fitting results (by clicking) in the opened figure before closing this to continue.'});
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% !!! (E3 ii.) SINGLE LORENTZ FITTING OF THE D-, G- AND 2D-PEAKS
% Filter ranges
Range_D = [1250 1450]; % D-peak
Range_G = [1500 1650]; % G-peak
Range_2D = [2550 2800]; % 2D-peak
C_D = C_ImageScan.filter_lorentzian(Range_D); % Lorentz filtering with removal of linear background. Returns also Intensity, Center, FWHM and Offset.
C_G = C_ImageScan.filter_lorentzian(Range_G); % Lorentz filtering with removal of linear background. Returns also Intensity, Center, FWHM and Offset.
C_2D = C_ImageScan.filter_lorentzian(Range_2D); % Lorentz filtering with removal of linear background. Returns also Intensity, Center, FWHM and Offset.

% SHOWING FITTING RESULTS OF THE RAYLEIGH-, D-, G- AND 2D-PEAKS
figure; C_ImageScan.plot('-compare', C_0(end), C_D(end), C_G(end), C_2D(end)); % Show fitting results % Image<TDGraph with sidebar

if ishandle(h), figure(h); uiwait(h); end % Wait for helpdlg to be closed before continuing.
close all;
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'!!! (E3 iii.) Clean-up of the fitted data:' ...
    '' ...
    '* Sometimes the fitting fails or contains invalid regions. For example, here the D-peak exists only in some graphene edges and elsewhere the results are invalid. It can be useful to discard such outlier regions from the dataset as NaN values.' ...
    '' ...
    '* Here R^2-fitting criteria is used to find invalid values and set them to NaN. Due to noisy signal, the fitting was only partially successful and has false-positives. For better visual and less false-positives, some invalid regions were slightly broadened algorithmically.' ...
    '' ...
    '* Commonly used graphene quality parameters, ratios of the D- and G-peak intensities and the 2D- and G-peak intensities, are evaluated and shown as examples.' ...
    '' ...
    '* Close this to continue.'});
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% !!! (E3 iii.) CLEAN-UP OF THE LORENTZ FITTED DATA
% Get invalid areas and modify I, Pos, Fwhm and I0
R_2_threshold = 0.2; % A rough threshold for very poorly fitted data
[bw_D_invalid, C_D(1).Data, C_D(2).Data, C_D(3).Data, C_D(4).Data] = ...
    data_true_and_nan_collective_hole_reduction(C_D(5).Data<R_2_threshold, ...
    C_D(1).Data, C_D(2).Data, C_D(3).Data, C_D(4).Data);
C_D(7).Data(repmat(bw_D_invalid, [1 1 size(C_D(7).Data, 3)])) = NaN; % Set invalid Fit results to NaN
[bw_G_invalid, C_G(1).Data, C_G(2).Data, C_G(3).Data, C_G(4).Data] = ...
    data_true_and_nan_collective_hole_reduction(C_G(5).Data<R_2_threshold, ...
    C_G(1).Data, C_G(2).Data, C_G(3).Data, C_G(4).Data);
C_G(7).Data(repmat(bw_G_invalid, [1 1 size(C_G(7).Data, 3)])) = NaN; % Set invalid Fit results to NaN
[bw_2D_invalid, C_2D(1).Data, C_2D(2).Data, C_2D(3).Data, C_2D(4).Data] = ...
    data_true_and_nan_collective_hole_reduction(C_2D(5).Data<R_2_threshold, ...
    C_2D(1).Data, C_2D(2).Data, C_2D(3).Data, C_2D(4).Data);
C_2D(7).Data(repmat(bw_2D_invalid, [1 1 size(C_2D(7).Data, 3)])) = NaN; % Set invalid Fit results to NaN

% Evaluate and show 2D/G AND D/G intensity ratios.
C_I_DperG = C_D(1).copy();
C_I_DperG.Data = C_D(1).Data ./ C_G(1).Data;
C_I_DperG.Name = 'Cleaned<I(D)/I(G)';

C_I_2DperG = C_2D(1).copy();
C_I_2DperG.Data = C_2D(1).Data ./ C_G(1).Data;
C_I_2DperG.Name = 'Cleaned<I(2D)/I(G)';

% Similar area-ratios can be evaluated using the areas of Gaussian and
% Lorentzian, Area_G = P(1,:).*P(3,:).*sqrt(pi./log(2))./2) and 
% Area_L = P(1,:).*P(3,:).*pi./2), respectively. Or, alternatively by use
% of of filter_sum to estimate areas under the Raman peaks.

figure;
subplot(1, 2, 1); nanimagesc(C_I_DperG.Data.'); daspect([1 1 1]); title(C_I_DperG.Name);
subplot(1, 2, 2); nanimagesc(C_I_2DperG.Data.'); daspect([1 1 1]); title(C_I_2DperG.Name);

if ishandle(h), figure(h); uiwait(h); end % Wait for helpdlg to be closed before continuing.
close all;
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = helpdlg({'!!! (E3 iv.) Histograms of the previously cleaned intensity ratios, I(D)/I(G) and I(2D)/I(G) are evaluated and shown:' ...
    '' ...
    '* Please note that the previously done cleaning procedure removed most invalid fitting values, what would have otherwise hidden these distributions.' ...
    '' ...
    '* Close this to END.'});
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% !!! (E3 iv.) CALCULATE AND SHOW HISTOGRAMS
C_hist_I_DperG = C_I_DperG.histogram();
C_hist_I_2DperG = C_I_2DperG.histogram();
figure; C_hist_I_DperG.plot();
figure; C_hist_I_2DperG.plot();

if ishandle(h), figure(h); uiwait(h); end % Wait for helpdlg to be closed before continuing.
close all;
%-------------------------------------------------------------------------%


