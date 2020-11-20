% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This copies the given objects (except obj) if they are shared by obj and
% any other object in the project and breaks such shared links by referring
% to the copies only in obj.
function varargout = copy_Others_if_shared_and_unshare(obj, varargin),
    varargout = varargin;
    Tag_Id = obj.Tag.Data.regexp('^[^<]+ID(List)?(<[^<]*)*$'); % Should not match with ID<TData!
    B_used = cellfun(@(x) false(size(x)), varargin, 'UniformOutput', false);
    for ii = 1:numel(varargin),
        for jj = 1:numel(varargin{ii}),
            if B_used{ii}(jj), continue; end
            B_used{ii}(jj) = true;
            obj_ii_jj = varargin{ii}(jj);
            if numel(obj_ii_jj.LinksToThis) > 1,
                old_Id = obj_ii_jj.Id;
                
                % See if obj_ii_jj is linked to obj
                Tag_Id_match = Tag_Id.match_by_Data_criteria(@(x) any(x == old_Id));
                if isempty(Tag_Id_match), continue; end % Do nothing if not linked
                
                % Make a copy of a linked obj_ii_jj and use it as result
                new_obj_ii_jj = obj_ii_jj.copy;
                varargout{ii}(jj) = new_obj_ii_jj;
                
                % Update the Ids
                new_Id = new_obj_ii_jj.Id;
                for kk = 1:numel(Tag_Id_match),
                    Tag_Id_match(kk).Data(Tag_Id_match(kk).Data == old_Id) = new_Id;
                end
                
                % Loops to handle the possible duplicates in the inputs
                for nn = ii:numel(varargin),
                    for mm = 1:numel(varargin{nn}),
                        if nn == ii && mm <= jj, continue; end
                        if B_used{nn}(mm), continue; end
                        if varargin{nn}(mm) == obj_ii_jj,
                            varargout{nn}(mm) = new_obj_ii_jj;
                            B_used{nn}(mm) = true;
                        end
                    end
                end
            end
        end
    end
end
