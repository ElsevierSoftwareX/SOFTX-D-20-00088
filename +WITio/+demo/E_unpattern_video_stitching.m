% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO DEMO CASE E: UNPATTERN VIDEO STITCHING IMAGES
% Simple example of (E) unpatterning the Video Stitching images, removing
% the grid pattern arising during stitching procedure due to the imperfect
% view at the Video camera per frame. Frame imperfections may be caused,
% for instance, by vignetting or varying pixel sensitivity.

% Temporarily set user preferences
resetOnCleanup = WITio.tbx.pref.set({'wip_AutoCreateObj', 'wip_AutoCopyObj', 'wip_AutoModifyObj'}, {true, true, true}); % The original values prior to this call are restored when resetOnCleanup-variable is cleared.

WITio.tbx.edit(); % Open this code in Editor
close all; % Close figures

% Demo file
pathstr = WITio.tbx.path.demo; % Get folder of this script
file = fullfile(pathstr, 'E_unpattern_video_stitching_v7.wip'); % Construct full path of the demo file

%-------------------------------------------------------------------------%
WITio.tbx.license;

h = WITio.tbx.msgbox({'{\bf\fontsize{12}\color{magenta}DEMO CASE E:}' ...
'{\bf\fontsize{12}UNPATTERN VIDEO STITCHING ' ...
'IMAGES}' ...
'' ...
'\bullet If unfamiliar with ''WITio'', then go through the previous examples first.'}, '-TextWrapping', false);
WITio.tbx.uiwait(h); % Wait for WITio.tbx.msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Load all TDBitmaps and TDTexts.
[O_wid, O_wip, O_wit] = WITio.read(file, '-all', '-Manager', '--Type', 'TDBitmap', 'TDText');

O_Bitmap = O_wid(1); % Get object of "7x5 Stitching Image_021 / Exfoliated graphene (Gr) on SiO2/Si-substrate" at index 1
O_Text = O_wid(2); % Get object of "7x5 Stitching Image_021 Information" at index 2

figure; O_Bitmap.plot; WITio.tbx.ifnodesktop();
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = WITio.tbx.msgbox({'{\bf\fontsize{12}{\color{magenta}(E)} Unpatterning the Video Stitching ' ...
'images:}' ...
'' ...
'\bullet Aim is to remove the grid pattern arising during stitching procedure due to ' ...
'the imperfect view at the Video camera per frame. Frame imperfections may ' ...
'be caused, for instance, by vignetting or varying pixel sensitivity.' ...
'' ...
'\ldots Illustrative unpatterning procedure begins by closing this help dialog.'}, '-TextWrapping', false);
WITio.tbx.uiwait(h); % Wait for WITio.tbx.msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% The call below makes a fully automated brute-force search sweep of the
% unknown optimal pattern square size. Unfortunately, this bit of
% information was not stored by the WITec software's Video Stitching
% procedure and has to be brute-force searched for at least once. The
% related TDText object, containing the crucial Number of Stitching Images
% X and Y, is automatically utilized. It warns if it detects that the Video
% Stitching image has been down-scaled in any way, because then it cannot
% quarantee finding perfect solution. Here '-debug' is added for more
% verbose process feedback.
if WITio.tbx.verbose, % This is true by default (and can be set by WITio.tbx.pref.set('Verbose', tf);)
    [O_new_Bitmap, N_best, new_Data] = O_Bitmap.unpattern_video_stitching('-debug'); % Here debug-mode is used to visualize the progress to the user. It can be used for double-checking. Remove '-debug' to disable such demonstration.
end



% Or skip the brute-force search sweep by giving the optimal solution to
% it. This is useful when working with multiple Video Stitching images,
% because they have the same optimal solution (if NOT down-scaled).

if ~WITio.tbx.verbose, % This is false by default
    N_best = 181; % Known best solution
    [O_new_Bitmap, N_best] = O_Bitmap.unpattern_video_stitching(N_best); % Use known optimal solution instead of asking for the code to scan through the options
end



% Also, ask the algorithm to crop the edge patterns away, which it is
% not often good at resolving due to lack of information at those regions.

O_new_Bitmap_crop = O_Bitmap.unpattern_video_stitching(N_best, '-crop'); % Use known optimal solution instead of asking for the code to scan through the options



% Or make a manual call to the underlying unpatterning algorithm. Here we
% use the known Number of Stitching Images X and Y (via 'O_Text.plot;').

% [new_Data, N_best] = WITio.obj.wid.unpattern_video_stitching_helper(O_Bitmap.Data, [7 5], '-debug');
% new_Data = WITio.obj.wid.unpattern_video_stitching_helper(O_Bitmap.Data, [7 5], N_best, '-debug'); % With known best solution
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = WITio.tbx.msgbox({'{\bf\fontsize{12}Unpatterning has completed:}' ...
'' ...
'\bullet Read the code for more details.' ...
'' ...
'\ldots Close this dialog to END and see the final result.'}, '-TextWrapping', false);
WITio.tbx.uiwait(h); % Wait for WITio.tbx.msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
figure; O_new_Bitmap.plot; WITio.tbx.ifnodesktop();
figure; O_new_Bitmap_crop.plot; WITio.tbx.ifnodesktop();

% O_wip.write(); % Save the results by overwriting the original file
%-------------------------------------------------------------------------%

% Reset user preferences
clear resetOnCleanup; % The original values are restored here.


