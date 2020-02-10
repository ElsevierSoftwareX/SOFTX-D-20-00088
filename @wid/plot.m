% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function h = plot(obj, varargin),
    % Supports following extra options, which can be followed by any number
    % of extra option inputs:
    % -positions: Shows positions of subsequent Image, Line and Point wid objects.
    % Use --markImageFun, --markLineFun and --markPointFun to customize it.
    % (For more details, see the documentation of @wid/show_Position.m.)
    % -compare: Shows comparison of obj and all subsequent wid objects. Implemented
    % for Image<TDGraph, Line<TDGraph, Point<TDGraph, Array<TDGraph,
    % Histogram<TDGraph, Time<TDGraph and Mask<TDGraph.
    % -mask: Uses subsequent inclusion masks to exclude areas in obj as NaNs.
    % -nocursor: Disables cursor.
    % -nopreview: Disables preview.
    % -nosidebar: Disables sidebar.
    
    % MATLAB R2014b and newer have different HOLD ON behaviour.
    % http://se.mathworks.com/help/matlab/graphics_transition/why-are-plot-lines-different-colors.html
    % This is taken into account in this code.
    
    Fig = gcf; % By default, update gcf
    Fig_sub = []; % Handle to preview-figure
    h_sub = []; % Handle to line-objects
    isBusy = false; % Was implemented to avoid replotting while busy
    
    % Avoid clipboard asyncronous bug
    isCopyingQueue = false; % Status of copying queue
    isCopyingBusy = false; % Status of copying
    srcCopyingQueue = [];
    evtCopyingQueue = [];
    
    showSidebar = ~varargin_dashed_str_exists('nosidebar', varargin); % By default, show sidebar
    showPreview = ~varargin_dashed_str_exists('nopreview', varargin); % By default, show preview
    showCursor = ~varargin_dashed_str_exists('nocursor', varargin); % By default, show cursor
    obj_showPosition = varargin_dashed_str_datas('position', varargin);
    obj_compare = varargin_dashed_str_datas('compare', varargin);
    fun_auto = @(x) true; % By default, enable autoscaling
    
    Name = obj.Name;
    Data = obj.Data;
    S_Data = size(Data);
    N_Data = numel(Data);
    Info = obj.Info; % Get this only once
    if ~isempty(obj.Id), Name = sprintf('%s (ID: %d)', Name, obj.Id); end
    
    % Preload all available space transformations
    XTransformation = [];
    if isfield(Info, 'XTransformation') && ~isempty(Info.XTransformation),
        XTransformation = Info.XTransformation; % Significant speed-up
    end
    
    set(0, 'CurrentFigure', Fig);
    set(Fig, 'Visible', 'off'); % Set visible
    Units = get(Fig, 'Units'); % Store Units
    set(Fig, 'Units', 'centimeters'); % Units to centimeters
    Position = get(Fig, 'Position'); % Position in centimeters
    Position(3:4) = [16 10]; % New window width and height in centimeters
    set(Fig, 'Name', Name, 'NumberTitle', 'off', ...
        'Position', Position, 'Color', 'white');
    set(Fig, 'Units', Units); % Restore Units
    
    % Mask Data
    MaskDatas = varargin_dashed_str_datas('mask', varargin);
    for ii = 1:numel(MaskDatas), [~, Data] = data_mask(Data, MaskDatas{ii}.Data); end
    
    if ~isempty(Data),
        switch(obj.Type),
            case 'TDBitmap',
                plot_Image(Data, 'RGB', Info.XUnit, Info.XLength, Info.YLength);
                if showSidebar && showCursor, ui_sidebar_for_cursor([], [], [], @transform_CP); end
            case 'TDGraph',
                % VERIFIED 25.7.2016 TO BE COMPLETE LIST!
                switch(obj.SubType),
                    case 'Image', % Image
                        if showSidebar,
                            updateGraphImage([-inf inf]);
                            fun_refresh = ui_sidebar_for_clim(Fig);
                            ui_sidebar_for_colormap_mpl(Fig);
                            ui_sidebar_for_sum_filter(Fig, @updateGraphImage, fun_refresh);
                            if showCursor,
                                if ~showPreview, ui_sidebar_for_cursor(Fig, [], [], @transform_CP);
                                else, ui_sidebar_for_cursor(Fig, @subPreview, [], @transform_CP); end
                            end
                        else,
                            if numel(varargin) > 0, updateGraphImage(varargin{1});
                            else, updateGraphImage([-inf inf]); end
                        end
                    case 'Line', % Line
                        plotSpectrum(1, 1);
                        if showSidebar,
                            if showCursor, ui_sidebar_for_cursor(Fig); end
                            ui_sidebar_for_index_slider(Fig, Info.XSize, @(Ind) plotSpectrum(Ind, 1));
                            fun_auto = ui_sidebar_for_checkbox(Fig, 'Autoscale', 1);
                        end
                    case 'Point', % Point
                        plotSpectrum(1, 1);
                        if showSidebar && showCursor, ui_sidebar_for_cursor(Fig); end
                    case 'Array', % Array
                        plotSpectrum(1, 1);
                        if showSidebar && showCursor, ui_sidebar_for_cursor(Fig); end
                    case 'Histogram', % Histogram
                        plotSpectrum(1, 1, @bar);
                        if showSidebar && showCursor, ui_sidebar_for_cursor(Fig); end
                    case 'Time', % Time
                        plotSpectrum(1, 1);
                        if showSidebar,
                            if showCursor, ui_sidebar_for_cursor(Fig); end
                            ui_sidebar_for_index_slider(Fig, Info.XSize, @(Ind) plotSpectrum(Ind, 1));
                            fun_auto = ui_sidebar_for_checkbox(Fig, 'Autoscale', 1);
                        end
                    case 'Mask', % Mask
                        plotSpectrum(1, 1);
                        if showSidebar && showCursor, ui_sidebar_for_cursor(Fig); end        % CUSTOM TYPE
                    case 'Volume', % Volume (CUSTOM)
                        if showSidebar,
                            updateGraphVolume([-inf inf]);
                            ui_sidebar_for_colormap_mpl(Fig);
                            ui_sidebar_for_sum_filter(Fig, @updateGraphVolume);
                        else,
                            if numel(varargin) > 0, updateGraphVolume(varargin{1});
                            else, updateGraphVolume([-inf inf]); end
                        end
                end
            case 'TDImage', % Image
                plot_Image(Data, Info.DataUnit, Info.XUnit, Info.XLength, Info.YLength);
                if showSidebar,
                    ui_sidebar_for_clim(Fig);
                    ui_sidebar_for_colormap_mpl(Fig);
                    if showCursor, ui_sidebar_for_cursor(Fig, [], [], @transform_CP); end
                end
            otherwise, % Text OR (un)formatted DataTree
                if ~strcmp(obj.Type, 'TDText'), % If NOT TDText
                    Data = DataTree2TextCell(Data); % Convert (un)formatted DataTree to Text-cell
                    S_Data = size(Data);
                    N_Data = numel(Data);
                end
                % Create uitable
                set(Fig, 'MenuBar', 'none', 'ToolBar', 'none');
                h = uitable(Fig, 'Data', Data, 'RowName', [], 'Units', 'normalized', 'Position', [0 0 1 1], ...
                    'CellSelectionCallback', @uitable_selection_to_clipboard, ...
                    'TooltipString', '<html><b>Select to copy:</b><br>Any selection is automatically copied to<br>clipboard in fixed-width representation!</html>');

                % Automatically determine the minimum column widths needed in uitable.
                % Create a temporary text object with the properties that of the table.
                h_text = text(0, 0, '', 'HandleVisibility', 'off', 'Interpreter', 'none', ...
                    'FontName', get(h, 'FontName'), 'FontSize', get(h, 'FontSize'), ...
                    'FontWeight', get(h, 'FontWeight'), 'FontAngle', get(h, 'FontAngle'));
                CW = zeros(S_Data);
                for ii = 1:N_Data, % Loop through all texts
                    set(h_text, 'String', Data{ii}, 'Units', 'pixels'); % Get in pixels
                    extent = get(h_text, 'Extent'); % Get the text extent in pixels
                    CW(ii) = extent(3); % Get the text width in pixels
                end
                delete(h_text); % Delete the temporary text object
                set(h, 'ColumnWidth', num2cell(max(CW, [], 1)+2)); % Set new column widths
                
                if showSidebar, % Show sidebar if requested
                    h_mainbar = ui_sidebar(Fig);
                    set(h_mainbar, 'Visible', 'off'); % Hide mainbar or it will hide uitable
                end
        end
    end
    
    % Show positions of the given objects
    h_positions = obj.show_Position(Fig, obj_showPosition{:});
    
    % Get handles of Axes children
    Ax = get(Fig, 'CurrentAxes');
    h = Ax.Children;
    h = [h; h_positions];
    
    % Set visible
    set(Fig, 'Visible', 'on');
    
    % Added feature on 19th March 2019
    function Text_cell = DataTree2TextCell(DT),
        fields = reshape(fieldnames(DT), [], 1);
        values = reshape(struct2cell(DT), [], 1);
        Text_cell = cell(0,2);
        row = 1;
        for ll = 1:numel(values),
            Text_cell{row,1} = fields{ll};
            value_ll = values{ll};
            if isstruct(value_ll), % CASE: A struct (== sub DataTree)
                value_ll = DataTree2TextCell(value_ll);
                for jj = 1:size(value_ll,1),
                    for kk = 1:size(value_ll,2),
                        Text_cell{row,1+kk} = value_ll{jj,kk};
                    end
                    row = row+1;
                end
            else, % CASE: A non-struct
                if isa(value_ll, 'wid'), % CASE: A wid object
                    % If wid, then get its Id
                    value_ll = max([0 value_ll.Id]);
                end
                if ischar(value_ll), % CASE: A char string
                    % Enclose char string within ''
                    value_ll = sprintf('''%s''', value_ll);
                else, % CASE: NOT a char string
                    if numel(value_ll) >= 1 && numel(value_ll) <= 9 && ndims(value_ll) <= 2, % CASE: a tiny 2-D matrix
                        % Show value
                        if numel(value_ll) == 1, % A single value
                            value_ll = sprintf('%.5g', value_ll); % Same precision as in Workspace
                        else, % A tiny 2-D matrix
                            str = '';
                            for jj = 1:size(value_ll,1),
                                for kk = 1:size(value_ll,2),
                                    if jj == 1 && kk == 1, % First row, first col
                                        str = sprintf('%s%.5g', str, value_ll(jj,kk)); % Same precision as in Workspace
                                    elseif kk == 1, % Subsequent row, first col
                                        str = sprintf('%s;%.5g', str, value_ll(jj,kk)); % Same precision as in Workspace
                                    else, % Subsequent row, subsequent col
                                        str = sprintf('%s,%.5g', str, value_ll(jj,kk)); % Same precision as in Workspace
                                    end
                                end
                            end
                            value_ll = sprintf('[%s]', str);
                        end
                    else, % CASE: a list of values (including empty)
                        % Only show list size and class
                        value_ll = sprintf('%s %s', regexprep(sprintf('%dx', size(value_ll)), 'x$', ''), class(value_ll));
                    end
                end
                Text_cell{row,2} = value_ll;
                row = row+1;
            end
        end
    end
    
    % Added feature on 8th November 2017
    function uitable_selection_to_clipboard(src, evt),
        if ~isCopyingBusy,
            isCopyingBusy = true;
            Data = get(src, 'Data'); % Backward compatible
            strs = repmat({''}, S_Data); % Create empty table
            inds = sub2ind(size(strs), evt.Indices(:,1), evt.Indices(:,2)); % Get indices
            strs(inds) = Data(inds); % Copy data based on the indices
            strs = strs(unique(evt.Indices(:,1)),:); % Keep only fully or partially selected rows
            strs = strs(:,unique(evt.Indices(:,2))); % Keep only fully or partially selected columns
