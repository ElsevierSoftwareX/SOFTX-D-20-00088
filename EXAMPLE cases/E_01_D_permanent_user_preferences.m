% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO EXAMPLE CASE 1 D: PERMANENT USER PREFERENCES
% Simple examples of (E1D) storing permanent user preferences.

wit_io_edit(); % Open this code in Editor
close all; % Close figures
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
wit_io_license;

h = wit_io_msgbox({'{\bf\fontsize{12}\color{magenta}EXAMPLE CASE 1 D:}' ...
    '{\bf\fontsize{12}PERMANENT USER PREFERENCES}'});
wit_io_uiwait(h); % Wait for wit_io_msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = wit_io_msgbox({'{\bf\fontsize{12}{\color{magenta}(E1D)} Configure wit\_io with permanent user preferences:}' ...
    '' ...
    '\bullet Getting the specified user preference values (or default values):' ...
    '{\bf\fontname{Courier}value = wit\_io\_pref\_get(pref, value);}' ...
    '' ...
    '\bullet Setting the specified user preference values:' ...
    '{\bf\fontname{Courier}value = wit\_io\_pref\_set(pref, value);}' ...
    '' ...
    '\bullet Testing if the speficied user preferences exist:' ...
    '{\bf\fontname{Courier}value = wit\_io\_pref\_is(pref);}' ...
    '' ...
    '\bullet Removing the specified user preferences:' ...
    '{\bf\fontname{Courier}value = wit\_io\_pref\_rm(pref);}' ...
    '' ...
    '\bullet Read the code for more details.' ...
    '' ...
    '\ldots Close this dialog to END.'});
wit_io_uiwait(h); % Wait for wit_io_msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Permanent session-to-session user preferences are available since wit_io
% v1.2.0. Currently there are only the following wip-class user preferences
% available (and 'license_dialog') but more may be added later on
% (especially if the users should request them). These functions and their
% behaviour are built on MATLAB's built-in getpref, setpref, ispref, rmpref
% functions.

% Get user preferences (or default values if not found)
pref_value_pairs_struct = wit_io_pref_get(); % Get all the user preferences as a struct
license_dialog = wit_io_pref_get('license_dialog'); % No default value given here
latest_folder = wit_io_pref_get('latest_folder', cd);
wip_ForceDataUnit = wit_io_pref_get('wip_ForceDataUnit', '');
wip_ForceSpaceUnit = wit_io_pref_get('wip_ForceSpaceUnit', '');
wip_ForceSpectralUnit = wit_io_pref_get('wip_ForceSpectralUnit', '');
wip_ForceTimeUnit = wit_io_pref_get('wip_ForceTimeUnit', '');
wip_OnWriteDestroyAllViewers = wit_io_pref_get('wip_OnWriteDestroyAllViewers', true);
wip_OnWriteDestroyDuplicateTransformations = wit_io_pref_get('wip_OnWriteDestroyDuplicateTransformations', true);
wip_UseLineValid = wit_io_pref_get('wip_UseLineValid', true);
wip_AutoCreateObj = wit_io_pref_get('wip_AutoCreateObj', true);
wip_AutoCopyObj = wit_io_pref_get('wip_AutoCopyObj', true);
wip_AutoModifyObj = wit_io_pref_get('wip_AutoModifyObj', true);



% Set user preferences
wit_io_pref_set('license_dialog', true);
wit_io_pref_set('latest_folder', cd);
wit_io_pref_set('wip_ForceDataUnit', 'a.u.');
wit_io_pref_set('wip_ForceSpaceUnit', 'um');
wit_io_pref_set('wip_ForceSpectralUnit', 'nm');
wit_io_pref_set('wip_ForceTimeUnit', 's');
wit_io_pref_set('wip_OnWriteDestroyAllViewers', false);
wit_io_pref_set('wip_OnWriteDestroyDuplicateTransformations', false);
wit_io_pref_set('wip_UseLineValid', false);
wit_io_pref_set('wip_AutoCreateObj', false);
wit_io_pref_set('wip_AutoCopyObj', false);
wit_io_pref_set('wip_AutoModifyObj', false);
% The above settings would be utilized by the next created wip-class
% objects. Changing these will not affect the already existing objects.



% Removing user preferences (and returning to the default values for the
% next created objects).
wit_io_pref_rm('wip_ForceTimeUnit'); % Removes the specified user preference
wit_io_pref_rm({'wip_ForceTimeUnit', 'wip_ForceSpectralUnit'}); % Removes the specified user preferences
wit_io_pref_rm(pref_value_pairs_struct); % Removes the specified user preferences
wit_io_pref_rm(); % Removes all the user preferences
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Restore the original user preferences to remove any unwanted
% modifications during this example script.
wit_io_pref_set(pref_value_pairs_struct);
%-------------------------------------------------------------------------%


