% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO EXAMPLE CASE A 4: PERMANENT USER PREFERENCES
% Simple examples of (A4) storing permanent user preferences.

WITio.misc.edit(); % Open this code in Editor
close all; % Close figures
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
WITio.misc.license;

h = WITio.misc.msgbox({'{\bf\fontsize{12}\color{magenta}EXAMPLE CASE A4:}' ...
'{\bf\fontsize{12}PERMANENT USER ' ...
'PREFERENCES}'}, '-TextWrapping', false);
WITio.misc.uiwait(h); % Wait for WITio.misc.msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = WITio.misc.msgbox({'{\bf\fontsize{12}{\color{magenta}(A4)} Configure WITio with permanent ' ...
'user preferences:}' ...
'' ...
'\bullet Getting the specified user preference values (or default values):' ...
'{\bf\fontname{Courier}value = WITio.pref.get(pref, ' ...
'value);}' ...
'' ...
'\bullet Setting the specified user preference values:' ...
'{\bf\fontname{Courier}value = WITio.pref.set(pref, ' ...
'value);}' ...
'' ...
'\bullet Testing if the speficied user preferences exist:' ...
'{\bf\fontname{Courier}value = WITio.pref.is(pref);}' ...
'' ...
'\bullet Removing the specified user preferences:' ...
'{\bf\fontname{Courier}value = WITio.pref.rm(pref);}' ...
'' ...
'\bullet Read the code for more details.' ...
'' ...
'\ldots Close this dialog to END.'}, '-TextWrapping', false);
WITio.misc.uiwait(h); % Wait for WITio.misc.msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Permanent session-to-session user preferences are available since WITio
% v1.2.0. Currently there are only the following wip-class user preferences
% available (and 'license_dialog') but more may be added later on
% (especially if the users should request them). These functions and their
% behaviour are built on MATLAB's built-in getpref, setpref, ispref, rmpref
% functions.

% Get user preferences (or default values if not found)
pref_value_pairs_struct = WITio.pref.get(); % Get all the user preferences as a struct
license_dialog = WITio.pref.get('license_dialog'); % No default value given here
latest_folder = WITio.pref.get('latest_folder', cd);
wip_ForceDataUnit = WITio.pref.get('wip_ForceDataUnit', '');
wip_ForceSpaceUnit = WITio.pref.get('wip_ForceSpaceUnit', '');
wip_ForceSpectralUnit = WITio.pref.get('wip_ForceSpectralUnit', '');
wip_ForceTimeUnit = WITio.pref.get('wip_ForceTimeUnit', '');
wip_OnWriteDestroyAllViewers = WITio.pref.get('wip_OnWriteDestroyAllViewers', true);
wip_OnWriteDestroyDuplicateTransformations = WITio.pref.get('wip_OnWriteDestroyDuplicateTransformations', true);
wip_UseLineValid = WITio.pref.get('wip_UseLineValid', true);
wip_AutoCreateObj = WITio.pref.get('wip_AutoCreateObj', true);
wip_AutoCopyObj = WITio.pref.get('wip_AutoCopyObj', true);
wip_AutoModifyObj = WITio.pref.get('wip_AutoModifyObj', true);



% Set user preferences
WITio.pref.set('license_dialog', true);
WITio.pref.set('latest_folder', cd);
WITio.pref.set('wip_ForceDataUnit', 'a.u.');
WITio.pref.set('wip_ForceSpaceUnit', 'um');
WITio.pref.set('wip_ForceSpectralUnit', 'nm');
WITio.pref.set('wip_ForceTimeUnit', 's');
WITio.pref.set('wip_OnWriteDestroyAllViewers', false);
WITio.pref.set('wip_OnWriteDestroyDuplicateTransformations', false);
WITio.pref.set('wip_UseLineValid', false);
WITio.pref.set('wip_AutoCreateObj', false);
WITio.pref.set('wip_AutoCopyObj', false);
WITio.pref.set('wip_AutoModifyObj', false);
% The above settings would be utilized by the next created wip-class
% objects. Changing these will not affect the already existing objects.



% Removing user preferences (and returning to the default values for the
% next created objects).
WITio.pref.rm('wip_ForceTimeUnit'); % Removes the specified user preference
WITio.pref.rm({'wip_ForceTimeUnit', 'wip_ForceSpectralUnit'}); % Removes the specified user preferences
WITio.pref.rm(pref_value_pairs_struct); % Removes the specified user preferences
WITio.pref.rm(); % Removes all the user preferences
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Restore the original user preferences to remove any unwanted
% modifications during this example script.
WITio.pref.set(pref_value_pairs_struct);
%-------------------------------------------------------------------------%


