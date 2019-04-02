% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [Data_range, Graph_range, Data_range_bg, range] = reduce_Graph_with_bg_helper(Data, Graph, range, bg_avg_lower, bg_avg_upper)
    % This function is based on WITEC 2.10.3.3 User Manual pp. 134-138.
    % Data can be arbitrarily-sized 4-D matrix. Graph must be either same-
    % sized 4-D matrix OR a vector with length of size(Data, 3). Graph is
    % ASSUMED to be monotonically increasing! NOTES: This is LOW-MEMORY
    % implementation. For instance, permute MEMORY BOTTLENECKs are avoided
    % by keeping Data and Graph read-only! This is at least as fast as
    % older 'data_filter_bg'-version!
    % IMPLEMENTATION TESTED AND VERIFIED 27.7.2017 by Joonas T. Holmi.
    
    % Default
    if nargin < 5, bg_avg_upper = 4; end
    if nargin < 4, bg_avg_lower = 4; end
    if nargin < 3, range = [-inf inf]; end
    
    % Test inputs
    if numel(range) ~= 2,
        error('Range must be a vector with length of 2!');
    end
    
    if ~isscalar(bg_avg_lower) || ~isscalar(bg_avg_upper),
        error('Lower and upper background averaging values must be scalars!');
    end
    
    S_Graph_dim = [];
    if sum(size(Graph) ~= 1) <= 1, % Accepts scalar or vector Graph
        S_Graph_dim = find(size(Graph) ~= 1); % Save the original dimensionality
        Graph = reshape(Graph, 1, 1, []); % Reduce any vector to a vector in 3rd dim
    elseif ndims(Graph) ~= ndims(Data) || any(size(Graph) ~= size(Data)),
        error('Graph must be either a vector or a matrix of the Data size');
    end
    
    % Get sizes if permuted
    S_Data = size(Data);
    S_Graph = size(Graph);
    N_Data = numel(Data);
    N_Graph = numel(Graph);
    
    % Find range indices
    [value_lower, idx_lower] = max(Graph >= range(1), [], 3); % Same as find(~, 1, 'first') in 1-D case
    idx_lower(~value_lower) = NaN; % Mark invalid indices with NaNs
    clear value_lower;
    
    [value_upper, idx_upper] = max(cumsum(Graph < range(2), 3), [], 3); % Same as find(~, 1, 'first') in 1-D case
    idx_upper(~value_upper) = NaN; % Mark invalid indices with NaNs
    clear value_upper;
    
    % Calculate lower background averaging
    [Data_start, Graph_start] = quick_indexing(idx_lower-bg_avg_lower, idx_lower-1);
    Data_mean_start = nanmean_without_toolbox(Data_start, 3);
    Graph_mean_start = nanmean_without_toolbox(Graph_start, 3);
    
    % Calculate upper background averaging
    [Data_end, Graph_end] = quick_indexing(idx_upper+1, idx_upper+bg_avg_upper);
    Data_mean_end = nanmean_without_toolbox(Data_end, 3);
    Graph_mean_end = nanmean_without_toolbox(Graph_end, 3);
    
    % If no lower background averaging
    Graph_mean_start(isnan(Graph_mean_start)) = Graph_mean_end(isnan(Graph_mean_start));
    Graph_mean_end(isnan(Graph_mean_end)) = Graph_mean_start(isnan(Graph_mean_end));
    
    % Limit the range
    [Data_range, Graph_range] = quick_indexing(idx_lower, idx_upper);
    
    % Determine line slope
    m = (Data_mean_end - Data_mean_start) ./ (Graph_mean_end - Graph_mean_start); % Non-horizontal line slope part
    
    % Treat NaNs correctly as no background
    Data_mean_start(isnan(Data_mean_start)) = 0;
    Graph_mean_start(isnan(Graph_mean_start)) = 0;
    m(isnan(m)) = 0;
    
    % Substract background (where possible)
    Data_range_bg = bsxfun(@plus, Data_mean_start, bsxfun(@times, m, bsxfun(@minus, Graph_range, Graph_mean_start)));
    if bg_avg_lower || bg_avg_upper, % Perform background removal only if necessary
        Data_range = bsxfun(@minus, double(Data_range), Data_range_bg); % Remove background
    end
    
    % Reshape Graph_range to be like Graph if they are vectors
    if ~isempty(S_Graph_dim),
        Graph_range = permute(Graph_range(:), [2:S_Graph_dim 1:1+min(1,S_Graph_dim==1)]);
    end
    
    function [y] = nanmean_without_toolbox(x, dim),
        bw_nan = isnan(x);
        x(bw_nan) = 0;
        y = sum(x, dim)./sum(~bw_nan, dim);
    end
    
    % LOOP VERSION: SIMPLEST, LOWEST-memory and FASTEST for N-D input!
    % (Appears to work well when limited to 8 GB of memory.)
    function [Data_sub, Graph_sub] = quick_indexing(start, stop),
        % Force columns
        start = start(:);
        stop = stop(:);
        
        start(start < 1) = 1; % Truncate if out of range
        stop(stop < 1) = NaN; % Cannot be out of range
        
        start(start > size(Graph, 3)) = NaN; % Cannot be out of range
        stop(stop > size(Graph, 3)) = size(Graph, 3); % Truncate if out of range
        
        len = stop - start + 1;
        pos = ~isnan(len) & len > 0; % Ignore nan or zero or negative lengths
        start = start(pos);
        stop = stop(pos);
        len = len(pos);
        
        max_len = max(len);
        if isnan(max_len), max_len = 0; end % Handle case of no match!
        Data_sub = nan([S_Data(1:2) max_len S_Data(4:end)]);
        Graph_sub = nan([S_Graph(1:2) max_len S_Graph(4:end)]);
        [I1, I2, I4] = ind2sub(S_Data([1:2 4:end]), 1:numel(len));
        for ii = 1:numel(len),
            if N_Graph ~= N_Data, Data_sub = Data(:,:,start:stop,:);
            else, Data_sub(I1(ii),I2(ii),1:len(ii),I4(ii)) = Data(I1(ii),I2(ii),start(ii):stop(ii),I4(ii)); end
            Graph_sub(I1(ii),I2(ii),1:len(ii),I4(ii)) = Graph(I1(ii),I2(ii),start(ii):stop(ii),I4(ii));
        end
    end

    % RUN-LENGTH DECODING VERSION: Low-memory and fast for N-D input!
    % Use run-length decoding to avoid indexing in a for-loop
