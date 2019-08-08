% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Use this function to reduce the TDGraph object Data and its Graph ranges
% to the given pixel indices [ind_range(1), ind_range(2)]. It is assumed that the
% given object and pixel indices are valid.
function [obj, Data_reduced, Graph_reduced] = reduce_Graph(obj, ind_range, Data_reduced, Graph_reduced),
    warning('You are using a deprecated version! Use crop_Graph.m instead.');
    [obj, Data_reduced, Graph_reduced] = obj.crop_Graph(ind_range, Data_reduced, Graph_reduced);
end
