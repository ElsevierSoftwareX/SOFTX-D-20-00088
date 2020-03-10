% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This shows positions of any TDBitmap, TDGraph and TDImage wid objects
% (given as varargin) within the region of any Image wid object.

% The plotter functions for Image, Line and Point wid objects can be
% customized by providing anonymous functions paired with '-markImageFun',
% '-markLineFun' and '-markPointFun'. The anonymous functions must be of
% the following form: h = fun(Ax, positions, color), where 'h' is an array
% of the created graphical object handles, 'Ax' is a figure axes handle,
% 'positions' is an N-by-3 XYZ-coordinate array and 'color' is a 1-by-3
% RGB-channel vector. Here N is 4, 2 and 1 for Image, Line and Point wid
% objects, respectively. For more details, see the default helper functions
% wid.plot_position_Image_helper.m, wid.plot_position_Line_helper.m and
% wid.plot_position_Point_helper.m.
function h_position = plot_position(obj, FigAxNeither, varargin),
    % Empty output by default
    h_position = [];
    
    % Test main object
    if ~strcmp(obj.SubType, 'Image'), return; end % Exit if not an Image
    
    % Check if markImageFun was specified
    datas = varargin_dashed_str_datas('markImageFun', varargin, -1);
    markImage = @wid.plot_position_Image_helper;
    if numel(datas) > 0, markImage = datas{1}; end
    
    % Check if markLineFun was specified
    datas = varargin_dashed_str_datas('markLineFun', varargin, -1);
    markLine = @wid.plot_position_Line_helper;
    if numel(datas) > 0, markLine = datas{1}; end
    
    % Check if markPointFun was specified
    datas = varargin_dashed_str_datas('markPointFun', varargin, -1);
    markPoint = @wid.plot_position_Point_helper;
    if numel(datas) > 0, markPoint = datas{1}; end
    
    % Parse FigAxNeither
    Fig = [];
    Ax = [];
    try, % Test if FigAxNeither is Figure or Axes
        type = get(FigAxNeither, 'type'); % Compatible with older versions
        if strcmp(type, 'figure'),
            Fig = FigAxNeither;
            Ax = findobj(Fig, 'Type', 'Axes'); % Find all Axes
        elseif strcmp(type, 'axes'),
            Ax = FigAxNeither;
            Fig = get(Ax, 'Parent');
        else, varargin = [{FigAxNeither} varargin]; end % Add to varargin if neither
    catch, varargin = [{FigAxNeither} varargin]; end % Add to varargin if neither
    % Get current figure if needed
    if isempty(Fig),
        Fig = gcf;
        Ax = findobj(Fig, 'Type', 'Axes'); % Find all Axes
    end
    % Create default axes if needed
    if isempty(Ax),
        Ax = axes('Parent', Fig);
        set(0, 'CurrentFigure', Fig);
        obj.plot;
    end
    
    % Parse the varargin and keep only TDBitmap, TDGraph and TDImage wid objects
    B_valid = cellfun(@(x) isa(x, 'wid'), varargin); % Test if wid
    varargin = varargin(B_valid); % Keep only wid
    varargin = cellfun(@(x) x(:), varargin, 'UniformOutput', false); % Force to column vectors
    O_wid = cat(1, varargin{:}); % Merge column vectors to a single column vector
    if isempty(O_wid), return; end % Exit if no valid inputs
    O_wid_Type = {O_wid.Type};
    B_valid = strcmp(O_wid_Type, 'TDBitmap') | strcmp(O_wid_Type, 'TDGraph') | strcmp(O_wid_Type, 'TDImage'); % Test if TDBitmap or TDGraph or TDImage
    O_wid = O_wid(B_valid);
    if isempty(O_wid), return; end % Exit if no valid inputs
    
    % Ensure that the subsequent plots are included into same axes
    hold on;
    
    % Get figure ColorOrder
    ColorOrder = get(Ax, 'ColorOrder');
    
    % Get its Space Transformation info
    [ModelOrigin, WorldOrigin, Scale, Rotation] = getTSpaceInfo(obj);
    
    % Loop through the other objects
    for ii = 1:numel(O_wid),
        [ModelOrigin_ii, WorldOrigin_ii, Scale_ii, Rotation_ii, XSize_ii, YSize_ii] = getTSpaceInfo(O_wid(ii));
        
        Color_ii = ColorOrder(mod(ii-1,size(ColorOrder,1))+1,:);
        switch(O_wid(ii).SubType),
            case 'Image',
                % Calculate four vertices in three coordinate systems:
                % (1) its own, (2) world coordinate system, and
                % (3) main object's.
                px_ii = [0.5 XSize_ii+0.5 XSize_ii+0.5 0.5; 0.5 0.5 YSize_ii+0.5 YSize_ii+0.5; 1 1 1 1]; % Half pixels in X- and Y-directions, because the middle of pixels are at integers.
                um_ii = bsxfun(@plus, Rotation_ii*Scale_ii*bsxfun(@minus, px_ii-1, ModelOrigin_ii), WorldOrigin_ii);
                px = bsxfun(@plus, (Rotation*Scale)\bsxfun(@minus, um_ii, WorldOrigin), ModelOrigin+1);
                
                % Mark ii'th Image object on top of the main object figure
                h_image = markImage(Ax, px.', Color_ii);
                h_position = [h_position; h_image(:)]; % Append gobjects
            case 'Line',
                % Calculate two vertices in three coordinate systems:
                % (1) its own, (2) world coordinate system, and
                % (3) main object's.
                px_ii = [0.5 XSize_ii+0.5; 1 1; 1 1]; % Half pixels in X-direction, because the middle of pixels are at integers.
                um_ii = bsxfun(@plus, Rotation_ii*Scale_ii*bsxfun(@minus, px_ii-1, ModelOrigin_ii), WorldOrigin_ii);
                px = bsxfun(@plus, (Rotation*Scale)\bsxfun(@minus, um_ii, WorldOrigin), ModelOrigin+1);
                
                % Mark ii'th Line object on top of the main object figure
                h_line = markLine(Ax, px.', Color_ii);
                h_position = [h_position; h_line(:)]; % Append gobjects
            case 'Point',
                % Calculate one vertex in three coordinate systems:
                % (1) its own, (2) world coordinate system, and
                % (3) main object's.
                px_ii = [1; 1; 1]; % The middle of pixel is at integer.
                um_ii = bsxfun(@plus, Rotation_ii*Scale_ii*bsxfun(@minus, px_ii-1, ModelOrigin_ii), WorldOrigin_ii);
                px = bsxfun(@plus, (Rotation*Scale)\bsxfun(@minus, um_ii, WorldOrigin), ModelOrigin+1);
                
                % Mark ii'th Point object on top of the main object figure
                h_point = markPoint(Ax, px.', Color_ii);
                h_position = [h_position; h_point(:)]; % Append gobjects
        end
    end
    
    function [ModelOrigin, WorldOrigin, Scale, Rotation, XSize, YSize] = getTSpaceInfo(obj),
        % Default values if without TDSpaceTransformation
        [ModelOrigin, WorldOrigin] = deal(zeros(3, 1));
        [Scale, Rotation] = deal(eye(3, 3));
        [XSize, YSize] = deal(0);
        
        if isempty(obj), return; end
        
        % Get its Info only once
        obj_Info = obj.Info;
        
        XSize = obj_Info.XSize;
        YSize = obj_Info.YSize;
        
        T = obj_Info.SecondaryXTransformation;
        if isempty(T) || ~strcmp(T.Type, 'TDSpaceTransformation'), T = obj_Info.XTransformation; end
        if isempty(T) || ~strcmp(T.Type, 'TDSpaceTransformation'), return; end
        
        T_Data = T.Data;
        TSpace = T_Data.TDSpaceTransformation;
        ModelOrigin = TSpace.ViewPort3D.ModelOrigin(:);
        WorldOrigin = TSpace.ViewPort3D.WorldOrigin(:);
        Scale = reshape(TSpace.ViewPort3D.Scale, [3 3]);
        Rotation = reshape(TSpace.ViewPort3D.Rotation, [3 3]);
    end
end
