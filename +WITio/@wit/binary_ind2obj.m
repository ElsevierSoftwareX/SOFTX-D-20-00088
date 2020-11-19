% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function returns wit Tree objects that correspond to the given
% binary buffer indices.
function [best_dist, best_obj] = binary_ind2obj(obj, ind),
    pos = double(ind)-1; % From buffer indices to binary position
    pos = reshape(pos, 1, []); % Force row vector
    if isempty(obj), Roots = WITio.wit.empty;
    else, Roots = [obj.Root]; end
    Roots_End = double([Roots.End]);
    best_dist = bsxfun(@minus, Roots_End(:), pos);
    best_obj = repmat(Roots(:), [1 numel(pos)]);
    for jj = 1:numel(obj),
        for ii = 1:numel(pos),
            if best_dist(jj,ii) > 0,
                [best_dist(jj,ii), best_obj(jj,ii)] = binary_pos2obj_helper([best_obj(jj,ii).Children WITio.wit.empty], pos(ii), best_dist(jj,ii), best_obj(jj,ii));
            end
        end
    end
    function [best_dist, best_obj] = binary_pos2obj_helper(obj, pos, best_dist, best_obj), 
        for kk = 1:numel(obj),
            dist = double(obj(kk).End) - pos;
            if dist < 0, continue;
            elseif isempty(best_dist) || dist <= best_dist,
                best_dist = dist;
                best_obj = obj(kk);
                break;
            end
        end
        if ~isempty(obj) && ~isempty(best_obj),
            [best_dist, best_obj] = binary_pos2obj_helper([best_obj.Children WITio.wit.empty], pos, best_dist, best_obj);
        end
    end
end
