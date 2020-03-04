% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function destroy_all_Viewers(obj),
    % Minimal reset for WITec Project 2.10.3.3 to show a project manager.
    Viewer = obj.Tree.regexp('^Viewer<', true);
    Tag1 = wit('ViewerClassName 0', 'TVProjectManagerForm');
    Tag2 = wit('Viewer 0');
    TVCustomForm = wit('TVCustomForm');
    % COMMENTED TO RESET TO MINIMAL DEFAULT PROJECT MANAGER
%     TVCustomForm.Data = ...
%         [wit('Version', int32(0)) ...
%         wit('ShowCommand', int32(1)) ...
%         wit('MinimumPositionX', int32(-1)) ...
%         wit('MinimumPositionY', int32(-1)) ...
%         wit('MaximumPositionX', int32(-1)) ...
%         wit('MaximumPositionY', int32(-1)) ...
%         wit('WindowLeft', int32(0)) ...
%         wit('WindowTop', int32(100)) ...
%         wit('WindowRight', int32(400)) ...
%         wit('WindowBottom', int32(900))];
    TVProjectManagerForm = wit('TVProjectManagerForm');
    % COMMENTED TO RESET TO MINIMAL DEFAULT PROJECT MANAGER
%     TVProjectManagerForm.Data = ...
%         [wit('Version', int32(0)) ...
%         wit('SortType', int32(1)) ...
%         wit('ShowCategoryToolBar', true) ...
%         wit('Image', wit('Show', int32(1))) ...
%         wit('Filter', wit('Show', int32(1))) ...
%         wit('Cross Section', wit('Show', int32(1))) ...
%         wit('Spectrum', wit('Show', int32(1))) ...
%         wit('Histogram', wit('Show', int32(1))) ...
%         wit('Cursor', wit('Show', int32(1))) ...
%         wit('Interpretation', wit('Show', int32(0))) ...
%         wit('Transformation', wit('Show', int32(0))) ...
%         wit('Cross Section Info', wit('Show', int32(1))) ...
%         wit('Look and Feel', wit('Show', int32(1))) ...
%         wit('Text', wit('Show', int32(1)))];
    Tag2.Data = [TVCustomForm TVProjectManagerForm];
    Tag3 = wit('NumberOfViewer', int32(1));
    Viewer.Data = [Tag1 Tag2 Tag3];
end
