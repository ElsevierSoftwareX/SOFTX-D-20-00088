% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function destroy_all_Viewers(obj),
    for ii = 1:numel(obj),
        % Minimal reset for WITec Project 2.10.3.3 to show a project manager.
        Viewer = obj(ii).Tree.regexp('^Viewer<', true);
        Tag1 = WITio.obj.wit('ViewerClassName 0', 'TVProjectManagerForm');
        Tag2 = WITio.obj.wit('Viewer 0');
        TVCustomForm = WITio.obj.wit('TVCustomForm');
        % COMMENTED TO RESET TO MINIMAL DEFAULT PROJECT MANAGER
%         TVCustomForm.Data = ...
%             [WITio.obj.wit('Version', int32(0)) ...
%             WITio.obj.wit('ShowCommand', int32(1)) ...
%             WITio.obj.wit('MinimumPositionX', int32(-1)) ...
%             WITio.obj.wit('MinimumPositionY', int32(-1)) ...
%             WITio.obj.wit('MaximumPositionX', int32(-1)) ...
%             WITio.obj.wit('MaximumPositionY', int32(-1)) ...
%             WITio.obj.wit('WindowLeft', int32(0)) ...
%             WITio.obj.wit('WindowTop', int32(100)) ...
%             WITio.obj.wit('WindowRight', int32(400)) ...
%             WITio.obj.wit('WindowBottom', int32(900))];
        TVProjectManagerForm = WITio.obj.wit('TVProjectManagerForm');
        % COMMENTED TO RESET TO MINIMAL DEFAULT PROJECT MANAGER
%         TVProjectManagerForm.Data = ...
%             [WITio.obj.wit('Version', int32(0)) ...
%             WITio.obj.wit('SortType', int32(1)) ...
%             WITio.obj.wit('ShowCategoryToolBar', true) ...
%             WITio.obj.wit('Image', WITio.obj.wit('Show', int32(1))) ...
%             WITio.obj.wit('Filter', WITio.obj.wit('Show', int32(1))) ...
%             WITio.obj.wit('Cross Section', WITio.obj.wit('Show', int32(1))) ...
%             WITio.obj.wit('Spectrum', WITio.obj.wit('Show', int32(1))) ...
%             WITio.obj.wit('Histogram', WITio.obj.wit('Show', int32(1))) ...
%             WITio.obj.wit('Cursor', WITio.obj.wit('Show', int32(1))) ...
%             WITio.obj.wit('Interpretation', WITio.obj.wit('Show', int32(0))) ...
%             WITio.obj.wit('Transformation', WITio.obj.wit('Show', int32(0))) ...
%             WITio.obj.wit('Cross Section Info', WITio.obj.wit('Show', int32(1))) ...
%             WITio.obj.wit('Look and Feel', WITio.obj.wit('Show', int32(1))) ...
%             WITio.obj.wit('Text', WITio.obj.wit('Show', int32(1)))];
        Tag2.Data = [TVCustomForm TVProjectManagerForm];
        Tag3 = WITio.obj.wit('NumberOfViewer', int32(1));
        Viewer.Data = [Tag1 Tag2 Tag3];
    end
end
