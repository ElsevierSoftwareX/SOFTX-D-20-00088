% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function O_wid = manager(obj, varargin),
    if isempty(obj), error('No project given!'); end
    
    % START OF VARARGIN PARSING
    
    % Parse extra arguments
    show_all = varargin_dashed_str_exists('all', varargin); % By default, show only all plottable
    is_multiple_selection = ~varargin_dashed_str_exists('singlesection', varargin); % By default, multiple selection
    show_indices = varargin_dashed_str_exists('indices', varargin); % By default, do not show indices
    show_sorted = ~varargin_dashed_str_exists('nosort', varargin); % By default, show sorted
    show_manager = ~varargin_dashed_str_exists('nomanager', varargin); % By default, show manager
    show_preview = ~varargin_dashed_str_exists('nopreview', varargin); % By default, show preview
    close_preview = varargin_dashed_str_exists('closepreview', varargin); % By default, keep preview figures opened
    
    % Check if Title was specified
    datas = varargin_dashed_str_datas('Title', varargin, -1);
    Title = '';
    if numel(datas) > 0, Title = datas{1}; end
    
    % Check if Type was specified
    datas = varargin_dashed_str_datas('Type', varargin, -1);
    Type = {'TDBitmap', 'TDGraph', 'TDImage', 'TDText'}; % Default
    if numel(datas) > 0, Type = datas{1}; end
    if ~iscell(Type), Type = {Type}; end
    
    % Check if SubType was specified
    datas = varargin_dashed_str_datas('SubType', varargin, -1);
    SubType = repmat({''}, size(Type));
    if numel(datas) > 0, SubType = datas{1}; end
    if ~iscell(SubType), SubType = {SubType}; end
    
    % Check if Data was specified
    datas = varargin_dashed_str_datas('Data', varargin, -1);
    O_wid = obj.Data; % Get all the objects in the project % ASSUMING THAT PROJECT HAS SELF-CONSISTENT WID-DATA!
    if numel(datas) > 0, O_wid = datas{1}; end
    if isempty(O_wid), return; end % Exit if no project data
    
    % END OF VARARGIN PARSING
    
    %http://undocumentedmatlab.com/blog/matlab-java-memory-leaks-performance
    %http://undocumentedmatlab.com/blog/setting-status-bar-components
    %http://undocumentedmatlab.com/blog/matlab-callbacks-for-java-events
    
    % Keep only the plottable types
    if ~show_all,
        bw = false(size(O_wid));
        for ii = 1:numel(Type),
            type_ii = Type{ii};
            bw1 = strncmp({O_wid.Type}, type_ii, numel(type_ii));
            subtype_ii = SubType{ii};
            bw2 = strncmp({O_wid.SubType}, subtype_ii, numel(subtype_ii));
            bw(bw1 & bw2) = true; % Keep only specified types and subtypes
        end
        O_wid = O_wid(bw);
        if isempty(O_wid), return; end % Exit if no project data
    end
    
    % Sort by ID
    if show_sorted,
        [~, idx_sorted] = sort([O_wid.Id]);
        O_wid = O_wid(idx_sorted);
    end
    
    % Do not show manager if specified so, and exit
    if ~show_manager, return; end
    
    % Window name
    window_name = 'Project Manager';
    if ~isempty(Title), window_name = sprintf('%s: %s', window_name, Title); end
    
    % Important shared variables to handle asynchronous events properly
    needClosing = false; % Status of closing
    isQueue = false; % Status of queue
    isBusy = false; % Status of loading
    
    % Create figure window
    fig_offset = floor(rem(now, 1)*86400000); % Produce unique figure index offset
    fig = figure(fig_offset);
    set(fig, 'CloseRequestFcn', @CloseRequestFcn);
    set(fig, 'DeleteFcn', 'delete(setdiff(findobj(gcbo), gcbo)); delete(gcbo);'); % Deletes all (including Java) and the figure % http://undocumentedmatlab.com/blog/couple-of-bugs-and-workarounds
    set(fig, 'Name', window_name, 'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none', 'Units', 'normalized', 'Position', [0.075 0.1 0.225 0.8]);
    
    % Get figure window position in pixels
    Units = get(fig, 'Units'); % Store Units
    set(fig, 'Units', 'pixels'); % Pixels
    Position = get(fig, 'Position'); % Get Position
    set(fig, 'Units', Units); % Restore Units
    
    % Bottom table height
    height_table = 60;
    
    % First create simple list
    list = O_wid.get_HtmlName(false); % Get ProjectManager-optimized names
    % Then modify the created list by adding filenames whenever needed (6.11.2017)
    files = cell(size(list));
    prev = ''; % Keep track of the previous filename
    for ii = 1:numel(O_wid), % Add only the first filename and omit immediately subsequent duplicates
        this = O_wid(ii).Tag.Data.File;
        if isempty(prev) || ~strcmp(this, prev);
            files{ii} = this;
            prev = this;
        end
    end
    for ii = 1:numel(O_wid),
        if show_indices, list{ii} = strrep(list{ii}, '&nbsp;', sprintf('&nbsp;<b>%d</b>. ', ii)); end
        if isempty(files{ii}), continue; end
        [pathstr, name, ext] = fileparts(files{ii});
        list{ii} = strrep(list{ii}, '<html>', ['<html>&#x25BE; <b>' name ext '</b> (v' sprintf('%d', O_wid(ii).Version) ') @ ' pathstr ':<br>']);
    end
    
    % Create list using Java
    [hcomponent, hcontainer] = javacomponent(javax.swing.JScrollPane(javax.swing.JList(list)), [], fig); % Create JScrollPane and JList: http://undocumentedmatlab.com/blog/javacomponent
    set(hcontainer, 'Units', 'pixels', 'Position', [0 height_table Position(3) Position(4)-height_table]); % Resize to fill the figure
