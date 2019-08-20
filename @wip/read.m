% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [O_wid, O_wip, O_wid_HtmlNames] = read(varargin),
    % WITec Project/Data (*.WIP/*.WID) -file data reader. Returns the
    % selected data when the Project Manager -window (if opened) is CLOSED.
    % 0) Input is parsed into files and extra options:
    % *Option '-all': Skip Project Manager and load all data in the files.
    % *Option '-ifall': Inquery the user whether or not to do '-all'.
    % *Option '-LimitedRead': If given, then limit file content reading to
    % the specified number of bytes per Data and skip any exceeding Data.
    % The skipped Data is read from file later only if requested by a user.
    % If given without a number, then the limit is set to 4096.
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
    O_wid_HtmlNames = cell.empty;
    
    % START OF VARARGIN PARSING
    
    % Parse input file and extra arguments
    ind_extra_begin = varargin_dashed_str_inds('', varargin);
    if isempty(ind_extra_begin), files = varargin;
    else, files = varargin(1:ind_extra_begin(1)-1); end
    
    showProjectManager = ~varargin_dashed_str_exists('all', varargin); % By default, show Project Manager
    show_ui_ifall = varargin_dashed_str_exists('ifall', varargin);
    
    [exists, datas] = varargin_dashed_str_exists_and_datas('LimitedRead', varargin, -1);
    LimitedRead = Inf; % By default, unlimited read
    if exists,
        LimitedRead = 4096; % Default limited read in bytes
        if numel(datas) > 0, LimitedRead = datas{1}; end % Customized limited read
    end
    
    if isempty(files),
        [filename, folder] = uigetfile({'*.wip;*.wid;*.zip', 'WITec Project/Data Files (*.wip/*.wid)'}, 'Open Project', 'MultiSelect', 'on');
%         [filename, folder] = uigetfile({'*.wip;*.wid;*.zip', 'WITec Project/Data Files (*.wip/*.wid [or *.zip if compressed])'}, 'Open Project', 'MultiSelect', 'on'); % Considered implementing either indirect or direct unzipping scheme. It appears that WIT-formatted files can potentially be significantly compressed. (16.1.2019)
        if ~iscell(filename), filename = {filename}; end
        if folder ~= 0, files = fullfile(folder, filename);
        else, return; end % Abort as no file was selected!
    end
    
    % Read all files preferring limited read and append them together
    O_wit = wit.empty;
    h = waitbar(0, 'Please wait...');
    for ii = 1:numel(files),
        if ~ishandle(h), return; end % Abort if cancelled!
        waitbar((ii-1)/numel(files), h, sprintf('Loading file %d/%d. Please wait...', ii, numel(files)));
        O_wit = wip.append(O_wit, wit.read(files{ii}, LimitedRead));
    end
    if ~ishandle(h), return; end % Abort if cancelled!
    waitbar(1, h, 'Completed!');
    delete(findobj(allchild(0), 'flat', 'Tag', 'TMWWaitbar')); % Avoids the closing issues with close-function!
    O_wip = wip(O_wit);
    
    % Force DataUnit, SpaceUnit, SpectralUnit, TimeUnit:
    % Parse input arguments
    datas = varargin_dashed_str_datas('DataUnit', varargin, -1);
    if numel(datas) > 0, O_wip.ForceDataUnit = datas{1}; end
    
    datas = varargin_dashed_str_datas('SpectralUnit', varargin, -1);
    if numel(datas) > 0, O_wip.ForceSpectralUnit = datas{1}; end
    
    datas = varargin_dashed_str_datas('SpaceUnit', varargin, -1);
    if numel(datas) > 0, O_wip.ForceSpaceUnit = datas{1}; end
    
    datas = varargin_dashed_str_datas('TimeUnit', varargin, -1);
    if numel(datas) > 0, O_wip.ForceTimeUnit = datas{1}; end
    
    datas = varargin_dashed_str_datas('Manager', varargin, -1);
    ManagerVarargin = {};
    if numel(datas) > 0, ManagerVarargin = datas{1}; end
    
    % Show project manager on demand
    if show_ui_ifall, showProjectManager = strncmp(questdlg('Would you like to 1) browse & select data OR 2) load all data?', 'How to proceed?', '1) Browse & select', '2) Load all', '1) Browse & select'), '1)', 2); end
    if ~showProjectManager, ManagerVarargin{end+1} = '-nomanager'; end
    O_wid = O_wip.manager(ManagerVarargin{:});
    
    % Get html names with icons
    O_wid_HtmlNames = O_wid.get_HtmlName();
    
    % Force output to column (More user-friendly!)
    O_wid = O_wid(:);
    O_wid_HtmlNames = O_wid_HtmlNames(:); % Much more user-friendly this way!
end
