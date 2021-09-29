% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function returns wit Tree objects that correspond to the given
% binary buffer indices.
function [best_dist, best_obj] = binary_ind2obj(obj, ind), %#ok
    pos = double(ind)-1; % From buffer indices to binary position
    pos = reshape(pos, 1, []); % Force row vector
    if isempty(obj), Roots = WITio.obj.wit.empty;
    else, Roots = [obj.Root]; end
    Roots_End = double([Roots.End]);
    best_dist = bsxfun(@minus, Roots_End(:), pos);
    best_obj = repmat(Roots(:), [1 numel(pos)]);
    for jj = 1:numel(obj), %#ok
        for ii = 1:numel(pos), %#ok
            if best_dist(jj,ii) > 0, %#ok
                [best_dist(jj,ii), best_obj(jj,ii)] = binary_pos2obj_helper([best_obj(jj,ii).ChildrenNow WITio.obj.wit.empty], pos(ii), best_dist(jj,ii), best_obj(jj,ii));
            end
        end
    end
    function [best_dist, best_obj] = binary_pos2obj_helper(obj, pos, best_dist, best_obj), %#ok
        for kk = 1:numel(obj), %#ok
            dist = double(obj(kk).End) - pos;
            if dist < 0, continue;
            elseif isempty(best_dist) || dist <= best_dist, %#ok
                best_dist = dist;
                best_obj = obj(kk);
                break;
            end
        end
        if ~isempty(obj) && ~isempty(best_obj), %#ok
            [best_dist, best_obj] = binary_pos2obj_helper([best_obj.ChildrenNow WITio.obj.wit.empty], pos, best_dist, best_obj);
        end
    end
end
