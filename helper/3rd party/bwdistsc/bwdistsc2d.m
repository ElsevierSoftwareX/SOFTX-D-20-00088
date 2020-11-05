function D = bwdistsc2d(BW),
    % D=BWDISTSC2D(BW)
    % BWDISTSC2D computes Euclidean distance transform of a binary 2D image
    % BW. Distance transform assigns to each pixel in BW a number that is
    % the distance from that pixel to the nearest nonzero pixel in BW.
    % BWDISTSC2D can accept a regular 2D image.
    %
    % BWDISTSC2D uses fast optimized scan algorithm and is less demanding
    % to physical memory.
    %
    % BWDISTSC2D tries to use MATLAB bwdist from Image Processing Toolbox
    % for 2D scans if possible, which is faster, otherwise BWDISTSC2D will
    % use its own algorithm to also perform 2D scans.
    %
    % (c) Yuriy Mishchenko HHMI JFRC Chklovskii Lab JUL 2007
    % Updated Yuriy Mishchenko (Toros University) SEP 2013
    % Modified & Simplified Joonas T. Holmi (Aalto University) NOV 2020
    
    % This implementation uses optimized forward-backward scan version of
    % the algorithm of the original bwdistsc (2007), which substantially
    % improves its speed and simplifies the code. The improvement is
    % described in the part on the selection initial point in the SIVP
    % paper below. The original implementation is still used in bwdistsc1,
    % since forward-backward scan does not allow limiting computation to a
    % fixed distance value MAXVAL.
    
    % This code is free for use or modifications, just please give credit 
    % where appropriate. And if you modify code or fix bugs, please drop me
    % a message at gmyuriy@hotmail.com.
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Scan algorithms below use following Lema:                     %
    % LEMA: let F(X,z) be lower envelope of a family of parabola:   %
    % F(X,z)=min_{i} [G_i(X)+(z-k_i)^2];                            %
    % and let H_k(X,z)=A(X)+(z-k)^2 be a parabola.                  %
    % Then for H_k(X,z)==F(X,z) at each X there exist at most       %
    % two solutions k1<k2 such that H_k12(X,z)=F(X,z), and          %
    % H_k(X,z)<F(X,z) is restricted to at most k1<k2.               %
    % Here X is any-dimensional coordinate.                         %
    %                                                               %
    % Thus, simply scan away from any z such that H_k(X,z)<F(X,z)   %
    % in either direction as long as H_k(X,z)<F(X,z) and update     %
    % F(X,z). Note that need to properly choose starting point;     %
    % starting point is any z such that H_k(X,z)<F(X,z); z==k is    %
    % usually, but not always the starting point!!!                 %
    % usually, but not always the starting point!                   %
    %                                                               %
    % Citation:                                                     %
    % Mishchenko Y. (2013) A function for fastcomputation of large  %
    % discrete Euclidean distance transforms in three or more       %
    % dimensions in Matlab. Signal, Image and Video Processing      %
    % DOI: 10.1007/s11760-012-0419-9.                               %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%% scan along XY %%%%%%%%%%%%%%%%
    try, % if can, use 2D bwdist from Image Processing Toolbox
        D = bwdist(BW);
    catch, % if not, use full XY-scan
        S = size(BW); % determine geometry of the data
        
        %%%%%%%%%%%%%%% X-SCAN %%%%%%%%%%%%%%%
        % scan bottow-up (for all y), copy dx-reference from previous row 
        % unless there is "on"-pixel in that point in current row, then 
        % that's the nearest pixel now
        dxlower = Inf(S); % reference for nearest "on"-pixel in bw in x direction down
        dxupper = Inf(S); % reference for nearest "on"-pixel in bw in x direction up
%         dxlower = Inf(S, 'single'); % reference for nearest "on"-pixel in bw in x direction down
%         dxupper = Inf(S, 'single'); % reference for nearest "on"-pixel in bw in x direction up
%         dxlower = (2^32-1).*ones(S, 'uint32'); % reference for nearest "on"-pixel in bw in x direction down
%         dxupper = (2^32-1).*ones(S, 'uint32'); % reference for nearest "on"-pixel in bw in x direction up
        dxlower(1,BW(1,:)) = 0; % fill in first row
        dxupper(end,BW(end,:)) = 0; % fill in last row
        for ii = 2:S(1),
            dxlower(ii,:) = dxlower(ii-1,:)+1; % copy previous row
            dxlower(ii,BW(ii,:)) = 0; % unless there is pixel
            jj = S(1)-(ii-1);
            dxupper(jj,:) = dxupper(jj+1,:)+1; % copy next row
            dxupper(jj,BW(jj,:)) = 0; % unless there is pixel
        end
        
        % build (X,Y) for points for which distance needs to be calculated
        % update distances as shortest to "on" pixels up/down in the above
        DXY = zeros(S);
%         DXY = zeros(S, 'single');
%         DXY = zeros(S, 'uint32');
        DXY(~BW) = min(dxlower(~BW).^2, dxupper(~BW).^2);
        
        clear dxlower dxupper BW; % free memory
        
        %%%%%%%%%%%%%%% Y-SCAN %%%%%%%%%%%%%%%
        % this will be the envelop of parabolas at different y
        D2 = Inf(S);
%         D2 = Inf(S, 'single');
%         D2 = (2^32-1).*ones(S, 'uint32');
        II = 1:S(2);
%         MII = repmat(II, [S(1) 1]); % for (3) and (4)
%         MII2 = MII.^2; % for (4)
%         DXY_MII2 = DXY + MII2; % for (4)
        for ii = II,
            % selecting starting point for x:
            % * if parabolas are incremented in increasing order of y, 
            %   then all below-envelop intervals are necessarily right-
            %   open, which means starting point can always be chosen 
            %   at the right end of y-axis
            % * if starting point exists it should be below existing
            %   current envelop at the right end of y-axis
            
            % (1) Original scheme simplified as far as possible (VERY SLOW)
            % scan from starting points down in increments of 1
%             BW_ii_jj = true(S(1),1); % this will keep track along which X should keep updating distances
%             for jj = S(2):-1:1,
%                 % these pixels are to be updated
%                 BW_ii_jj(BW_ii_jj) = D2(BW_ii_jj,jj) > DXY(BW_ii_jj,ii) + (jj-ii).^2; % other pixels are removed from scan
%                 D2(BW_ii_jj,jj) = DXY(BW_ii_jj,ii) + (jj-ii).^2;
%                 if all(~BW_ii_jj), break; end
%             end

            % (2) Modified scheme by avoiding indexing (FASTEST if double, FAST if single, FAST if uint32)
            for jj = II,
                % all pixels are to be updated
                D2(:,jj) = min(D2(:,jj), DXY(:,ii) + (jj-ii).^2); % indices here can be swapped
            end
            
            % (3) Modified scheme by avoiding indexing and inner loop (SLOW if double, OK if single, GOOD if uint32)
%             D2 = min(D2, bsxfun(@plus, DXY(:,ii), (MII-ii).^2)); % all pixels are to be updated
            
            % (4) Modified scheme by avoiding indexing and inner loop (after swapping the loops) (SLOWISH if double, OK if single, GOOD if uint32)
%             D2(:,ii) = min(D2(:,ii), min(DXY_MII2 - 2.*ii.*MII, [], 2)+ii.^2); % all pixels are to be updated
        end
        
        clear DXY; % free memory
        D = sqrt(single(D2)); % output as single like bwdist
    end
end