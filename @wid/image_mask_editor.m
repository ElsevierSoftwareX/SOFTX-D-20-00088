% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [new_obj, image_mask] = image_mask_editor(obj, image_mask),
    if numel(obj) > 1, error('Provide either an empty or a single wid Data object!'); end
    
    % Pop states (even if not used to avoid push-pop bugs)
    Project = [obj.Project];
    if isempty(Project), AutoCreateObj = false;
    else, AutoCreateObj = Project.popAutoCreateObj; end % Get the latest value (may be temporary or permanent or default)
    
    new_obj = wid.empty;
    
    % MASK GENERATION IF NO MASK INPUT / MASK EDITING IF NO MAIN INPUT
    if ~isempty(obj) || nargin > 1,
        Fig = figure('Name', 'Mask Editor', 'NumberTitle', 'off');
        if ~isempty(obj),
            obj_Info = obj.Info; % Load only once
            if strcmp('TDBitmap', obj.Type) || (strcmp('TDGraph', obj.Type) && strcmp('Image', obj.SubType)) || strcmp('TDImage', obj.Type),
                obj.plot('-nopreview', '-nocursor');
                set(Fig, 'Name', sprintf('Mask Editor: %s', get(Fig, 'Name')));
                if nargin == 1 || any(size(image_mask) ~= [obj_Info.XSize obj_Info.YSize]),
                    image_mask = true(obj_Info.XSize, obj_Info.YSize);
                end
            else,
                warning('Invalid Type! Image mask editor is only for TDBitmap, Image<TDGraph and TDImage. ABORTING...');
                return; % Abort if illegal type!
            end
        else,
            imagesc(true(size(image_mask.')), [0 1]);
            daspect([1 1 1]);
        end
        
        Ax = get(Fig, 'CurrentAxes');
        masking_value = false;
        masking_mode = 0;
        show_mask();
        ui_sidebar_for_popup(Fig, 'Masking value:', {'False', 'True'}, @update_value, 1, false, [1 -1 1 1]);
        ui_sidebar_for_button(Fig, [], 'Clear mask', @clear, [1 1 1 -1]);
        ui_sidebar_for_button(Fig, [], 'Invert mask', @invert, [1 1 1 -1]);
        str_Popup = {'Freehand', 'Contour', 'Fill'};
        set(Fig, 'WindowButtonDownFcn', @WindowButtonDownFcn, 'WindowButtonUpFcn', @WindowButtonUpFcn); % Enable mouse tracking when pressed down!
        ui_sidebar_for_popup(Fig, 'Masking tool:', str_Popup, @update, 1, false, [1 -1 1 1]);
        waitfor(Fig);
    end
    
    % Create new object if permitted
    if AutoCreateObj,
        new_obj = wid.new_Image(obj.Tag.Root); % This does not add newly created object to Project yet!
        new_obj.Name = sprintf('Mask<%s', obj.Name); % Generate new name
        new_obj.Data = image_mask;
        
        % Give it the same transformations and interpretations
        new_obj.Tag.Data.regexp('^PositionTransformationID<TDImage<', true).Data = int32(max([obj_Info.XTransformation.Id 0])); % Must be int32!
        if wip.get_Root_Version(obj) == 7,
            new_obj.Tag.Data.regexp('^SecondaryTransformationID<TDImage<', true).Data = int32(max([obj_Info.SecondaryXTransformation.Id 0])); %v7 % Must be int32!
        end
    end
    
    % Add new object to current Project, modifying its Project-property.
    if ~isempty(Project) && ~isempty(new_obj),
        Project.Data = [Project.Data; new_obj];
    end
    
    function isShown = show_mask(),
        isShown = false;
        if ~ishandle(Ax), return; end % Stop if no Axes found
        Im = findobj(Ax, 'Type', 'image');
        if isempty(Im), return; end % Stop if no image found
        AlphaFalse = 0; % Alpha of false-values
        set(Im, 'AlphaData', (1-AlphaFalse).*image_mask.'+AlphaFalse); % 0 = transparent, 1 = opaque
        isShown = true;
    end
    
    function invert(varargin),
        image_mask = ~image_mask;
        show_mask();
    end
    
    function clear(varargin),
        image_mask(:) = ~masking_value;
        show_mask();
    end
    
    function update(currentValue, varargin),
        masking_mode = currentValue;
    end
    
    function update_value(currentValue, varargin),
        masking_value = currentValue == 2;
    end
    
    function update_without_Image_Processing_Toolbox(isMouseUp),
        persistent old_CP;
        if ishandle(Fig) && ~isempty(Ax),
            CP = get(Ax, 'CurrentPoint');
            CP = CP(1,:);
            
            if masking_mode == 1, % Freehand-mode
                if isempty(old_CP),
                    drawLine(CP(1), CP(2), CP(1), CP(2));
                else,
                    drawLine(old_CP(end,1), old_CP(end,2), CP(1), CP(2));
                    if isMouseUp,
                        drawLine(CP(1), CP(2), old_CP(1,1), old_CP(1,2));
                        % Then mark insides (even if self-intersecting!)
                        L = label(image_mask);
                        stats = myregionprops(L);
                        PILS = cellfun(@(pil) pil(1), {stats.PixelIdxList});
                        [XS, YS] = ind2sub(size(image_mask), PILS);
                        in = myinpolygon(XS, YS, old_CP(:,1), old_CP(:,2));
                        for ii = 1:numel(in),
                            if ~in(ii), L(L == ii) = 0; end
                        end
                        create_mask = L > 0;
                        if masking_value, image_mask = image_mask | create_mask; %Mask binary map
                        else, image_mask = ~(~image_mask | create_mask); end %Mask binary map
                    end
                end
                % Whether or not to store CP
                if isMouseUp, old_CP = [];
                else, old_CP(end+1,:) = CP; end
            elseif masking_mode == 2, % Contour-mode
                if isempty(old_CP),
                    drawLine(CP(1), CP(2), CP(1), CP(2));
                else,
                    drawLine(old_CP(1), old_CP(2), CP(1), CP(2));
                end
                % Whether or not to store CP
                if isMouseUp, old_CP = [];
                else, old_CP = CP; end
            elseif masking_mode == 3 && image_mask(round(CP(1)),round(CP(2))) ~= masking_value, % Fill-mode
                L = label(image_mask);
                l = L(round(CP(1)),round(CP(2)));
                stats = myregionprops(L);
                image_mask(stats(l).PixelIdxList) = masking_value;
            end
            
            show_mask();
        end
    end

    function drawLine(x0, y0, x1, y1),
        % Get step directions
        sh = sign(y1-y0);
        sv = sign(x1-x0);
        % Get limits
        XLim = get(Ax, 'XLim');
        YLim = get(Ax, 'YLim');
        % Draw only one point
        if x0 == x1 && y0 == y1,
            % Draw point only if not out-of-bounds!
            if x0 >= XLim(1) && x0 <= XLim(2) && y0 >= YLim(1) && y0 <= YLim(2),
                image_mask(round(x0), round(y0)) = masking_value;
            end
        else,
            % Get horizontal line intersections
            if y0 == y1,
                yh = [];
                xh = [];
            else,
                yh = round(y0)+0.5.*sh:sh:round(y1)-0.5.*sh;
                xh = interp1([y0 y1], [x0 x1], yh, 'linear');
            end
            % Get vertical line intersections
            if x0 == x1,
                xv = [];
                yv = [];
            else,
                xv = round(x0)+0.5.*sv:sv:round(x1)-0.5.*sv;
                yv = interp1([x0 x1], [y0 y1], xv, 'linear');
            end
            % Create line points
            x = [ceil(xv) ceil(xv)-1 round(xh) round(xh)];
            y = [round(yv) round(yv) ceil(yh) ceil(yh)-1];
            % Draw line points
            for ii = 1:numel(x),
                % Draw point only if not out-of-bounds!
                if x(ii) >= XLim(1) && x(ii) <= XLim(2) && y(ii) >= YLim(1) && y(ii) <= YLim(2),
                    image_mask(x(ii), y(ii)) = masking_value;
                end
            end
        end
    end
    
    % Mouse tracking callbacks
    function WindowButtonUpFcn(varargin),
        set(Fig, 'WindowButtonMotionFcn', ''); % Disable mouse tracking
        update_without_Image_Processing_Toolbox(true);
    end
    function WindowButtonDownFcn(varargin),
        set(Fig, 'WindowButtonMotionFcn', @WindowButtonMotionFcn); % Enable mouse tracking
        update_without_Image_Processing_Toolbox(false);
    end
    function WindowButtonMotionFcn(varargin),
        update_without_Image_Processing_Toolbox(false);
    end
end
