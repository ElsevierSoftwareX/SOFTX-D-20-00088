% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [Data_range, Graph_range, Data_range_bg, range] = reduce_Graph_with_bg_helper(Data, Graph, range, bg_avg_lower, bg_avg_upper)
    warning('You are using a deprecated version! Use crop_Graph_with_bg_helper.m instead.');
    [Data_range, Graph_range, Data_range_bg, range] = wit.reduce_Graph_with_bg_helper(Data, Graph, range, bg_avg_lower, bg_avg_upper);
end
