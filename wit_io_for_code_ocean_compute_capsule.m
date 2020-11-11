% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function is intended to be ran only inside the Code Ocean compute
% capsule, intended to non-interactively demonstrate all the example cases
% in the toolbox.
function wit_io_for_code_ocean_compute_capsule(AutoCloseInSeconds),
    if nargin == 0, AutoCloseInSeconds = 0; end % By default, auto close without any delay
    wit_io_pref_set('AutoCloseInSeconds', AutoCloseInSeconds);
    ocu = onCleanup(@() wit_io_pref_set('AutoCloseInSeconds', Inf)); % Restore original value on close
    
    % Run each example case one by one
    pathstr = fileparts([mfilename('fullpath') '.m']);
    S = dir(fullfile(pathstr, 'EXAMPLE cases'));
    S = S(~[S.isdir]); % Exclude directories
    names = {S.name};
    [~, names, ext] = cellfun(@fileparts, names, 'UniformOutput', false);
    names = names(strcmp(ext, '.m')); % Keep *.m files
    for ii = 1:numel(names),
        str_msg = 'NON-INTERACTIVE MODE (interruptable with Ctrl+C):';
        str_dashes = repmat('-', [1 max(numel(str_msg), numel(names{ii}))]);
        fprintf('%s\n%s\n%s\n%s\n\n', str_dashes, str_msg, names{ii}, str_dashes);
        wit_io_for_code_ocean_compute_capsule_helper(names{ii});
        fprintf('\n\n');
    end
end
