% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [O_wid, O_wip, O_wid_HtmlNames] = read(varargin),
    % WITec Project/Data (*.WIP/*.WID) -file data reader. Returns the
    % selected data when the Project Manager -window (if opened) is CLOSED.
    % 0) Input is parsed into files and extra case-insensitive options:
    % *Option '-all': Skip Project Manager and load all data in the files.
    % *Option '-ifall': Inquery the user whether or not to do '-all'.
    % *Option '-LimitedRead': If given, then limit file content reading to
    % the specified number of bytes per Data and skip any exceeding Data.
    % The skipped Data is read from file later only if requested by a user.
    % If given without a number, then the limit is set to 4096.
    % *Options '-DataUnit', '-SpaceUnit', '-SpectralUnit' and '-TimeUnit':
    % Force the output units. This is very useful for automated processing.
    % *Option '-Manager': Passes the given inputs to Project Manager:
    % (1) by providing the inputs in a single cell, i.e. {'-all'}, OR
    % (2) by writing the related single-dashed strings as double-dashed,
    % i.e. '-all' becomes '--all'. For instance, it can be used to load all
    % data with specified Type / SubType.
    % 1) If the file input is omitted, then a file browsing GUI is opened.
    % 2) The specified file is loaded, processed and shown in a new window.
    % 3) Project Manager -window allows preview of all data in the project.
    % 4) The selected items in Project Manager -window are returned.
    
    % By default, empty output
    O_wid = WITio.core.wid.empty;
    O_wip = WITio.core.wip.empty;
    O_wid_HtmlNames = cell.empty;
    
    % START OF VARARGIN PARSING
    
    % Parse input file and extra arguments
    ind_extra_begin = WITio.fun.varargin_dashed_str.inds('', varargin);
    if isempty(ind_extra_begin), files = varargin;
    else, files = varargin(1:ind_extra_begin(1)-1); end
    
    showProjectManager = ~WITio.fun.varargin_dashed_str.exists('all', varargin); % By default, show Project Manager
    show_ui_ifall = WITio.fun.varargin_dashed_str.exists('ifall', varargin);
    
    [exists, datas] = WITio.fun.varargin_dashed_str.exists_and_datas('LimitedRead', varargin, -1);
    LimitedRead = Inf; % By default, unlimited read
    if exists,
        LimitedRead = 4096; % Default limited read in bytes
        if numel(datas) > 0, LimitedRead = datas{1}; end % Customized limited read
    end
    
    % Check if Params was specified
    Params = WITio.fun.varargin_dashed_str.datas('Params', varargin);
    
    if isempty(files),
        filter = {'*.wip;*.wiP;*.wIp;*.wIP;*.Wip;*.WiP;*.WIp;*.WIP;*.wid;*.wiD;*.wId;*.wID;*.Wid;*.WiD;*.WId;*.WID;*.zip;*.ziP;*.zIp;*.zIP;*.Zip;*.ZiP;*.ZIp;*.ZIP;*.zst;*.zsT;*.zSt;*.zST;*.Zst;*.ZsT;*.ZSt;*.ZST', 'WITec Project/Data Files (*.wip/*.wid) or Compressed Files (*.zip/*.zst)'; ...
            '*.wip;*.wiP;*.wIp;*.wIP;*.Wip;*.WiP;*.WIp;*.WIP', 'WITec Project Files (*.wip)'; ...
            '*.wid;*.wiD;*.wId;*.wID;*.Wid;*.WiD;*.WId;*.WID', 'WITec Data Files (*.wid)'; ...
            '*.zip;*.ziP;*.zIp;*.zIP;*.Zip;*.ZiP;*.ZIp;*.ZIP', 'Compressed Files (*.zip)'; ...
            '*.zst;*.zsT;*.zSt;*.zST;*.Zst;*.ZsT;*.ZSt;*.ZST', 'Compressed Files (*.zst)'};
        [filename, folder] = uigetfile(filter, 'Open Project', WITio.core.pref.get('latest_folder', cd), 'MultiSelect', 'on');
        if ~iscell(filename), filename = {filename}; end
        if folder ~= 0,
            files = fullfile(folder, filename);
            WITio.core.pref.set('latest_folder', folder); % Remember permanently the latest folder
        else, return; end % Abort as no file was selected!
    end
    
    % Determine the compressed file extension
    compressed_ext = {'.zip', '.zst'};
    
    % Read all files preferring limited read and append them together
    O_wit = WITio.core.wit.empty;
    h = waitbar(0, 'Please wait...');
    for ii = 1:numel(files),
        if ~ishandle(h), return; end % Abort if cancelled!
        waitbar((ii-1)/numel(files), h, sprintf('Loading file %d/%d. Please wait...', ii, numel(files)));
        
        % Add the required file extension if it is missing nor is compression used
        [~, ~, ext] = fileparts(files{ii});
        OnReadDecompress = any(strcmpi(compressed_ext, ext));
        
        if OnReadDecompress, % Read compressed
            O_wit = OnReadDecompress_loop(O_wit, files{ii});
        else, % Read uncompressed
            O_wit_new = WITio.core.wit.read(files{ii}, LimitedRead);
            O_wit = WITio.core.wip.append(O_wit, O_wit_new);
        end
    end
    if ~ishandle(h), return; end % Abort if cancelled!
    waitbar(1, h, 'Completed!');
    delete(findobj(allchild(0), 'flat', 'Tag', 'TMWWaitbar')); % Avoids the closing issues with close-function!
    if isempty(O_wit), return; end % Abort if no file to read!
    O_wip = WITio.core.wip(O_wit);
    
    % Force DataUnit, SpaceUnit, SpectralUnit, TimeUnit:
    % Parse input arguments
    datas = WITio.fun.varargin_dashed_str.datas('DataUnit', varargin, -1);
    if numel(datas) > 0, O_wip.ForceDataUnit = datas{1}; end
    
    datas = WITio.fun.varargin_dashed_str.datas('SpectralUnit', varargin, -1);
    if numel(datas) > 0, O_wip.ForceSpectralUnit = datas{1}; end
    
    datas = WITio.fun.varargin_dashed_str.datas('SpaceUnit', varargin, -1);
    if numel(datas) > 0, O_wip.ForceSpaceUnit = datas{1}; end
    
    datas = WITio.fun.varargin_dashed_str.datas('TimeUnit', varargin, -1);
    if numel(datas) > 0, O_wip.ForceTimeUnit = datas{1}; end
    
    datas = WITio.fun.varargin_dashed_str.datas('Manager', varargin);
    ManagerVarargin = {};
    if numel(datas) == 1 && iscell(datas{1}), ManagerVarargin = datas{1}; % Special case of {}-enclosed inputs
    elseif numel(datas) > 0, ManagerVarargin = datas; end
    
    % Show project manager on demand
    if show_ui_ifall, showProjectManager = strncmp(questdlg('Would you like to 1) browse & select data OR 2) load all data?', 'How to proceed?', '1) Browse & select', '2) Load all', '1) Browse & select'), '1)', 2); end
    if ~showProjectManager, ManagerVarargin{end+1} = '-nomanager'; end
    O_wid = O_wip.manager(ManagerVarargin{:});
    
    % Get html names with icons
    O_wid_HtmlNames = O_wid.get_HtmlName();
    
    % Force output to column (More user-friendly!)
    O_wid = O_wid(:);
    O_wid_HtmlNames = O_wid_HtmlNames(:); % Much more user-friendly this way!
    
    function obj = OnReadDecompress_loop(obj, File),
        % Get file name
        [~, name, ext] = fileparts(File);
        FileName = [name ext];
        fprintf('\nReading from file: %s\n', FileName);
        % Decompress
        [~, zip_datas] = WITio.file.decompress(File, '-FilterExtension', '.wip', '.wid', '-ProgressBar', Params{:}); % Decompress binary from zip archive
        % Loop through data entries
        for jj = 1:numel(zip_datas),
            obj_new = WITio.core.wit.read(File, LimitedRead, [], [], '-CustomFun', @OnReadDecompress_helper, '-Silent');
            obj = WITio.core.wip.append(obj, obj_new);
        end
        function OnReadDecompress_helper(obj, File),
            obj.bread(zip_datas{jj});
        end
    end
end
