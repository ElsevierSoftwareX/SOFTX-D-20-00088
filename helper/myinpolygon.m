% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Mimics that of built-in inpolygon, but works for self-intersecting
% polygons as well.
function [in, on, out] = myinpolygon(xq, yq, xv, yv),
    % Algorithm 1: Determine whether P is inside, outside, or on ∂S. It
    % cannot solve the problem of instability that can result from the
    % comparison operations of floating-point numbers.
    
    % Input: A tested point P = (xp,yp) and the edge sequence (P1P2,P2P3,
    % ...,PiPi+1,...,PnPn+1) of a closed polygon S with i = 1,2,...,n.
    
    % Output: Return an integer 1, 0, or −1 depending on whether the point
    % P is within, outside, or on the polygon S, respectively.

    % Source: J. Hao et al (2018) 'Optimal Reliable Point-in-Polygon Test
    % and Differential Coding Boolean Operations on Polygons'
    % https://doi.org/10.3390/sym10100477
    
    % Close the polygon curve
    xv(end+1) = xv(1);
    yv(end+1) = yv(1);
    
    output = zeros(size(xq));
    for jj = 1:numel(xq),
        kk = 0;
        xp = xq(jj);
        yp = yq(jj);
        for ii = 1:numel(xv)-1,
            v1 = yv(ii) - yp; v2 = yv(ii+1) - yp;
            if (v1 < 0 && v2 < 0) || (v1 > 0 && v2 > 0), % Case 11 or 26
                continue;
            end
            u1 = xv(ii) - xp; u2 = xv(ii+1) - xp;
            if v2 > 0 && v1 <= 0, % Case 3, 9, 16, 21, 13, or 24
                ff = u1.*v2 - u2.*v1;
                if ff > 0, % Case 3 or 9
                    kk = kk + 1; % Handle Case 3 or 9
                elseif ff == 0, % Case 16 or 21. The rest are Case 13 or 24
                    output(jj) = -1; % Handle Case 16 or 21
                    break;
                end
            elseif v1 > 0 && v2 <= 0, % Case 4, 10, 19, 20, 12, or 25
                ff = u1.*v2 - u2.*v1;
                if ff < 0, % Case 4 or 10
                    kk = kk + 1; % Handle Case 4 or 10
                elseif ff == 0, % Case 19 or 20. The rest are Case 12 or 25
                    output(jj) = -1; % Handle Case 19 or 20
                    break;
                end
            elseif v2 == 0 && v1 < 0, % Case 7, 14, or 17
                ff = u1.*v2 - u2.*v1;
                if ff == 0, % Case 17. The rest are Case 7 or 14
                    output(jj) = -1;
                    break;
                end
            elseif v1 == 0 && v2 < 0, % Case 8, 15, or 18
                ff = u1.*v2 - u2.*v1;
                if ff == 0, % Case 18. The rest are Case 8 or 15
                    output(jj) = -1;
                    break;
                end
            elseif v1 == 0 && v2 == 0, % Case 1, 2, 5, 6, 22, or 23
                if u2 <= 0 && u1 >= 0, % Case 1
                    output(jj) = -1; % Handle Case 1
                    break;
                elseif u1 <= 0 && u2 >= 0, % Case 2. The rest are Case 5, 6, 22, or 23
                    output(jj) = -1; % Handle Case 2
                    break;
                end
            end
        end
        if mod(kk, 2) == 0,
            output(jj) = 0;
        else,
            output(jj) = 1;
        end
    end
    in = output == 1;
    on = output == -1;
    out = output == 0;
end
