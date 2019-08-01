% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [new_obj, image_mask] = image_mask_editor(obj, image_mask)
    % TOOLBOX REQUIREMENTS: Image Processing Toolbox
    % Updated 5.3.2019 by Joonas T. Holmi
    
    new_obj = wid.Empty;
    
    % MASK GENERATION IF NO MASK INPUT / MASK EDITING IF NO MAIN INPUT
    if ~isempty(obj) || nargin > 1,
        Fig = figure('Name', 'Mask Editor', 'NumberTitle', 'off');
        if ~isempty(obj),
            if strcmp('TDBitmap', obj.Type) || (strcmp('TDGraph', obj.Type) && strcmp('Image', obj.SubType)) || strcmp('TDImage', obj.Type),
                obj.plot('-nopreview', '-nocursor');
                set(Fig, 'Name', sprintf('Mask Editor: %s', get(Fig, 'Name')));
                if nargin == 1 || any(size(image_mask) ~= [obj.Info.XSize obj.Info.YSize]),
                    image_mask = true(obj.Info.XSize, obj.Info.YSize);
                end
            else,
                warning('Invalid Type! Image mask editor is only for TDBitmap, Image<TDGraph and TDImage. ABORTING...');
                return; % Abort if illegal type!
            end
        else,
            imagesc(true(size(image_mask.')), [0 1]);
            daspect([1 1 1]);
        end
        str_Popup = {'Freehand', 'Polygon', 'Ellipse', 'Rectangle', 'Line', 'Point'};
        Ax = get(Fig, 'CurrentAxes');
        ui_sidebar_for_button(Fig, [], 'Invert mask', @invert, [1 1 1 -1]);
        ui_sidebar_for_popup(Fig, 'Masking tool:', str_Popup, @update, 1, false, [1 -1 1 1]);
        waitfor(Fig);
    end
    
    % Create new object if permitted
    if obj.Project.popAutoCreateObj, % Get the latest value (may be temporary or permanent or default)
        new_obj = wid.new_Image(obj.Tag.Root); % This does not add newly created object to Project yet!
        new_obj.Name = sprintf('Mask<%s', obj.Name); % Generate new name
        new_obj.Data = image_mask;
        
        % Give it the same transformations and interpretations
        new_obj.Tag.Data.regexp('^PositionTransformationID<TDImage<', true).Data = int32(max([obj.Info.XTransformation.Id 0])); % Must be int32!
        if wip.get_Root_Version(obj) == 7,
            new_obj.Tag.Data.regexp('^SecondaryTransformationID<TDImage<', true).Data = int32(max([obj.Info.XSecondaryTransformation.Id 0])); %v7 % Must be int32!
        end
    end
    
    % Add new object to current Project, modifying its Project-property.
    if ~isempty(obj.Project) && ~isempty(new_obj),
        obj.Project.Data = [obj.Project.Data; new_obj];
    end
    
    function [isShown] = show_mask(),
        isShown = false;
        if ~ishandle(Ax), return; end % Stop if no Axes found
        Im = findobj(Ax, 'Type', 'image');
        if isempty(Im), return; end % Stop if no image found
        AlphaFalse = 0; % Alpha of false-values
        set(Im, 'AlphaData', (1-AlphaFalse).*image_mask.'+AlphaFalse); % 0 = transparent, 1 = opaque
        isShown = true;
    end
    
    function [] = invert(varargin),
        image_mask = ~image_mask;
        show_mask();
    end
    
    function [] = update(currentValue, varargin),
        persistent isBusy; % If busy in some other callback
        persistent Value; % Latest value
        persistent robot; % Keyboard robot
        Value = currentValue; % Update value to the latest value
        if isempty(isBusy), isBusy = false; end % Initialize
        if isBusy, % Interrupt other callback and exit
            if isempty(robot), robot = java.awt.Robot; end % Initialize (CAN THIS LEAK MEMORY?)
            robot.keyPress(java.awt.event.KeyEvent.VK_ESCAPE);
            robot.keyRelease(java.awt.event.KeyEvent.VK_ESCAPE);
            return;
        end
        if ~show_mask(), return; end % Abort if mask cannot be shown
        isBusy = true; % Set callback busy
        switch(Value), % New masking tool (these can be VK_ESCAPE-interrupted)
            case 1, h = imfreehand(Ax);
            case 2, h = impoly(Ax);
            case 3, h = imellipse(Ax);
            case 4, h = imrect(Ax);
            case 5, h = imline(Ax);
            case 6, h = impoint(Ax);
        end
        if ishandle(Fig) && ~isempty(h), % Continue only if masking was successful
            image_mask = image_mask & ~createMask(h)'; %Mask binary map
            delete(h);
        end
        isBusy = false; % Set callback free
        update(Value); % Value may have changed by other callback!
    end
end
