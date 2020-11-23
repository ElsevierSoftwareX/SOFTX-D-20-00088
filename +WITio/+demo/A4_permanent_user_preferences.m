% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO DEMO CASE A 4: PERMANENT USER PREFERENCES
% Simple examples of (A4) storing permanent user preferences.

WITio.tbx.edit(); % Open this code in Editor
close all; % Close figures
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
WITio.tbx.license;

h = WITio.tbx.msgbox({'{\bf\fontsize{12}\color{magenta}DEMO CASE A4:}' ...
'{\bf\fontsize{12}PERMANENT USER ' ...
'PREFERENCES}'}, '-TextWrapping', false);
WITio.tbx.uiwait(h); % Wait for WITio.tbx.msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = WITio.tbx.msgbox({'{\bf\fontsize{12}{\color{magenta}(A4)} Configure WITio with permanent ' ...
'user preferences:}' ...
'' ...
'\bullet Getting the specified user preference values (or default values):' ...
'{\bf\fontname{Courier}value = WITio.tbx.pref.get(pref, ' ...
'value);}' ...
'' ...
'\bullet Setting the specified user preference values:' ...
'{\bf\fontname{Courier}value = WITio.tbx.pref.set(pref, ' ...
'value);}' ...
'' ...
'\bullet Testing if the speficied user preferences exist:' ...
'{\bf\fontname{Courier}value = WITio.tbx.pref.is(pref);}' ...
'' ...
'\bullet Removing the specified user preferences:' ...
'{\bf\fontname{Courier}value = WITio.tbx.pref.rm(pref);}' ...
'' ...
'\bullet Read the code for more details.' ...
'' ...
'\ldots Close this dialog to END.'}, '-TextWrapping', false);
WITio.tbx.uiwait(h); % Wait for WITio.tbx.msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Permanent session-to-session user preferences are available since WITio
% v1.2.0. Currently there are only the following wip-class user preferences
% available (and 'license_dialog') but more may be added later on
% (especially if the users should request them). These functions and their
% behaviour are built on MATLAB's built-in getpref, setpref, ispref, rmpref
% functions.

% Get user preferences (or default values if not found)
pref_value_pairs_struct = WITio.tbx.pref.get(); % Get all the user preferences as a struct
license_dialog = WITio.tbx.pref.get('license_dialog'); % No default value given here
latest_folder = WITio.tbx.pref.get('latest_folder', cd);
wip_ForceDataUnit = WITio.tbx.pref.get('wip_ForceDataUnit', '');
wip_ForceSpaceUnit = WITio.tbx.pref.get('wip_ForceSpaceUnit', '');
wip_ForceSpectralUnit = WITio.tbx.pref.get('wip_ForceSpectralUnit', '');
wip_ForceTimeUnit = WITio.tbx.pref.get('wip_ForceTimeUnit', '');
wip_OnWriteDestroyAllViewers = WITio.tbx.pref.get('wip_OnWriteDestroyAllViewers', true);
wip_OnWriteDestroyDuplicateTransformations = WITio.tbx.pref.get('wip_OnWriteDestroyDuplicateTransformations', true);
wip_UseLineValid = WITio.tbx.pref.get('wip_UseLineValid', true);
wip_AutoCreateObj = WITio.tbx.pref.get('wip_AutoCreateObj', true);
wip_AutoCopyObj = WITio.tbx.pref.get('wip_AutoCopyObj', true);
wip_AutoModifyObj = WITio.tbx.pref.get('wip_AutoModifyObj', true);



% Set user preferences
WITio.tbx.pref.set('license_dialog', true);
WITio.tbx.pref.set('latest_folder', cd);
WITio.tbx.pref.set('wip_ForceDataUnit', 'a.u.');
WITio.tbx.pref.set('wip_ForceSpaceUnit', 'um');
WITio.tbx.pref.set('wip_ForceSpectralUnit', 'nm');
WITio.tbx.pref.set('wip_ForceTimeUnit', 's');
WITio.tbx.pref.set('wip_OnWriteDestroyAllViewers', false);
WITio.tbx.pref.set('wip_OnWriteDestroyDuplicateTransformations', false);
WITio.tbx.pref.set('wip_UseLineValid', false);
WITio.tbx.pref.set('wip_AutoCreateObj', false);
WITio.tbx.pref.set('wip_AutoCopyObj', false);
WITio.tbx.pref.set('wip_AutoModifyObj', false);
% The above settings would be utilized by the next created wip-class
% objects. Changing these will not affect the already existing objects.



% Removing user preferences (and returning to the default values for the
% next created objects).
WITio.tbx.pref.rm('wip_ForceTimeUnit'); % Removes the specified user preference
WITio.tbx.pref.rm({'wip_ForceTimeUnit', 'wip_ForceSpectralUnit'}); % Removes the specified user preferences
WITio.tbx.pref.rm(pref_value_pairs_struct); % Removes the specified user preferences
WITio.tbx.pref.rm(); % Removes all the user preferences
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Restore the original user preferences to remove any unwanted
% modifications during this example script.
WITio.tbx.pref.set(pref_value_pairs_struct);
%-------------------------------------------------------------------------%


