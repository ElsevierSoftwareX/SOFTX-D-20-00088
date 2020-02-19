% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function T = overlay(obj, obj_2),
    [moving, fixed] = cpselect(obj.Data, obj_2.Data);
    
    % Transpose to column
    moving = moving.';
    fixed = fixed.';
    
    % Append z-dimension by adding ones
    moving(3,:) = 1;
    fixed(3,:) = 1;
    
    % Generate affine transformation matrix that will transform from moving
    % to fixed coordinate system
    T = fixed / moving;
    
    % Take into account the known transformation matrix for obj
    T_obj = obj.Info.XTransformation.Data.TDSpaceTransformation;
    % TODOOO
    T_obj_2 = T * T_obj;
end
