% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This generates Html names that include the data specific icons for the
% given objects. The returned cell array can then be double-clicked under
% Workspace in order to more easily distinguish between them. You may need
% to rescale the 1st column by holding left-mouse on the border between 1
% and 2. Doing this is recommended when working with several objects.

% Here isWorkspaceOptimized is true by default, but is set only false when
% used by Project Manager, which needs larger icons and vertical centering.
function HtmlName = get_HtmlName(obj, isWorkspaceOptimized),
    if nargin < 2, isWorkspaceOptimized = true; end
    HtmlName = reshape({obj.Name}, size(obj));
    % Convert predefined characters to their Html-versions as defined in
    % https://www.w3schools.com/php/func_string_htmlspecialchars.asp:
    HtmlName = strrep(HtmlName, '&', '&amp;'); % & (ampersand) becomes &amp;
    HtmlName = strrep(HtmlName, '"', '&quot;'); % " (double quote) becomes &quot;
    HtmlName = strrep(HtmlName, '''', '&#039;'); % ' (single quote) becomes &#039;
    HtmlName = strrep(HtmlName, '<', '&lt;'); % < (less than) becomes &lt;
    HtmlName = strrep(HtmlName, '>', '&gt;'); % > (greater than) becomes &gt;
    % Construct html string(s)
    folder = WITio.tbx.path.icons;
    if isWorkspaceOptimized, folder = fullfile(folder, 'icons (16x16)'); end
    for ii = 1:numel(obj),
        Type = obj(ii).Type; % Read the raw type
        if any(strcmp(Type, {'TDSpectralCursor', 'TDSpaceCursor', 'TDZCursor'})), Type = 'TDCursor'; end % Special case: Cursors
        if any(strcmp(Type, {'TDGraph', 'TDSpaceTransformation'})), ImageFile = sprintf('%s_%d.png', Type, obj(ii).ImageIndex); % Special case: ImageIndices
        else, ImageFile = sprintf('%s.png', Type); end
        ImageFile = fullfile(folder, ImageFile); % Construct its full path
        if exist(ImageFile, 'file') ~= 2, % Revert to Default.png if attempted ImageFile does NOT exist
            ImageFile = fullfile(folder, 'Default.png'); % Construct its full path
        end
        if isWorkspaceOptimized, % isProjectManagerOptimized == false
            % Wrap icon and name in html-table and set their vertical alignment
            % to middle and add 1px cell spacing around the table.
            HtmlName{ii} = sprintf('<html><img height="16" width="16" src="file:%s"/>&nbsp;%s</html>', strrep(ImageFile, '\', '/'), HtmlName{ii}); % height and width are required by R2019b and onwards
        else, % isProjectManagerOptimized == true
            info = imfinfo(ImageFile); % Get height and width, required by R2019b and onwards
            if verLessThan('matlab', '9.7'), % If older than R2019b
                % Wrap icon and name in html-table and set their vertical alignment
                % to middle and add 1px cell spacing around the table.
                HtmlName{ii} = sprintf('<html><table cellspacing="1" cellpadding="0"><tr valign="middle"><td><img height="%d" width="%d" src="file:%s"/></td><td>&nbsp;%s</td></tr></table></html>', info.Height, info.Width, strrep(ImageFile, '\', '/'), HtmlName{ii}); % height and width are required by R2019b and onwards
            else, % If R2019b or newer that use uihtml_JList.html via uihtml
                [~, name, ext] = fileparts(ImageFile);
                ImageFile = [name ext]; % Remove path, because uihtml_project_manager.html is located in the same folder as the icons
                HtmlName{ii} = sprintf('<tr><td width="1px"><img height="%d" width="%d" src="%s"/></td><td>&nbsp;%s</td></tr>', info.Height, info.Width, strrep(ImageFile, '\', '/'), HtmlName{ii}); % height and width are required by R2019b and onwards
            end
        end
    end
end