%             strs = strs(any(~cellfun(@isempty, strs),2),:); % Keep only fully or partially non-empty rows
%             strs = strs(:,any(~cellfun(@isempty, strs),1)); % Keep only fully or partially non-empty columns
            if isempty(strs), return; end
            % Fixed-width representation of the data
            lens = cellfun(@numel, strs);
            lens_max = max(max(lens, [], 1), 1);
            str = repmat(' ', sum(lens_max)+size(strs, 2), size(strs, 1));
            str(end,:) = char(10); % \n
            for jj = 1:size(strs, 1),
                for kk = 1:size(strs, 2),
                    if isempty(strs{jj, kk}), continue; end
                    str((1:lens(jj,kk))+kk-1+sum(lens_max(1:(kk-1))),jj) = strs{jj, kk};
                end
            end
            str = str(:).';
            % \t as column-separator and \n as row-separator
%             str = '';
%             for jj = 1:size(strs, 1),
%                 for kk = 1:size(strs, 2),
%                     if kk == 1,
%                         if jj == 1, str = strs{jj, kk};
%                         else, str = sprintf('%s\n%s', str, strs{jj, kk}); end
%                     else, str = sprintf('%s\t%s', str, strs{jj, kk}); end
%                 end
%             end
            str = str(1:end-1); % Remove last \n
            clipboard('copy', str); % This line can cause error if called too often!
            pause(0.5); % And sleep for 500 ms. Strangely works better than java.lang.Thread.sleep(500);
            isCopyingBusy = false;
            if isCopyingQueue, % Release copying queue
                isCopyingQueue = false;
                uitable_selection_to_clipboard(srcCopyingQueue, evtCopyingQueue),
            end
        else,
            isCopyingQueue = true;
            srcCopyingQueue = src;
            evtCopyingQueue = evt;
        end
    end
    
    % TDBitmap & TDGraph & TDImage
    % Transform the point
    function CP_in_space = transform_CP(CP_in_pixels),
        if isempty(XTransformation), CP_in_space = [CP_in_pixels 1];
        else, [ ~, CP_in_space ] = obj.Project.transform_forced(XTransformation, permute(CP_in_pixels(:), [2 3 1])); end
    end
    
    % TDGraph
    % Update Graph Volume (CUSTOM TYPE)
    function updateGraphVolume(filter_range),
        set(0, 'CurrentFigure', Fig);
        Data_range = wid.crop_Graph_with_bg_helper(Data, Info.Graph, filter_range);
        data_plot_Volume(mynansum(Data_range, 3));
    end
    % Update Graph Image
    function updateGraphImage(filter_range),
        set(0, 'CurrentFigure', Fig);
        Data_range = wid.crop_Graph_with_bg_helper(Data, Info.Graph, filter_range);
        bw_isnan_3rd_dim = all(isnan(Data_range), 3); % Test if all NaN in the same location
        sum_3rd_dim = mynansum(Data_range, 3);
        sum_3rd_dim(bw_isnan_3rd_dim) = NaN; % Restore NaN if all NaN in the same location
        plot_Image(sum_3rd_dim, Info.DataUnit, Info.XUnit, Info.XLength, Info.YLength);
    end
    
    % Mouse tracking callback
    function subPreview(CP),
        if ~isBusy, % Proceed only if NOT busy
            isBusy = true; % Set busy flag true
            % Create figure on demand
            if isempty(Fig_sub) || ~ishandle(Fig_sub), 
                Fig_sub = invisible_figure(floor(rem(now, 1)*86400000)); % Produce unique (invisible) figure
                set(Fig_sub, 'Name', sprintf('PREVIEW of %s', obj.Name), 'NumberTitle', 'off');
                Units = get(Fig_sub, 'Units'); % Store Units
                set(Fig_sub, 'Units', 'centimeters'); % Units to centimeters
                Position = get(Fig_sub, 'Position'); % Position in centimeters
                Position(3:4) = [16 10]; % New window width and height in centimeters
                set(Fig_sub, 'Position', Position, 'Color', 'white');
                set(Fig_sub, 'Units', Units); % Restore Units
                if isprop(Fig_sub, 'DoubleBuffer'), set(Fig_sub, 'DoubleBuffer', 'on'); end % Added for backward compability
                axes('Parent', Fig_sub);
                OuterPosition = get(Fig, 'OuterPosition');
                OuterPosition(2) = OuterPosition(2) - OuterPosition(4);
                set(Fig_sub, 'OuterPosition', OuterPosition);
                if showSidebar,
                    ui_sidebar_for_cursor(Fig_sub);
                    fun_auto = ui_sidebar_for_checkbox(Fig_sub, 'Autoscale', 1);
                end
            end
            % Show spectrum data
