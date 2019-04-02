% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function HtmlName = get_HtmlName(obj)
    HtmlName = reshape({obj.Name}, size(obj));
    % Convert predefined characters to their Html-versions as defined in
    % https://www.w3schools.com/php/func_string_htmlspecialchars.asp:
    HtmlName = strrep(HtmlName, '&', '&amp;'); % & (ampersand) becomes &amp;
    HtmlName = strrep(HtmlName, '"', '&quot;'); % " (double quote) becomes &quot;
    HtmlName = strrep(HtmlName, '''', '&#039;'); % ' (single quote) becomes &#039;
    HtmlName = strrep(HtmlName, '<', '&lt;'); % < (less than) becomes &lt;
    HtmlName = strrep(HtmlName, '>', '&gt;'); % > (greater than) becomes &gt;
    % Construct html string(s)
    folder_reader = regexprep(mfilename('fullpath'), '[\\\/]+[^\\\/]+[\\\/]+[^\\\/]+$', ''); % Step back one folder, assuming file://-case first
    folder_reader = regexprep(folder_reader, '^([^\\\/])', '\\$1'); % Handle file:/// local file -case
    for ii = 1:numel(obj),
        Type = obj(ii).Type; % Read the raw type
        if any(strcmp(Type, {'TDSpectralCursor', 'TDSpaceCursor', 'TDZCursor'})), Type = 'TDCursor'; end % Special case: Cursors
        if any(strcmp(Type, {'TDGraph', 'TDSpaceTransformation'})), ImageFile = sprintf('%s_%d.png', Type, obj(ii).ImageIndex); % Special case: ImageIndices
        else, ImageFile = sprintf('%s.png', Type); end
        ImageFile = strrep(fullfile(folder_reader, 'icons', ImageFile), '\', '/'); % Construct its full path
        if exist(ImageFile, 'file') ~= 2, % Revert to Default.png if attempted ImageFile does NOT exist
            ImageFile = strrep(fullfile(folder_reader, 'icons', 'Default.png'), '\', '/'); % Construct its full path
        end
        % Wrap icon and name in html-table and set their vertical alignment
        % to middle and add 1px cell spacing around the table.
        HtmlName{ii} = sprintf('<html><table cellspacing="1" cellpadding="0"><tr valign="middle"><td><img src="file:%s"/></td><td>&nbsp;%s</td></tr></table></html>', ImageFile, HtmlName{ii});
    end
end