%     set(hcontainer, 'Units', 'normalized', 'Position', [0 0 1 1]); % Resize to fill the figure
    if is_multiple_selection, selection_mode = javax.swing.ListSelectionModel.MULTIPLE_INTERVAL_SELECTION;
    else, selection_mode = javax.swing.ListSelectionModel.SINGLE_SELECTION; end
    set(handle(hcomponent.getViewport().getView(), 'CallbackProperties'), ...
        'SelectionMode', selection_mode, ... % Whether single or multiple selection mode
        'KeyReleasedCallback', @ReleasedCallback, 'MouseReleasedCallback', @ReleasedCallback, 'MouseMovedCallback', @MouseMovedCallback); % Modify standard callbacks of JList: http://undocumentedmatlab.com/blog/uicontrol-callbacks

    % Create preview checkbox
%     c = uicontrol(fig, 'Style', 'checkbox', 'String', 'Preview', 'Value', 1, 'Units', 'normalized', 'Position', [0 0 1 0.03]);
    isPreview = show_preview;
    h_table = uitable(fig, ...
        'Data', {isPreview obj.ForceDataUnit obj.ForceSpaceUnit obj.ForceSpectralUnit obj.ForceTimeUnit}, ...
        'RowName', [], ...
        'ColumnName', {'Preview', 'DataUnit', 'SpaceUnit', 'SpectralUnit', 'TimeUnit'}, ...
        'ColumnFormat', {'logical', 'char', 'char', 'char', 'char'}, ...
        'ColumnEditable', [true true true true true], ...
        'Units', 'pixels', ...
        'Position', [0 0 Position(3) height_table], ...
        'CellEditCallback', @CallEditCallback);
    
    % Add resizing function
    if isprop(fig, 'SizeChangedFcn'), set(fig, 'SizeChangedFcn', @update);
    else, set(fig, 'ResizeFcn', @update); end % Added for backward compability
    
    % Create Java waitbar
%     [hcomponent2, hcontainer2] = javacomponent(javax.swing.JProgressBar(0, 1000), [], fig); % From 0.0% to 100.0%
%     set(hcontainer2, 'Units', 'normalized', 'Position', [0 0 1 0.03], 'Visible', 'off');
    
    indices = []; % Store old indices (to be updated by MouseReleasedCallback)
    if nargout > 0,
        waitfor(fig); % If output is expected, then wait until the manager is closed!
        O_wid = O_wid(indices(~isnan(indices))); % ~isnan removes NaN's due to deselecting indices
    end
    
    % To handle main window closing (and '-closepreview'-option)
    function CloseRequestFcn(varargin),
        if isBusy, % Test if there are other unfinished duties
            needClosing = true; % And expect a close-call elsewhere
        else,
            needClosing = false;
            % Close the opened preview figures if requested
            if close_preview,
                figs = (1:numel(indices))+fig_offset;
                close(figs(ishandle(figs)));
            end
            delete(fig);
        end
    end
    
    % For KeyReleasedCallback and MouseReleasedCallback
    function ReleasedCallback(h, varargin),
        if ~isBusy, % Proceed only if NOT busy
            isBusy = true;
            h_Waitbar = waitbar(0, 'Please wait...');
