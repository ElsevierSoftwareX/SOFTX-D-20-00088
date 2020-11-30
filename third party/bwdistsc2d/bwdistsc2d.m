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
    if license('test', 'image_toolbox') == 1, % if can, use 2D bwdist from Image Processing Toolbox
        D = bwdist(BW, 'Euclidean');
    else, % if not, use full XY-scan
        S = size(BW); % determine geometry of the data
        
        % In order to minimize the workload, swap dimensions if the first
        % dimension is smaller than the second
        isSwapped = false;
        if S(1) < S(2),
            BW = permute(BW, [2 1]); % Permute to swap dimensions
            S = S(end:-1:1);
            isSwapped = true;
        end
        
        % Determine the inner variable class
        innerClass = 'double';
%         innerClass = 'single';
%         innerClass = 'uint32';
        
        %%%%%%%%%%%%%%% X-SCAN %%%%%%%%%%%%%%%
        % scan bottow-up (for all y), copy dx-reference from previous row 
        % unless there is "on"-pixel in that point in current row, then 
        % that's the nearest pixel now
        dxlower = repmat_realmax_or_intmax(S, innerClass); % reference for nearest "on"-pixel in bw in x direction down
        dxupper = dxlower; % reference for nearest "on"-pixel in bw in x direction up
        dxlower(1,BW(1,:)) = 0; % fill in first row
        dxupper(end,BW(end,:)) = 0; % fill in last row
        for ii = 2:S(1),
            dxlower(ii,:) = dxlower(ii-1,:)+1; % copy previous row
            dxlower(ii,BW(ii,:)) = 0; % unless there is pixel
            jj = S(1)-(ii-1);
            dxupper(jj,:) = dxupper(jj+1,:)+1; % copy next row
            dxupper(jj,BW(jj,:)) = 0; % unless there is pixel
        end
        
        clear BW; % free memory
        
        % build (X,Y) for points for which distance needs to be calculated
        % update distances as shortest to "on" pixels up/down in the above
        DXY = min(dxlower, dxupper).^2;
        
        clear dxlower dxupper; % free memory
        
        %%%%%%%%%%%%%%% Y-SCAN %%%%%%%%%%%%%%%
        D2 = repmat_realmax_or_intmax(S, innerClass); % Initialize
        % this will be the envelop of parabolas at different y
        II = cast(1:S(2), class(DXY));
%         MII = repmat(II, [S(1) 1]); % for (3a) and (3b)
%         MII2 = MII.^2; % for (3b)
%         DXY_MII2 = DXY + MII2; % for (3b)
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
            
            % (2a) Modified scheme by avoiding indexing (FASTEST if double, FAST if single, FAST if uint32)
            DXY_ii = DXY(:,ii);
            for jj = II,
                % all pixels are to be updated
                D2(:,jj) = min(D2(:,jj), DXY_ii + (jj-ii).^2); % indices here can be swapped
            end
            
            % (2b) Modified scheme by avoiding indexing (after swapping the loops) (FASTEST if double, FAST if single, FAST if uint32)
% %             D2_ii = D2(:,ii);
%             for jj = II,
%                 % all pixels are to be updated
%                 D2(:,ii) = min(D2(:,ii), DXY(:,jj) + (jj-ii).^2); % indices here can be swapped
% %                 D2_ii = min(D2_ii, DXY(:,jj) + (jj-ii).^2); % indices here can be swapped
%             end
% %             D2(:,ii) = D2_ii;
            
            % (3a) Modified scheme by avoiding indexing and inner loop (SLOW if double, OK if single, GOOD if uint32)
%             D2 = min(D2, bsxfun(@plus, DXY(:,ii), (MII-ii).^2)); % all pixels are to be updated
            
            % (3b) Modified scheme by avoiding indexing and inner loop (after swapping the loops) (SLOWISH if double, FAST if single, SLOW if uint32)
%             D2(:,ii) = min(DXY_MII2 - 2.*ii.*MII, [], 2) + ii.^2; % all pixels are to be updated
        end
        
        clear DXY; % free memory
        D = sqrt(single(D2)); % output as single like bwdist
        if isSwapped,
            D = permute(D, [2 1]); % Swap dimensions to return the original shape
        end
    end
    
    function D = repmat_realmax_or_intmax(S, classname),
        if strcmp(classname, 'double') || strcmp(classname, 'single'),
            D = repmat(realmax(classname), S);
        else,
            D = repmat(intmax(classname), S);
        end
    end
end