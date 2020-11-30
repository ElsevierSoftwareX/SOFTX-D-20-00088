% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This is used to export figures when running MATLAB with -nodesktop. Use
% WITio.tbx.pref.set({'ifnodesktop_dpi', 'ifnodesktop_renderer'}, {dpi,
% renderer}) to customize the export dpi and renderer.
function ifnodesktop(fig),
    counter = WITio.tbx.pref.get('ifnodesktop_counter', 0) + 1;
    if nargin == 0, fig = gcf; end % By default, export the current figure
    % See which function called this and which line
    S = dbstack('-completenames');
    name = 'Base'; % Special case, where caller is Command Window
    if numel(S) > 1,
        [~, name, ext] = fileparts(S(2).file);
        name = sprintf('%s%s line %03d', name, ext, S(2).line);
    end
    % Prepare to export
    name = sprintf('Figure %03d. %s', counter, name); % Add counter in front
    ext = WITio.tbx.pref.get('ifnodesktop_ext', '.png'); % Default export extension
    path = WITio.tbx.pref.get('ifnodesktop_path', '.'); % Default export path
    file = fullfile(path, [name ext]); % Construct full path
    export_opt = {['-' WITio.tbx.pref.get('ifnodesktop_renderer', 'painters')], ... % Painters works with Linux as well
        sprintf('-r%d', WITio.tbx.pref.get('ifnodesktop_dpi', 300)), ... % Dots Per Inch (DPI), ...
        '-nofontswap', ... % Preserves original fonts for vector formats
        '-q101'}; % Quality: q > 100 ensures lossless compression!
    setpref('export_fig', 'promo_time', now); % Stop export_fig from promoting consulting services once a week!
    export_fig(file, fig, export_opt{:}, '-silent'); % Try export figure to file
    WITio.tbx.pref.set('ifnodesktop_counter', counter); % Update counter
end
