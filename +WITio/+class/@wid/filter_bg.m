% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [obj, Data_range, Graph_range, Data_range_bg] = filter_bg(obj, varargin),
    % Pop states (even if not used to avoid push-pop bugs)
    AutoModifyObj = obj.Project.popAutoModifyObj; % Get the latest value (may be temporary or permanent or default)
    
    [Data_range, Graph_range, Data_range_bg, range] = WITio.class.wid.crop_Graph_with_bg_helper(obj.Data, obj.Info.Graph, varargin{:});
    
    obj.Project.pushAutoModifyObj(AutoModifyObj); % Temporarily pass on the same state
    obj = obj.crop_Graph([], Data_range, Graph_range);
    
    % Modify the object (or its copy) if permitted
    if AutoModifyObj,
        obj.Name = sprintf('[%g-%g]<%s', range(1), range(2), obj.Name);
    end
end
