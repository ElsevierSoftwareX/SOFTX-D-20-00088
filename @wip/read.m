% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [O_wid, O_wip, O_HtmlNames] = read(varargin),
    % WITec Project/Data (*.WIP/*.WID) -file data reader. Returns the
    % selected data when the Project Manager -window (if opened) is CLOSED.
    % 0) Input is parsed into files and extra options:
    % *Option '-all': Skip Project Manager and load all data in the files.
    % *Option '-ifall': Inquery the user whether or not to do '-all'.
    % *Options '-DataUnit', '-SpaceUnit', '-SpectralUnit' and '-TimeUnit':
    % Force the output units. This is very useful for automated processing.
    % *Option '-Manager': Pass any varargin to Project Manager. For
    % instance, can be used to load all data with specified Type / SubType.
    % 1) If the file input is omitted, then a file browsing GUI is opened.
    % 2) The specified file is loaded, processed and shown in a new window.
    % 3) Project Manager -window allows preview of all data in the project.
    % 4) The selected items in Project Manager -window are returned.
    
    % By default, empty output
    O_wid = wid.Empty;
    O_wip = wip.empty;
    O_HtmlNames = cell.empty;
    
    % Parse input file and extra arguments
    ind_extra_begin = find(strncmp(varargin, '-', 1));
    ind_extra_end = [ind_extra_begin(2:end)-1 numel(varargin)];
    showProjectManager = ~any(strcmpi(varargin(ind_extra_begin), '-all')); % By default, show Project Manager
    show_ui_ifall = any(strcmpi(varargin(ind_extra_begin), '-ifall'));
    ind_DataUnit = find(strcmpi(varargin(ind_extra_begin), '-DataUnit'), 1, 'first');
    ind_SpectralUnit = find(strcmpi(varargin(ind_extra_begin), '-SpectralUnit'), 1, 'first');
    ind_SpaceUnit = find(strcmpi(varargin(ind_extra_begin), '-SpaceUnit'), 1, 'first');
    ind_TimeUnit = find(strcmpi(varargin(ind_extra_begin), '-TimeUnit'), 1, 'first');
    ind_Manager = find(strcmpi(varargin(ind_extra_begin), '-Manager'), 1, 'first');
    
    if isempty(ind_extra_begin), files = varargin;
    else, files = varargin(1:ind_extra_begin(1)-1); end
    
    if isempty(files),
        [filename, folder] = uigetfile({'*.wip;*.wid;*.zip', 'WITec Project/Data Files (*.wip/*.wid)'}, 'Open Project', 'MultiSelect', 'on');
%         [filename, folder] = uigetfile({'*.wip;*.wid;*.zip', 'WITec Project/Data Files (*.wip/*.wid [or *.zip if compressed])'}, 'Open Project', 'MultiSelect', 'on'); % Considered implementing either indirect or direct unzipping scheme. It appears that WIT-formatted files can potentially be significantly compressed. (16.1.2019)
        if ~iscell(filename), filename = {filename}; end
        if folder ~= 0, files = fullfile(folder, filename);
        else, return; end % Abort as no file was selected!
    end
    
    % Read all files preferring limited read and append them together
    O_wit = wit.Empty;
    h = waitbar(0, 'Please wait...');
    for ii = 1:numel(files),
        if ~ishandle(h), return; end % Abort if cancelled!
        waitbar((ii-1)/numel(files), h, sprintf('Loading file %d/%d. Please wait...', ii, numel(files)));
        O_wit = wip.append(O_wit, wit.read(files{ii}, 4096)); % Prefer 4KB limited read
    end
    if ~ishandle(h), return; end % Abort if cancelled!
    waitbar(1, h, 'Completed!');
    delete(findobj(allchild(0), 'flat', 'Tag', 'TMWWaitbar')); % Avoids the closing issues with close-function!
    O_wip = wip(O_wit);
    
    % Force DataUnit, SpaceUnit, SpectralUnit, TimeUnit:
    % Parse input arguments
    if ~isempty(ind_DataUnit) && ind_extra_end(ind_DataUnit)-ind_extra_begin(ind_DataUnit) > 0,
        O_wip.ForceDataUnit = varargin{ind_extra_end(ind_DataUnit)};
    end
    if ~isempty(ind_SpaceUnit) && ind_extra_end(ind_SpaceUnit)-ind_extra_begin(ind_SpaceUnit) > 0,
        O_wip.ForceSpaceUnit = varargin{ind_extra_end(ind_SpaceUnit)};
    end
    if ~isempty(ind_SpectralUnit) && ind_extra_end(ind_SpectralUnit)-ind_extra_begin(ind_SpectralUnit) > 0,
        O_wip.ForceSpectralUnit = varargin{ind_extra_end(ind_SpectralUnit)};
    end
    if ~isempty(ind_TimeUnit) && ind_extra_end(ind_TimeUnit)-ind_extra_begin(ind_TimeUnit) > 0,
        O_wip.ForceTimeUnit = varargin{ind_extra_end(ind_TimeUnit)};
    end
    ManagerVarargin = {};
    if ~isempty(ind_Manager) && ind_extra_end(ind_Manager)-ind_extra_begin(ind_Manager) > 0,
        ManagerVarargin = varargin{ind_extra_end(ind_Manager)};
    end
    
    % Show project manager on demand
    if show_ui_ifall, showProjectManager = strncmp(questdlg('Would you like to 1) browse & select data OR 2) load all data?', 'How to proceed?', '1) Browse & select', '2) Load all', '1) Browse & select'), '1)', 2); end
    if ~showProjectManager, ManagerVarargin{end+1} = '-nomanager'; end
    O_wid = O_wip.manager(ManagerVarargin{:});
    
    % Get html names with icons
    O_HtmlNames = O_wid.get_HtmlName();
    
    % Force output to column (More user-friendly!)
    O_wid = O_wid(:);
    O_HtmlNames = O_HtmlNames(:); % Much more user-friendly this way!
end