%     function [Data_sub, Graph_sub] = quick_indexing(start, stop),
%         % Force columns
%         start = start(:);
%         stop = stop(:);
%         
%         start(start < 1) = 1; % Truncate if out of range
%         stop(stop < 1) = NaN; % Cannot be out of range
%         
%         start(start > size(Graph, 3)) = NaN; % Cannot be out of range
%         stop(stop > size(Graph, 3)) = size(Graph, 3); % Truncate if out of range
%         
%         len = stop - start + 1;
%         idx = reshape(1:numel(len), [], 1); % Original indices
%         pos = ~isnan(len) & len > 0; % Ignore nan or zero or negative lengths
%         start = start(pos);
%         stop = stop(pos);
%         len = len(pos);
%         idx = idx(pos);
%         ind = reshape(1:numel(idx), [], 1); % New indices
%         
%         % Create the result
%         max_len = max(len);
%         if isempty(max_len), max_len = 0; end % Handle case of no match!
%         Data_sub = nan([S_Data(1:2) max_len S_Data(4:end)]);
%         Graph_sub = nan([S_Graph(1:2) max_len S_Graph(4:end)]);
%         
%         % Avoid ind2sub and sub2ind later by precalculations!
%         [S1, S2, S4] = ind2sub(S_Data([1:2 4:end]), idx);
%         c_Graph_sub = int32(sub2ind(size(Graph_sub), S1, S2, ones(size(idx)), S4) - size(Graph_sub, 2) .* size(Graph_sub, 1)); % Limited so in WITec Project 2.10.3.3
%         c_Data_sub = int32(sub2ind(size(Data_sub), S1, S2, ones(size(idx)), S4) - size(Data_sub, 2) .* size(Data_sub, 1)); % Limited so in WITec Project 2.10.3.3
%         c_Graph = int32(sub2ind(size(Graph), S1, S2, ones(size(idx)), S4) - size(Graph, 2) .* size(Graph, 1)); % Limited so in WITec Project 2.10.3.3
%         c_Data = int32(sub2ind(size(Data), S1, S2, ones(size(idx)), S4) - size(Data, 2) .* size(Data, 1)); % Limited so in WITec Project 2.10.3.3
%         
%         % First part of run-length decoding
%         clen = cumsum(len);
%         
%         % Use while-loop to avoid memory bottleneck at sub2ind and ind2sub!
%         N_max = 1e6; % Limit how many indices to handle per cycle
%         ii = 1;
%         while ii <= numel(clen),
%             % Get the sub problem
%             sub_upper_idx = find(clen <= clen(ii) + N_max, 1, 'last');
%             if isempty(sub_upper_idx), sub_upper_idx = ii; end
%             range_sub = ii:sub_upper_idx; % Get the sub problem range
%             sub_len = len(range_sub);
%             if ii == 1, sub_clen = clen(range_sub);
%             else, sub_clen = clen(range_sub)-clen(ii-1); end
%             sub_ind = ind(range_sub);
%             sub_start = start(range_sub);
%             sub_stop = stop(range_sub);
%             ii = sub_upper_idx+1; % Skip the index accordingly
%             
%             % Instead of slow: incr = accumarray([1; sub_clen(1:end-1)+1], [1; 1-sub_len(1:end-1)], [], [], 1);
%             incr = ones(sub_clen(end), 1, 'int32'); % Limited so in WITec Project 2.10.3.3
%             incr([1; sub_clen(1:end-1)+1]) = [1; 1-sub_len(1:end-1)]; % Handle jumps
%             I3_sub = cumsum(incr); % Second part of run-length decoding
% 
%             % Instead of slow: incr = accumarray([1; sub_clen(1:end-1)+1], [sub_start(1); sub_start(2:end)-sub_stop(1:end-1)], [], [], 1);
%             incr = ones(sub_clen(end), 1, 'int32'); % Limited so in WITec Project 2.10.3.3
%             incr([1; sub_clen(1:end-1)+1]) = [sub_start(1); sub_start(2:end)-sub_stop(1:end-1)]; % Handle jumps
%             I3 = cumsum(incr); % Second part of run-length decoding
% 
%             % Instead of slow: incr = accumarray([1; sub_clen(1:end-1)+1], diff([0; sub_ind(:)]));
%             incr = zeros(sub_clen(end), 1, 'int32'); % Limited so in WITec Project 2.10.3.3
%             incr([1; sub_clen(1:end-1)+1]) = diff([0; sub_ind(:)]); % Handle jumps
%             ind3 = cumsum(incr); % Second part of run-length decoding
%             
%             Graph_sub(c_Graph_sub(ind3) + I3_sub .* size(Graph_sub, 2) .* size(Graph_sub, 1)) = Graph(c_Graph(ind3) + I3 .* size(Graph, 2) .* size(Graph, 1));
%             if N_Graph ~= N_Data, Data_sub = Data(:,:,start:stop,:);
%             else, Data_sub(c_Data_sub(ind3) + I3_sub .* size(Data_sub, 2) .* size(Data_sub, 1)) = Data(c_Data(ind3) + I3 .* size(Data, 2) .* size(Data, 1)); end
%         end
%     end
end
