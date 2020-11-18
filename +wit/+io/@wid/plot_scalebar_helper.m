% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This shows scalebar on any specified axes handle and requires image_size,
% image_size_in_SU and image_SU, where SU stands for Standard Units. This
% helper function is utilized by wid-class plot_scalebar.m. This accepts
% the following case-insensitive customizations:
% '-Color' = [1 1 1]: Overrides white color with the specified color.
% '-Anchor' = [0 1]: Overrides bottom-left corner anchor. Top-left corner
% is [0 0]. Top-right corner is [1 0]. Bottom-right corner is [1 1].
% '-PositionRatio' = [0.05 1-0.05]: Overrides 5% scalebar margins (from
% the anchor). Note: The top-left corner is located at [0 0].
% '-Position': Same as above but specified in dataset point coordinates.
% '-TextSpacingRatio' = 0.025: Overrides 2.5% text spacing margin.
% '-TextSpacing': Same as above but specified in dataset point coordinates.
% '-TextHeightRatio' = 0.05: Overrides 5% text height ratio. This is used
% to calculate the text FontSize-property.
% '-TextHeight': Same as above but specified in dataset point coordinates.
% '-ThicknessRatio' = 0.025: Overrides 2.5% scalebar height ratio.
% '-Thickness': Same as above but specified in dataset point coordinates.
% '-AutoLengthRatio' = 0.5: Overrides 50% scalebar length maximum ratio.
% This is used to calculate the scalebar length, floored to the most
% significant digit.
% '-AutoFloorDigitTo' = [1 2 5]: If not empty, then determine which digits
% are allowed to be used for the scalebar length.
% '-Length': If provided, then disables the automatic scalebar length
% calculation and uses this length value instead.
% '-LengthUnit' = image_standard_units: Determines the standard units of
% the previous length.
% '-LengthFormat' = '%g': Determines the sprintf formatting string in order
% to convert the previous length to text.
% '-PatchVarargin': Any accompanying inputs are provided to the patch
% object.
% '-TextVarargin': Any accompanying inputs are provided to the text object.
% '-NoText': If provided (standalone), then the scalebar is plotted without
% text label.
function h = plot_scalebar_helper(Ax, image_size, image_size_in_SU, image_SU, varargin),
    image_size = reshape(image_size, 1, []); % Force row vector
    image_size_in_SU = reshape(image_size_in_SU, 1, []); % Force row vector

    % Check if Color was specified
    datas = wit.io.parse.varargin_dashed_str_datas('Color', varargin, -1);
    color = [1 1 1]; % White by default
    if numel(datas) > 0, color = datas{1}; end

    % Check if Anchor was specified
    datas = wit.io.parse.varargin_dashed_str_datas('Anchor', varargin, -1);
    anchor = [0 1]; % Bottom-left by default
    if numel(datas) > 0, anchor = datas{1}; end
    anchor = reshape(anchor, 1, []); % Force row vector

    % Check if PositionRatio was specified
    datas = wit.io.parse.varargin_dashed_str_datas('PositionRatio', varargin, -1);
    position_ratio = [0.05 1-0.05]; % 5% margins by default
    if numel(datas) > 0, position_ratio = datas{1}; end
    position_ratio = reshape(position_ratio, 1, []); % Force row vector

    % Check if Position (in points) was specified
    datas = wit.io.parse.varargin_dashed_str_datas('Position', varargin, -1);
    position = position_ratio .* image_size;
    if numel(datas) > 0, position = datas{1}; end

    % Check if TextSpacingRatio was specified
    datas = wit.io.parse.varargin_dashed_str_datas('TextSpacingRatio', varargin, -1);
    text_spacing_ratio = 0.025;
    if numel(datas) > 0, text_spacing_ratio = datas{1}; end

    % Check if TextSpacing (in points) was specified
    datas = wit.io.parse.varargin_dashed_str_datas('TextSpacing', varargin, -1);
    text_spacing = text_spacing_ratio .* image_size(2);
    if numel(datas) > 0, text_spacing = datas{1}; end

    % Check if TextHeightRatio was specified
    datas = wit.io.parse.varargin_dashed_str_datas('TextHeightRatio', varargin, -1);
    text_height_ratio = 0.05;
    if numel(datas) > 0, text_height_ratio = datas{1}; end

    % Check if TextHeight (in points) was specified
    datas = wit.io.parse.varargin_dashed_str_datas('TextHeight', varargin, -1);
    text_height = text_height_ratio .* image_size(2);
    if numel(datas) > 0, text_height = datas{1}; end

    % Check if ThicknessRatio was specified
    datas = wit.io.parse.varargin_dashed_str_datas('ThicknessRatio', varargin, -1);
    thickness_ratio = 0.025;
    if numel(datas) > 0, thickness_ratio = datas{1}; end

    % Check if Thickness (in points) was specified
    datas = wit.io.parse.varargin_dashed_str_datas('Thickness', varargin, -1);
    thickness = thickness_ratio .* image_size(2);
    if numel(datas) > 0, thickness = datas{1}; end

    % Check if AutoLengthRatio was specified
    datas = wit.io.parse.varargin_dashed_str_datas('AutoLengthRatio', varargin, -1);
    auto_length_ratio = 0.5;
    if numel(datas) > 0, auto_length_ratio = datas{1}; end

    % Check if AutoFloorDigitTo was specified
    datas = wit.io.parse.varargin_dashed_str_datas('AutoFloorDigitTo', varargin, -1);
    auto_floor_digit_to = [1 2 5]; % Floor to 1, 2 and 5 digits
    if numel(datas) > 0, auto_floor_digit_to = datas{1}; end
    auto_floor_digit_to = sort(auto_floor_digit_to, 'ascend');

    % Check if Length was specified
    datas = wit.io.parse.varargin_dashed_str_datas('Length', varargin, -1);
    length = []; % Auto length by default
    if numel(datas) > 0, length = datas{1}; end

    % Check if LengthUnit was specified
    datas = wit.io.parse.varargin_dashed_str_datas('LengthUnit', varargin, -1);
    length_unit = [];
    if numel(datas) > 0, length_unit = datas{1}; end

    % Check if LengthFormat was specified
    datas = wit.io.parse.varargin_dashed_str_datas('LengthFormat', varargin, -1);
    length_format = '%g';
    if numel(datas) > 0, length_format = datas{1}; end

    % Check if PatchVarargin was specified
    patch_varargin = wit.io.parse.varargin_dashed_str_datas('PatchVarargin', varargin);

    % Check if TextVarargin was specified
    text_varargin = wit.io.parse.varargin_dashed_str_datas('TextVarargin', varargin);

    % Check if notext was specified
    show_text = ~wit.io.parse.varargin_dashed_str_exists('notext', varargin); % By default, show text

    % Interpret Length (if given) in correct units
    [~, length_in_SU] = wit.io.wip.interpret('Space', image_SU, length_unit, length);

    if isempty(length_in_SU),
        % Initialize the vertical scalebar length
        length_in_SU = auto_length_ratio.*image_size_in_SU(1);

        % Get the most significant digit
        [digit, power] = wit.io.fun.get_significant_digits_and_power(length_in_SU, 1);

        % Automatically floor the digit to
        for ii = numel(auto_floor_digit_to):-1:1,
            if digit >= auto_floor_digit_to(ii),
                digit = auto_floor_digit_to(ii);
                break;
            end
        end

        % Recalculate the scalebar length
        length_in_SU = digit.*10.^power;

        % Generate a string out of this length
        str_digit = char(digit + '0');
        if power >= 0, str_scalebar_length_in_SU = [str_digit repmat('0', [1 power])];
        else, str_scalebar_length_in_SU = ['0.' repmat('0', [1 -1-power]) str_digit]; end
    else,
        str_scalebar_length_in_SU = sprintf(length_format, length_in_SU);
    end

    % Calculate the scalebar length in pixels
    scale = image_size(1) ./ image_size_in_SU(1);
    length = length_in_SU .* scale;

    % Create the scalebar text
    scalebar_text = [str_scalebar_length_in_SU ' ' image_SU];
    
    % Estimate scalebar + text object bounding box
    bounding_box = [length thickness]; % scalebar dimensions
    scalebar_offset = [0 0];
    if show_text, % + text spacing + text height (if present)
        scalebar_offset(2) = text_spacing + text_height;
        bounding_box(2) = bounding_box(2) + scalebar_offset(2);
    end
    
    % Shift position to top-left from the specified anchor
    position = position - anchor.*bounding_box;

    % Plot scalebar
    positions = repmat(position+scalebar_offset, [4 1]); % Top-left (of scalebar)
    positions(2,:) = positions(2,:) + [length 0]; % Set top right
    positions(3,:) = positions(3,:) + [length thickness]; % Set bottom right
    positions(4,:) = positions(4,:) + [0 thickness]; % Set bottom left
    f = [1 2 3 4]; % How vertices are connected to each other
    h(1) = patch('Parent', Ax, 'Faces', f, 'Vertices', positions, 'EdgeColor', 'none', 'FaceColor', color); % Backward compatible with R2011a!
    if ~isempty(patch_varargin),
        set(h(1), patch_varargin{:});
    end

    % Plot its text
    if show_text,
        % Get axes height in pixels and pixels per point -ratio
        Units_old = get(Ax, 'Units');
        set(Ax, 'Units', 'pixels');
        Position = get(Ax, 'Position');
        set(Ax, 'Units', Units_old);
        pixels_per_point = Position(4)./image_size(2);
        % Get FontSize that matches text_height
        FontSize = 72./get(0, 'ScreenPixelsPerInch').*text_height.*pixels_per_point;
        % Plot text
        bottom_center = position + [0.5.*length text_height];
        h(2) = text(bottom_center(1), bottom_center(2), scalebar_text, 'Parent', Ax, 'Color', color, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'baseline', 'FontSize', FontSize); % Backward compatible with R2011a
        if ~isempty(text_varargin),
            set(h(2), text_varargin{:});
        end;
    end
    
    % Force column vector
    h = h(:);
end