%             isPreview = get(c, 'Value'); % State of preview checkbox
            next_indices = h.getSelectedIndices()+1; % New indices
            if ~isempty(indices), % Compare with old indices
                bw_ne = bsxfun(@ne, next_indices(:), indices(:)'); % Construct not-equal matrix
                bw_new = all(bw_ne, 2); % Truly new indices
                bw_old = all(bw_ne, 1) & ~isnan(indices(:)'); % Truly old indices
            else bw_new = true(size(next_indices)); bw_old = []; end
            % Handle old figures
            figs_prev = (1:numel(indices))+fig_offset; % Previous figure numbers
            figs_prev = figs_prev(bw_old); % Figures for truly old indices
            close(figs_prev(ishandle(figs_prev))); % Close open figures for truly old indices
            indices(bw_old) = NaN; % Destroy truly old indices
            % Handle new figures
            N_new = sum(bw_new); % Number of truly new indices
            N_balance = N_new-sum(bw_old); % How many new elements must be created
            if N_balance > 0, 
                indices(end+1:end+N_balance) = NaN; % Append enough NaNs to the end
            end
            next_indices = next_indices(bw_new); % Keep only truly new indices
    %         if N_new > 0, set(hcontainer2, 'Visible', 'on'); end % Java waitbar
            for jj = 1:N_new,
    %             hcomponent2.setValue(jj / N_new * 1000); drawnow; % Java waitbar
                idx = find(isnan(indices), 1, 'first'); % Find next NaN index
                indices(idx) = next_indices(jj); % Store current truly new index
                if isPreview, 
                    invisible_figure(idx+fig_offset); % Create new invisible figure
                    plot(O_wid(next_indices(jj))); % Show data
                end
                waitbar(jj / N_new);
            end
    %         if N_new > 0, set(hcontainer2, 'Visible', 'off'); drawnow; hcomponent2.setValue(0); end % Java waitbar
            delete(findobj(allchild(0), 'flat', 'Tag', 'TMWWaitbar')); % Solves the closing issues with close(h_Waitbar);
            isBusy = false;
            if isQueue, % Release queue
                isQueue = false;
                ReleasedCallback(h, varargin),
            end
            
            % Handle main window closing if requested (if not already closed)
            if needClosing && ishandle(fig),
                close(fig);
            end
        else, isQueue = true; end
    end
    
    % Proper resizing of the uitable (topbar, bottombar)
    function update(varargin),
        % Store previous Units
        fig_Units = get(fig, 'Units');
        hcontainer_Units = get(hcontainer, 'Units');
        table_Units = get(h_table, 'Units');
        
        % Change Units to pixels
        set(fig, 'Units', 'pixels');
        set(hcontainer, 'Units', 'pixels');
        set(h_table, 'Units', 'pixels');
        
        % Calculate and set new Positions
        drawnow; % Update Figure first (added for backward compability)
        fig_Position = get(fig, 'Position');
        table_Position = get(h_table, 'Position'); % Get previous h_table Position
        hcontainer_Position = [0 table_Position(4) fig_Position(3) fig_Position(4)-table_Position(4)];
        table_Position = [0 0 fig_Position(3) table_Position(4)];
        set(hcontainer, 'Position', hcontainer_Position);
        set(h_table, 'Position', table_Position);
        
        % Restore previous Units
        set(hcontainer, 'Units', hcontainer_Units);
        set(h_table, 'Units', table_Units);
        set(fig, 'Units', fig_Units);
    end

    % Handle uitable changes
    function CallEditCallback(hObject, callbackData),
        Value = callbackData.EditData; % Either logical or char
        UnitInd = callbackData.Indices(2)-1;
        if UnitInd == 0, isPreview = Value; % Preview
        else, % DataUnit, SpaceUnit, SpectralUnit or TimeUnit
            switch(UnitInd),
                case 1, obj.ForceDataUnit = Value; Value = obj.ForceDataUnit;
                case 2, obj.ForceSpaceUnit = Value; Value = obj.ForceSpaceUnit;
                case 3, obj.ForceSpectralUnit = Value; Value = obj.ForceSpectralUnit;
                case 4, obj.ForceTimeUnit = Value; Value = obj.ForceTimeUnit;
            end
            % hObject.Data{UnitInd+1} = Value; % replaced for backward compability
            Data = get(hObject, 'Data');
            Data{UnitInd+1} = Value;
            set(hObject, 'Data', Data);
        end
    end

    % MouseMovedCallback, which sets JList-item name as tooltip string
    % https://undocumentedmatlab.com/blog/setting-listbox-mouse-actions/
    function MouseMovedCallback(jListbox, jEventData),
        % Get the current mouse position
        mousePosition = java.awt.Point(jEventData.getX, jEventData.getY);
        % Get the currently-hovered JList-item
        hoverIndex = jListbox.locationToIndex(mousePosition);
        % Get its string value
        str = jListbox.getModel().getElementAt(hoverIndex);
        % Set it as new tooltip string in order to show the item full name
        jListbox.setToolTipText(str);
    end
end