%             CP = min(max(round(CP(:).'), 1), [Info.XSize Info.YSize]);
            CP = round(CP);
            plotSpectrum(CP(1), CP(2));
            figure(Fig); % Return focus back to the main figure
            isBusy = false; % Set busy flag false
        end
    end

    function plotSpectrum(indX, indY, fun_plot),
        % Handle first time
        if isempty(h_sub) || ~ishandle(h_sub(1)),
            if nargin < 3, fun_plot = []; end
            h_sub = plot_Spectrum(Fig_sub, Info.Graph, Info.GraphUnit, Data(indX,indY,:), Info.DataUnit, fun_plot, fun_auto());
            if numel(obj_compare) > 0,
                hold on;
                Colors = get(get(h_sub(1), 'Parent'), 'ColorOrder');
                set(h_sub(1), 'Color', Colors(1,:));
                strs = {obj.Name};
                counter = 0;
                for ii = 1:numel(obj_compare),
                    C_compare = obj_compare{ii};
                    for jj = 1:numel(C_compare),
                        if ~strcmp(C_compare(jj).Type, 'TDGraph'), continue; end
                        Data_compare = C_compare(jj).Data;
                        S_Data_latest = size(Data_compare);
                        S_Data_latest(end+1:numel(S_Data)) = 1;
                        if all(S_Data_latest(1:2) == S_Data(1:2) | S_Data_latest(1:2) == 1),
                            counter = counter+1;
                            Data_compare = bsxfun(@plus, Data_compare, zeros(S_Data(1:2)));
                            strs{1+counter} = C_compare(jj).Name;
                            Graph_compare = C_compare(jj).interpret_Graph('(nm)');
                            [~, Graph_compare] = obj.Project.interpret_forced(C_compare(jj).Info.GraphInterpretation, Info.GraphUnit, 0, Graph_compare);
                            h_sub(1+counter) = plot_Spectrum(Fig_sub, Graph_compare, Info.GraphUnit, Data_compare(indX,indY,:), Info.DataUnit, [], false);
                            set(h_sub(1+counter), 'Color', Colors(mod(counter, size(Colors, 1))+1,:)); % Circular indexing
                        end
                    end
                end
                hold off;
                legend('String', strs, 'Interpreter', 'none', 'Location', 'NorthWest', 'Box', 'off', 'LineWidth', 1, 'HitTest', 'off');
            end
            set(Fig_sub, 'Visible', 'on');
            set(0, 'CurrentFigure', Fig);
        % Otherwise update data
        else,
            set(h_sub(1), 'YData', Data(indX,indY,:));
            if fun_auto(), autoaxis(get(h_sub(1), 'Parent'), Info.Graph, Data(indX,indY,:)); end
            counter = 0;
            for ii = 1:numel(obj_compare),
                C_compare = obj_compare{ii};
                for jj = 1:numel(C_compare),
                    if ~strcmp(C_compare(jj).Type, 'TDGraph'), continue; end
                    Data_compare = C_compare(jj).Data;
                    S_Data_latest = size(Data_compare);
                    S_Data_latest(end+1:numel(S_Data)) = 1;
                    if all(S_Data_latest(1:2) == S_Data(1:2) | S_Data_latest(1:2) == 1),
                        counter = counter+1;
                        Data_compare = bsxfun(@plus, Data_compare, zeros(S_Data(1:2)));
                        set(h_sub(1+counter), 'YData', Data_compare(indX,indY,:));
                    end
                end
            end
        end
    end

    % Plotting functions
    function h = plot_Image(Data, DataUnit, SideUnit, SideWidth, SideHeight),
        % Ensures consistent image formatting
        Data = permute(Data, [2 1 3]); % Permute to show image correctly!
        if size(Data, 3) == 1, % Plot grayscale data
            if ~islogical(Data),
                % Get smart 4-sigmas range for best visibility using clever statistics
                [~, ~, ~, ~, ~, cmin, cmax] = clever_statistics_and_outliers(Data, [], 4);
                if cmin == cmax || isnan(cmin) || isnan(cmax), h = nanimagesc(Data);
                else, h = nanimagesc(Data, [cmin cmax]); end
            else, h = imagesc(Data); end % Plot logical data
%             colormap(colormap_mpl([], 'inferno')); % Use inferno by default
            colorbar('HitTest', 'off'); % HitTest 'off' added for backward compability of ui_sidebar_for_cursor
        elseif size(Data, 3) == 3, h = image(Data); end % Plot colored data

        daspect([1 1 1]);

        set(gca, 'FontName', 'Helvetica', 'FontSize', 9, ...
            'Box', 'on', 'TickDir', 'in', 'XMinorTick', 'off', ...
            'YMinorTick', 'off', 'YGrid', 'off', 'XGrid', 'off', ...
            'XColor', [0 0 0], 'YColor', [0 0 0], 'LineWidth', 1);

        if nargin > 1 && ~isempty(DataUnit), title(DataUnit, 'Interpreter', 'none'); end
        if nargin > 4, add_ticks_to_image( size(Data, 2), size(Data, 1), SideWidth, SideHeight, SideUnit ); end
    end

    function h = plot_Spectrum(Fig, X, XUnit, Y, YUnit, fun, isAuto),
        % Ensures consistent plot formatting
        if isempty(Fig), Fig = gcf; end
        Ax = get(Fig, 'CurrentAxes');
        if isempty(Ax), Ax = axes('Parent', Fig); end

        if nargin < 6 || isempty(fun), fun = @plot; end
        if nargin < 7, isAuto = true; end

        if isAuto,
            h = fun(Ax, X(:), Y(:));
            autoaxis(Ax, X, Y);
        else, % Preserve scaling
            XLim = get(Ax, 'XLim');
            YLim = get(Ax, 'YLim');
            h = fun(Ax, X(:), Y(:));
            set(Ax, ...
                'XLimMode', 'manual', 'XLim', XLim, ...
                'YLimMode', 'manual', 'YLim', YLim);
        end

        set(Ax, 'FontName', 'Helvetica', 'FontSize', 9, ...
            'Box', 'on', 'TickDir', 'in', 'XMinorTick', 'on', ...
            'YMinorTick', 'on', 'YGrid', 'off', 'XGrid', 'off', ...
            'XColor', [0 0 0], 'YColor', [0 0 0], 'LineWidth', 1);

        if isempty(XUnit), XUnit = wip.ArbitraryUnit; end
        xlabel(Ax, XUnit);

        if isempty(YUnit), YUnit = wip.ArbitraryUnit; end
        ylabel(Ax, YUnit);
    end
end
