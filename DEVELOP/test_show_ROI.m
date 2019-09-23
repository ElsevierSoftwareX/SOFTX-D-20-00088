close all;
[O_wid, O_wip, O_wid_HtmlNames] = wip.read('test_show_ROI.WIP', '-all');

% Indices to the objects of interest
% Call to O_wid.manager; was used to determine the following indices
ind_main = 1; % Main image
ind_others = [2 3];
colors = {'red', 'blue'};

% Plot main object
O_main = O_wid(ind_main);
O_main_Info = O_main.Info; % Get Info only once
figure; O_main.plot;

% Calculate the main object's four corners
v_main_px = permute([1 O_main_Info.XSize+1 O_main_Info.XSize+1 1;1 1 O_main_Info.YSize+1 O_main_Info.YSize+1;1 1 1 1], [2 3 1]);
[LengthUnit_main, v_main_um] = O_wip.transform_forced(O_main_Info.XTransformation, v_main_px);
v_main_px = permute(v_main_px(:,:,1:2), [1 3 2]);
v_main_um = permute(v_main_um(:,:,1:2), [1 3 2]);

% Create interpolator for the main object's pixel vertices
v_main_px_1 = scatteredInterpolant(v_main_um(:,1), v_main_um(:,2), v_main_px(:,1), 'linear', 'linear'); % Since R2013a
v_main_px_2 = scatteredInterpolant(v_main_um(:,1), v_main_um(:,2), v_main_px(:,2), 'linear', 'linear'); % Since R2013a

% Loop through the other objects
for ii = 1:numel(ind_others),
    O_ii = O_wid(ind_others(ii));
    O_ii_Info = O_ii.Info; % Get Info only once
    
    v_ii_px = permute([1 O_ii_Info.XSize+1 O_ii_Info.XSize+1 1;1 1 O_ii_Info.YSize+1 O_ii_Info.YSize+1;1 1 1 1], [2 3 1]);
    [LengthUnit_ii, v_ii_um] = O_wip.transform_forced(O_ii_Info.XTransformation, v_ii_px);
    v_ii_px = permute(v_ii_px(:,:,1:2), [1 3 2]);
    v_ii_um = permute(v_ii_um(:,:,1:2), [1 3 2]);

    % Calculate the four vertices
    v_ii = [v_main_px_1(v_ii_um(:,1), v_ii_um(:,2)) v_main_px_2(v_ii_um(:,1), v_ii_um(:,2))];
    f = [1 2 3 4]; % How vertices are connected to each other

    % Draw the ROI of ii'th object on top of the main object figure
    patch('Faces', f, 'Vertices', v_ii, 'EdgeColor', colors{ii}, 'FaceColor', 'none');
end
