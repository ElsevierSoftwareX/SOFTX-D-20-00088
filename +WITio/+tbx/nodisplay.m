% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This is used to export figures when running MATLAB with -nodisplay.
function nodisplay(fig),
    persistent counter;
    if isempty(counter), counter = 0; end
    counter = counter + 1;
    if nargin == 0, fig = gcf; end % By default, export the current figure
    % See which function called this and which line
    S = dbstack('-completenames');
    name = 'Base'; % Special case, where caller is Command Window
    if numel(S) > 1,
        [~, name, ext] = fileparts(S(2).file);
        name = sprintf('%s%s line %03d', name, ext, S(2).line);
    end
    % Prepare to export
    name = sprintf('%03d_%s', counter, name); % Add counter in front
    ext = WITio.tbx.pref.get('nodisplay_ext', '.png'); % Default export extension
    path = WITio.tbx.pref.get('nodisplay_path', WITio.tbx.path); % Default export path
    file = fullfile(path, [name ext]); % Construct full path
    WITio.tbx.ui.sidebar_export(fig, file); % Try export figure to file
end
