close all;
[O_wid, O_wip, O_wid_HtmlNames] = wip.read('test_show_ROI.WIP', '-all');

% Indices to the objects of interest
% Call to O_wid.manager; was used to determine the following indices
ind_main = 1; % Main image
ind_others = [2 3];

% Plot main object
O_main = O_wid(ind_main);
O_main_Info = O_main.Info; % Get Info only once
figure(1); O_main.plot;
C = get(gca, 'ColorOrder');

% Get the main object Space Transformation
T = O_main_Info.SecondaryXTransformation;
if isempty(T) || ~strcmp(T.Type, 'TDSpaceTransformation'), T = O_main_Info.XTransformation; end
if isempty(T) || ~strcmp(T.Type, 'TDSpaceTransformation'), return; end
T_Data = T.Data;
TSpace = T_Data.TDSpaceTransformation;
ModelOrigin = TSpace.ViewPort3D.ModelOrigin(:);
WorldOrigin = TSpace.ViewPort3D.WorldOrigin(:);
Scale = reshape(TSpace.ViewPort3D.Scale, [3 3]);
Rotation = reshape(TSpace.ViewPort3D.Rotation, [3 3]);

% Loop through the other objects
for ii = 1:numel(ind_others),
    O_ii = O_wid(ind_others(ii));
    O_ii_Info = O_ii.Info; % Get Info only once
    
    % Get the other object Space Transformation
    T_ii = O_ii_Info.SecondaryXTransformation;
    if isempty(T_ii) || ~strcmp(T_ii.Type, 'TDSpaceTransformation'), T_ii = O_ii_Info.XTransformation; end
    if isempty(T_ii) || ~strcmp(T_ii.Type, 'TDSpaceTransformation'), continue; end
    T_ii_Data = T_ii.Data;
    TSpace_ii = T_ii_Data.TDSpaceTransformation;
    ModelOrigin_ii = TSpace_ii.ViewPort3D.ModelOrigin(:);
    WorldOrigin_ii = TSpace_ii.ViewPort3D.WorldOrigin(:);
    Scale_ii = reshape(TSpace_ii.ViewPort3D.Scale, [3 3]);
    Rotation_ii = reshape(TSpace_ii.ViewPort3D.Rotation, [3 3]);
    
    % Calculate four vertices in three coordinate systems: (1) its own,
    % (2) world coordinate system, and (3) main object's.
    px_ii = [0.5 O_ii_Info.XSize+0.5 O_ii_Info.XSize+0.5 0.5;0.5 0.5 O_ii_Info.YSize+0.5 O_ii_Info.YSize+0.5;1 1 1 1]; % Half pixels in X- and Y-directions, because the middle of pixels are at integers.
    um_ii = bsxfun(@plus, Rotation_ii*Scale_ii*bsxfun(@minus, px_ii-1, ModelOrigin_ii), WorldOrigin_ii);
    px = bsxfun(@plus, (Rotation*Scale)\bsxfun(@minus, um_ii, WorldOrigin), ModelOrigin+1);
    
    % Draw the ROI of ii'th object on top of the main object figure
    f = [1 2 3 4]; % How vertices are connected to each other
    v_ii = px(1:2,:).'; % Discard the Z-axis indices and reshape for patch
    patch('Faces', f, 'Vertices', v_ii, 'EdgeColor', C(mod(ii-1,size(C,1))+1,:), 'FaceColor', 'none', 'LineWidth', 1);
end

figure(2);
O_main.plot('-position', O_wid(ind_others));
