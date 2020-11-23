% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Requires 3rd party export_fig
function sidebar_export(Fig),
    if nargin < 1 || isempty(Fig), Fig = gcf; end % By default, update gcf
    h_sidebar = findobj(Fig, 'Type', 'uipanel', '-and', 'Tag', 'sidebar'); % Find sidebar uipanel
    h_mainbar = findobj(Fig, 'Type', 'uipanel', '-and', 'Tag', 'mainbar'); % Find mainbar uipanel
    
    % Disable the close button until this is completed!
    CloseRequestFcn = get(Fig, 'CloseRequestFcn');
    set(Fig, 'CloseRequestFcn', []);
    
    % Temporarily adjust mainbar and sidebar if they exist
    if ~isempty(h_sidebar) && ~isempty(h_mainbar), % Backward compatible instead of ishandle
        % Temporarily change sidebar and mainbar Units to Pixels
        sidebar_Units = get(h_sidebar, 'Units');
        set(h_sidebar, 'Units', 'Pixels');
        mainbar_Units = get(h_mainbar, 'Units');
        set(h_mainbar, 'Units', 'Pixels');
        % Temporarily adjust sidebar and mainbar Positions
        sidebar_Position = get(h_sidebar, 'Position');
        set(h_sidebar, 'Visible', 'off');
%         set(h_sidebar, 'Position', [sidebar_Position(1)-sidebar_Position(3) sidebar_Position(2) 0 sidebar_Position(4)]); % Not backward compatible!
        mainbar_Position = get(h_mainbar, 'Position');
        set(h_mainbar, 'Position', [mainbar_Position(1:2) mainbar_Position(3)+sidebar_Position(3) mainbar_Position(4)]);
    end

    formats = {'*.png', 'Portable Network Graphics (*.png)'; ...
        '*.pdf', 'Portable Document Format (*.pdf)'};
    N_formats = size(formats, 1);
    % Add CROPPED versions of the formats
    formats(end+1:end+2,1) = formats(1:2,1);
    formats(end-1:end,2) = WITio.fun.anyfun2cell(@(x) sprintf('CROP >> %s', x{1}), formats(1:2,2));
    [filename, pathname, filterindex] = uiputfile(formats, 'Export figure >> 600 DPI >> ...', WITio.tbx.pref.get('latest_folder', cd));
    
    % Export if filename is provided
    if pathname ~= 0,
        file = fullfile(pathname, filename);
        WITio.tbx.pref.set('latest_folder', pathname); % Remember permanently the latest folder
        h_waitbar = waitbar(0, 'Please wait...', 'Name', 'Exporting figure');
        export_opt = {'-r600', ... % Dots Per Inch (DPI), ...
            '-nofontswap', ... % Preserves original fonts for vector formats
            '-q101'}; % Quality: q > 100 ensures lossless compression!
        if filterindex <= N_formats,
            export_opt{end+1} = '-nocrop'; % Add option: Do not crop the figure
        end
        setpref('export_fig', 'promo_time', now); % Stop export_fig from promoting consulting services once a week!
        WITio.fun.lib.export_fig.export_fig(file, Fig, export_opt{:}, '-silent');
        waitbar(1, h_waitbar);
        delete(findobj(allchild(0), 'flat', 'Tag', 'TMWWaitbar')); % Solves the closing issues with close(h_Waitbar);
    end
    
    % Restore mainbar and sidebar if they existed
    if ~isempty(h_sidebar) && ~isempty(h_mainbar), % Backward compatible instead of ishandle
        % Restore sidebar and mainbar Positions
        set(h_sidebar, 'Visible', 'on');
%         set(h_sidebar, 'Position', sidebar_Position);
        set(h_mainbar, 'Position', mainbar_Position);
        % Restore sidebar and mainbar Units
        set(h_sidebar, 'Units', sidebar_Units);
        set(h_mainbar, 'Units', mainbar_Units);
    end
    
    % Enable the close button again!
    set(Fig, 'CloseRequestFcn', CloseRequestFcn);
end
