% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

%% WIT_IO EXAMPLE CASE A 4: PERMANENT USER PREFERENCES
% Simple examples of (A4) storing permanent user preferences.

WITio.self.edit(); % Open this code in Editor
close all; % Close figures
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
WITio.self.license;

h = WITio.self.msgbox({'{\bf\fontsize{12}\color{magenta}EXAMPLE CASE A4:}' ...
'{\bf\fontsize{12}PERMANENT USER ' ...
'PREFERENCES}'}, '-TextWrapping', false);
WITio.self.uiwait(h); % Wait for WITio.self.msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
h = WITio.self.msgbox({'{\bf\fontsize{12}{\color{magenta}(A4)} Configure WITio with permanent ' ...
'user preferences:}' ...
'' ...
'\bullet Getting the specified user preference values (or default values):' ...
'{\bf\fontname{Courier}value = WITio.self.pref.get(pref, ' ...
'value);}' ...
'' ...
'\bullet Setting the specified user preference values:' ...
'{\bf\fontname{Courier}value = WITio.self.pref.set(pref, ' ...
'value);}' ...
'' ...
'\bullet Testing if the speficied user preferences exist:' ...
'{\bf\fontname{Courier}value = WITio.self.pref.is(pref);}' ...
'' ...
'\bullet Removing the specified user preferences:' ...
'{\bf\fontname{Courier}value = WITio.self.pref.rm(pref);}' ...
'' ...
'\bullet Read the code for more details.' ...
'' ...
'\ldots Close this dialog to END.'}, '-TextWrapping', false);
WITio.self.uiwait(h); % Wait for WITio.self.msgbox to be closed before continuing.
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Permanent session-to-session user preferences are available since WITio
% v1.2.0. Currently there are only the following wip-class user preferences
% available (and 'license_dialog') but more may be added later on
% (especially if the users should request them). These functions and their
% behaviour are built on MATLAB's built-in getpref, setpref, ispref, rmpref
% functions.

% Get user preferences (or default values if not found)
pref_value_pairs_struct = WITio.self.pref.get(); % Get all the user preferences as a struct
license_dialog = WITio.self.pref.get('license_dialog'); % No default value given here
latest_folder = WITio.self.pref.get('latest_folder', cd);
wip_ForceDataUnit = WITio.self.pref.get('wip_ForceDataUnit', '');
wip_ForceSpaceUnit = WITio.self.pref.get('wip_ForceSpaceUnit', '');
wip_ForceSpectralUnit = WITio.self.pref.get('wip_ForceSpectralUnit', '');
wip_ForceTimeUnit = WITio.self.pref.get('wip_ForceTimeUnit', '');
wip_OnWriteDestroyAllViewers = WITio.self.pref.get('wip_OnWriteDestroyAllViewers', true);
wip_OnWriteDestroyDuplicateTransformations = WITio.self.pref.get('wip_OnWriteDestroyDuplicateTransformations', true);
wip_UseLineValid = WITio.self.pref.get('wip_UseLineValid', true);
wip_AutoCreateObj = WITio.self.pref.get('wip_AutoCreateObj', true);
wip_AutoCopyObj = WITio.self.pref.get('wip_AutoCopyObj', true);
wip_AutoModifyObj = WITio.self.pref.get('wip_AutoModifyObj', true);



% Set user preferences
WITio.self.pref.set('license_dialog', true);
WITio.self.pref.set('latest_folder', cd);
WITio.self.pref.set('wip_ForceDataUnit', 'a.u.');
WITio.self.pref.set('wip_ForceSpaceUnit', 'um');
WITio.self.pref.set('wip_ForceSpectralUnit', 'nm');
WITio.self.pref.set('wip_ForceTimeUnit', 's');
WITio.self.pref.set('wip_OnWriteDestroyAllViewers', false);
WITio.self.pref.set('wip_OnWriteDestroyDuplicateTransformations', false);
WITio.self.pref.set('wip_UseLineValid', false);
WITio.self.pref.set('wip_AutoCreateObj', false);
WITio.self.pref.set('wip_AutoCopyObj', false);
WITio.self.pref.set('wip_AutoModifyObj', false);
% The above settings would be utilized by the next created wip-class
% objects. Changing these will not affect the already existing objects.



% Removing user preferences (and returning to the default values for the
% next created objects).
WITio.self.pref.rm('wip_ForceTimeUnit'); % Removes the specified user preference
WITio.self.pref.rm({'wip_ForceTimeUnit', 'wip_ForceSpectralUnit'}); % Removes the specified user preferences
WITio.self.pref.rm(pref_value_pairs_struct); % Removes the specified user preferences
WITio.self.pref.rm(); % Removes all the user preferences
%-------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
% Restore the original user preferences to remove any unwanted
% modifications during this example script.
WITio.self.pref.set(pref_value_pairs_struct);
%-------------------------------------------------------------------------%


