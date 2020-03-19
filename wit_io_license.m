% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This always returns a 'BSD 3-Clause License' char array. If allowed by
% the user preference, then open a License Dialog -window, describing the
% wit_io toolbox license's span and freedom of usage. To reset this user
% preference, execute wit_io_pref_rm('license_dialog').
function license = wit_io_license(),
    % Convert non-false-value to 'ask' (required by uigetpref)
    value = wit_io_pref_get('license_dialog');
    if ~islogical(value) || numel(value) ~= 1 || value ~= false,
        wit_io_pref_set('license_dialog', 'ask');
    end
    
    % Show dialog (if user preference allows it)
    uigetpref('wit_io', 'license_dialog', 'License Dialog', ...
    {'Code of ''wit_io'' toolbox is mostly open-sourced under', ...
    'the simple and permissive BSD 3-Clause License and', ...
    'is free-to-use like described in LICENSE file!', ...
    '', ...
    'Toolbox users are welcome to contribute to the code at', ...
    'https://gitlab.com/jtholmi/wit_io.', ...
    '', ...
    '(Only exceptions to this license can be found among', ...
    'the ''3rd party''-folder code under ''helper''-folder.)'}, ...
    'OK');
    
    % Convert uigetpref's 'ask'-value to true and otherwise false.
    if strcmp(wit_io_pref_get('license_dialog'), 'ask'),
        wit_io_pref_set('license_dialog', true);
    else,
        wit_io_pref_set('license_dialog', false);
    end
    
    % Return wit_io's license
    license = 'BSD 3-Clause License';
end
