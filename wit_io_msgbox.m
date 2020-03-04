% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% A simple wrapper for MATLAB's built-in msgbox functionality. By default,
% opens a wit_io's Dialog -window, which has wit_io's main icon and TeX
% Interpreter enabled to more enriched text. See the msgbox documentation
% [1] for the possible TeX Markups.
% [1] https://www.mathworks.com/help/matlab/ref/msgbox.html
function h = wit_io_msgbox(message, title, icon, icondata, iconcmap, WindowStyle, Interpreter),
    % Load the default wit_io icon only once
    persistent default_icondata default_iconcmap;
    if isempty(default_icondata) || isempty(default_iconcmap),
        [default_icondata, default_iconcmap] = imread('wit_io.png');
    end
    % Parse the icon, icondata and iconcmap
    if nargin < 3 || isempty(icon), icon = 'custom'; end
    if nargin < 4 || isempty(icondata), icondata = default_icondata; end
    if nargin < 5 || isempty(icondata), iconcmap = default_iconcmap; end % By isempty(icondata) test if to use the toolbox icon
    % Parse the title
    if nargin < 2 || isempty(title),
        title = 'wit_io''s Dialog';
        if ~strcmp(icon, 'none') && ~strcmp(icon, 'custom'),
            title = sprintf('wit_io''s %s Dialog', [upper(icon(1)) icon(2:end)]);
        end
    end
    % Parse the createmode struct field values
    if nargin < 6 || isempty(WindowStyle), WindowStyle = 'replace'; end
    if nargin < 7 || isempty(Interpreter), Interpreter = 'tex'; end
    % Create the customized msgbox
    h = msgbox(message, title, icon, icondata, iconcmap, struct('WindowStyle', WindowStyle, 'Interpreter', Interpreter));
end
