% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Use this function to reduce the TDBitmap, TDGraph or TDImage object Data
% and its X, Y, Graph, Z ranges to the given pixel indices. It is assumed
% that the given object and pixel indices are valid. If any of the begin
% indices are [], then they are set 1. If any of the end indices are [],
% then they are set to the end of Data.
function [obj, Data_reduced, X_reduced, Y_reduced, Graph_reduced, Z_reduced] = reduce(obj, ind_X_begin, ind_X_end, ind_Y_begin, ind_Y_end, ind_Graph_begin, ind_Graph_end, ind_Z_begin, ind_Z_end),
    warning('You are using a deprecated version! Use crop.m instead.');
    [obj, Data_reduced, X_reduced, Y_reduced, Graph_reduced, Z_reduced] = obj.crop(ind_X_begin, ind_X_end, ind_Y_begin, ind_Y_end, ind_Graph_begin, ind_Graph_end, ind_Z_begin, ind_Z_end);
end
