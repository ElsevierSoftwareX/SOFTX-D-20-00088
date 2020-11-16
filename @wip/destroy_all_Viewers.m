% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function destroy_all_Viewers(obj),
    % Minimal reset for WITec Project 2.10.3.3 to show a project manager.
    Viewer = obj.Tree.regexp('^Viewer<', true);
    Tag1 = wit.io.wit('ViewerClassName 0', 'TVProjectManagerForm');
    Tag2 = wit.io.wit('Viewer 0');
    TVCustomForm = wit.io.wit('TVCustomForm');
    % COMMENTED TO RESET TO MINIMAL DEFAULT PROJECT MANAGER
%     TVCustomForm.Data = ...
%         [wit.io.wit('Version', int32(0)) ...
%         wit.io.wit('ShowCommand', int32(1)) ...
%         wit.io.wit('MinimumPositionX', int32(-1)) ...
%         wit.io.wit('MinimumPositionY', int32(-1)) ...
%         wit.io.wit('MaximumPositionX', int32(-1)) ...
%         wit.io.wit('MaximumPositionY', int32(-1)) ...
%         wit.io.wit('WindowLeft', int32(0)) ...
%         wit.io.wit('WindowTop', int32(100)) ...
%         wit.io.wit('WindowRight', int32(400)) ...
%         wit.io.wit('WindowBottom', int32(900))];
    TVProjectManagerForm = wit.io.wit('TVProjectManagerForm');
    % COMMENTED TO RESET TO MINIMAL DEFAULT PROJECT MANAGER
%     TVProjectManagerForm.Data = ...
%         [wit.io.wit('Version', int32(0)) ...
%         wit.io.wit('SortType', int32(1)) ...
%         wit.io.wit('ShowCategoryToolBar', true) ...
%         wit.io.wit('Image', wit.io.wit('Show', int32(1))) ...
%         wit.io.wit('Filter', wit.io.wit('Show', int32(1))) ...
%         wit.io.wit('Cross Section', wit.io.wit('Show', int32(1))) ...
%         wit.io.wit('Spectrum', wit.io.wit('Show', int32(1))) ...
%         wit.io.wit('Histogram', wit.io.wit('Show', int32(1))) ...
%         wit.io.wit('Cursor', wit.io.wit('Show', int32(1))) ...
%         wit.io.wit('Interpretation', wit.io.wit('Show', int32(0))) ...
%         wit.io.wit('Transformation', wit.io.wit('Show', int32(0))) ...
%         wit.io.wit('Cross Section Info', wit.io.wit('Show', int32(1))) ...
%         wit.io.wit('Look and Feel', wit.io.wit('Show', int32(1))) ...
%         wit.io.wit('Text', wit.io.wit('Show', int32(1)))];
    Tag2.Data = [TVCustomForm TVProjectManagerForm];
    Tag3 = wit.io.wit('NumberOfViewer', int32(1));
    Viewer.Data = [Tag1 Tag2 Tag3];
end
