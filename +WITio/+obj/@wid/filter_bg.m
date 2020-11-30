% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [obj, Data_range, Graph_range, Data_range_bg] = filter_bg(obj, varargin),
    [Data_range, Graph_range, Data_range_bg, range] = WITio.obj.wid.crop_Graph_with_bg_helper(obj.Data, obj.Info.Graph, varargin{:});
    
    obj = obj.crop_Graph([], Data_range, Graph_range);
    
    % Modify the object (or its copy) if permitted
    if WITio.tbx.pref.get('wip_AutoModifyObj', true),
        obj.Name = sprintf('[%g-%g]<%s', range(1), range(2), obj.Name);
    end
end
