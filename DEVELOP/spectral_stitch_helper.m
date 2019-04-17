% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Spectral stitching of the given TDGraph objects into a large spectrum.
% Each TDGraph must be of same spatial size. Stitching of each individual
% overlap is linear, but, due to a product rule, becomes non-linear for
% more generalized case of multiple simultaneous overlaps. Linear case
% behaves like WITec's Spectral Stitching measurement scheme.

% WARNING! The related instrumental errors, if NOT corrected for, can lead
% to UNPHYSICAL stitching result in the overlapping regions, even if their
% apparent stitching result looks smooth!
function [Graph, Data, W, D] = spectral_stitch_helper(Graphs_nm, Datas, isdebug)
    % Test if '-debug' was given
    if nargin < 3, isdebug = false; end % By default, hide debug plots
    
    % Cellify
    if ~iscell(Graphs_nm), Graphs_nm = {Graphs_nm}; end
    if ~iscell(Datas), Datas = {Datas}; end
    
    N_TDGraph = numel(Datas); % Number of TDGraph
    if N_TDGraph == 0 || numel(Graphs_nm) ~= N_TDGraph, error('No input or inconsistent input!'); end % Test if TDGraphs OR ABORT
    
    % Store Datas and test if sizes have spectral stitching consistency
    Datas = reshape(Datas, [], 1);
    Datas_ndims = cellfun(@ndims, Datas); % Get dimension counts
    Datas_ndims_max = max(Datas_ndims); % Find maximum dimension count
    [Datas_size{1:Datas_ndims_max}] = cellfun(@size, Datas); % Get sizes
    Datas_size = cat(2, Datas_size{:}); % Convert to a matrix
    delta_size = diff(Datas_size, [], 1); % Find size differences
    delta_size(:,3) = 0; % Ignore differences in spectral dimension
    if any(delta_size(:)), error('Inconsistent Data dimension sizes! Only 3rd dimension can vary in size.'); end
    [SizeX, SizeY, ~, SizeZ] = size(Datas{1});
    SizeXYZ = SizeX.*SizeY.*SizeZ;
    ind_debug = randi(SizeXYZ); % Choose a random index for debug plotting
    
    % Store Graphs (in nm), Weights, min/max of Graphs and indices
    Graphs_nm = reshape(Graphs_nm, [], 1);
    Graph_nm_minmax = nan(N_TDGraph, 2);
    indices = nan(N_TDGraph, 2);
    Weights = cell(N_TDGraph, 1);
    for ii = 1:N_TDGraph,
        Datas{ii} = reshape(permute(Datas{ii}, [3 1 2 4]), [], SizeXYZ); % Permute and collapse to 2-D matrix
        Graphs_nm{ii} = reshape(Graphs_nm{ii}, [], 1); % Force to column vector
        Graph_nm_minmax(ii,:) = [min(Graphs_nm{ii}) max(Graphs_nm{ii})]; % Min, max
        indices(ii,:) = ii;
        % Preallocate Weights
        Weights{ii} = ones(size(Graphs_nm{ii}));
    end
    
    % Minimize the effort by constructing a binary map, which shows overlaps
    [Graph_nm_minmax, ind_sort] = sort(Graph_nm_minmax(:));
    indices = indices(ind_sort);
    bw_overlap = false(N_TDGraph, 2.*N_TDGraph);
    bw_overlap(sub2ind(size(bw_overlap), indices.', 1:2.*N_TDGraph)) = true; % Assign indices of TDGraph
    bw_overlap = cumsum(bw_overlap, 2) == 1;
    ind_gaps = find(all(~bw_overlap, 1)); % Find gaps
    bw_overlap(:,ind_gaps) = bw_overlap(:,ind_gaps-1); % Fill gaps with copies
    
    % A total weight per TDGraph is a PRODUCT of each individual weight
    % describing a single overlap case per TDGraph. Only a partial overlap
    % can affect the total weight. Its weight is described by a sloped step
    % function, which has a linear slope from 0 to 1 within the overlapping
    % region and is 1 elsewhere. A PRODUCT instead of SUM is taken because
    % all individual overlap cases of same point (and their weights) are
    % thought as simultaneous events (and their probabilities). For the
    % same reason they are also later renormalized (with respect to 
    % total weights of other TDGraphs, interpolated to same point). This
    % also leads to the stitching continuity across overlaps.
    % VERIFICATION:
    % Total weights were verified by a simple, symmetric stitching case of
    % three spectra, where outermost two spectra do not overlap but touch.
    % In this case, outermost total weights are sloped step functions AND
    % middle total weight is a triangle function, both as expected. It is
    % noteworthy that this appears identical to WITec's Spectral Stitching
    % measurement scheme stitching behaviour.
    bw_skip = false(N_TDGraph, N_TDGraph);
    for ii = 1:N_TDGraph,
        x_ii = Graphs_nm{ii}; % Index to current TDGraph
        ind_minmax_ii = find(indices == ii); % Find min/max pair
        minmax_ii = Graph_nm_minmax(ind_minmax_ii);
        for kk = ind_minmax_ii(1)+1:ind_minmax_ii(2)-1,
            jj = indices(kk); % Index to other TDGraph
            if bw_skip(ii,jj), continue; end % Skip to avoid doing same process twice
            x_jj = Graphs_nm{jj};
            w_ii_on_jj = ones(size(x_ii));
            w_jj_on_ii = ones(size(x_jj));
            minmax_jj = Graph_nm_minmax(indices == jj); % Find min/max pair
            % (1) Partial overlap (ii's right-side is PARTIALLY overlapping jj's left-side)
            if minmax_ii(1) < minmax_jj(1) && minmax_ii(2) < minmax_jj(2),
                bw_ii_overlap = x_ii >= minmax_jj(1);
                bw_jj_overlap = x_jj <= minmax_ii(2);
                w_ii_on_jj(bw_ii_overlap) = (minmax_ii(2)-x_ii(bw_ii_overlap))./(minmax_ii(2)-minmax_jj(1));
                w_jj_on_ii(bw_jj_overlap) = (x_jj(bw_jj_overlap)-minmax_jj(1))./(minmax_ii(2)-minmax_jj(1));
%                 w_ii_on_jj = interp1([minmax_ii(1) minmax_jj(1) minmax_ii(2) minmax_jj(2)], [1 1 0 0], x_ii, 'linear');
%                 w_jj_on_ii = interp1([minmax_ii(1) minmax_jj(1) minmax_ii(2) minmax_jj(2)], [0 0 1 1], x_jj, 'linear');
            % (2) Partial overlap (ii's left-side is PARTIALLY overlapping jj's right-side)
            elseif minmax_ii(1) > minmax_jj(1) && minmax_ii(2) > minmax_jj(2),
                bw_ii_overlap = x_ii <= minmax_jj(2);
                bw_jj_overlap = x_jj >= minmax_ii(1);
                w_ii_on_jj(bw_ii_overlap) = (x_ii(bw_ii_overlap)-minmax_ii(1))./(minmax_jj(2)-minmax_ii(1));
                w_jj_on_ii(bw_jj_overlap) = (minmax_jj(2)-x_jj(bw_jj_overlap))./(minmax_jj(2)-minmax_ii(1));
%                 w_ii_on_jj = interp1([minmax_jj(1) minmax_ii(1) minmax_jj(2) minmax_ii(2)], [0 0 1 1], x_ii, 'linear');
%                 w_jj_on_ii = interp1([minmax_jj(1) minmax_ii(1) minmax_jj(2) minmax_ii(2)], [1 1 0 0], x_jj, 'linear');
            % (3) Complete overlap (ii is COMPLETELY overlapped by jj)
            elseif minmax_ii(1) >= minmax_jj(1) && minmax_ii(2) <= minmax_jj(2),
                % DO NOTHING
            % (4) Complete overlap (jj is COMPLETELY overlapped by ii)
            elseif minmax_ii(1) <= minmax_jj(1) && minmax_ii(2) >= minmax_jj(2),
                % DO NOTHING
            end
            Weights{ii} = Weights{ii} .* w_ii_on_jj; % Update ii'th weight
            Weights{jj} = Weights{jj} .* w_jj_on_ii; % Update jj'th weight
            bw_skip(ii,jj) = true;
            bw_skip(jj,ii) = true; % Due to symmetry!
            if isdebug,
                figure(1); subplot(2,1,1); plot(x_ii, w_ii_on_jj, 'r', x_jj, w_jj_on_ii, 'g'); title(sprintf('Weights @ %d/%d: (%d vs. %d)', ind_debug, SizeXYZ, ii, jj));
                subplot(2,1,2); plot(x_ii, Datas{ii}(:,ind_debug), 'r', x_jj, Datas{jj}(:,ind_debug), 'g'); title(sprintf('Datas @ %d/%d: (%d vs. %d)', ind_debug, SizeXYZ, ii, jj));
                java.lang.Thread.sleep(10000./sum(bw_overlap(:))); % Aim for total ~10 sec
            end
        end
    end
    
    % Evaluate weighted sum of individual objects
    Graph = unique(cat(1, Graphs_nm{:})); % Construct unique Graph-axis
    Data = zeros(numel(Graph), SizeXYZ);
    if isdebug || nargout > 2, % Store only if requested
        W = zeros(numel(Graph), N_TDGraph); % Weights (normalized) for debugging
        D = nan(numel(Graph), N_TDGraph, SizeXYZ); % Datas for debugging
    end
    for ii = 1:size(bw_overlap, 2),
        bw_ii = bw_overlap(:,ii);
        N_ii = sum(bw_ii); % Number of overlapping TDGraphs
        
        % For overlapping TDGraphs
        Datas_ii = Datas(bw_ii);
        Graphs_nm_ii = Graphs_nm(bw_ii);
        Weights_ii = Weights(bw_ii);
        
        % Find overlapping region
        Graph_nm_min = Graph_nm_minmax(ii);
        Graph_nm_max = inf;
        if ii+1 <= size(bw_overlap, 2), Graph_nm_max = Graph_nm_minmax(ii+1); end
        bw = Graph >= Graph_nm_min & Graph <= Graph_nm_max;
        
        % Renormalize interpolate weights
        weights_ii_bw = zeros(sum(bw), N_ii);
        for jj = 1:N_ii,
            weights_ii_bw(:,jj) = interp1(Graphs_nm_ii{jj}, Weights_ii{jj}, Graph(bw), 'linear');
        end
        weights_ii_bw = bsxfun(@rdivide, weights_ii_bw, sum(weights_ii_bw, 2)); % Renormalize
        if isdebug || nargout > 2, W(bw,bw_ii) = weights_ii_bw; end % Store only if requested
        
        % Interpolate datas
        Data_ii_bw = zeros(sum(bw), N_ii, SizeXYZ);
        for jj = 1:N_ii,
            Data_ii_bw(:,jj,:) = interp1(Graphs_nm_ii{jj}, double(Datas_ii{jj}), Graph(bw), 'linear');
        end
        if isdebug || nargout > 2, D(bw,bw_ii,:) = Data_ii_bw; end % Store only if requested
        
        % Get weighted sum of datas
        Data(bw,:) = sum(bsxfun(@times, Data_ii_bw, weights_ii_bw), 2);
    end
    
    % For debugging
    if isdebug,
        figure(2); clf; plot(Graph, bsxfun(@times, D(:,:,ind_debug), W), '.'); % Weighted interpolated datas
        hold on; plot(Graph, Data(:,ind_debug), 'k'); % Plot stitching result
        title(sprintf('Stitched Data (black) @ %d/%d vs. Weighted Datas @ %d/%d', ind_debug, SizeXYZ, ind_debug, SizeXYZ));

        % Plot interpolated datas
        figure(3); clf; plot(Graph, D(:,:,ind_debug)); title(sprintf('Datas @ %d/%d', ind_debug, SizeXYZ));

        % Plot normalized weights
        figure(4); clf; plot(Graph, W); title('Normalized weights');
    end
    
    % Reshape and permute to original
    Data = reshape(Data, numel(Graph), SizeX, SizeY, SizeZ);
    Data = ipermute(Data, [3 1 2 4]);
end
