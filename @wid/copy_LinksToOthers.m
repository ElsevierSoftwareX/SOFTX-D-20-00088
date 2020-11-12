% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function copy_LinksToOthers(obj),
    % Temporarily disable the Project related wit-class ObjectModified events until the end of the function
    Root = obj.Tag.Root;
    Data = obj.Tag.Data;
    Root.disableObjectModified;
    ocu = onCleanup(@Root.enableObjectModified);
    Data.disableObjectModified;
    ocu2 = onCleanup(@Data.enableObjectModified);
    
    % DANGER! Call this function only if obj and its obj.Tag are COPIES!
    % Handle transformations and interpretations
    Tag_Id = obj.Tag.Data.regexp('^[^<]+ID(List)?(<[^<]*)*$'); % Should not match with ID<TData!
    for ii = 1:numel(Tag_Id),
        ids_ii = Tag_Id(ii).Data;
        for jj = 1:numel(ids_ii),
            if ids_ii(jj) ~= 0, % Ignore if zero
                Link = obj.Project.find_Data(ids_ii(jj));
                Link_new = Link.copy();
                Tag_Id(ii).Data(jj) = Link_new.Id; % DANGER! This modifies obj.Tag!
            end
        end
    end
end
