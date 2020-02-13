% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function copy_LinksToOthers(obj),
    % DANGER! Call this function only if obj and its obj.Tag are COPIES!
    % Handle transformations and interpretations
    Tag_Id = obj.Tag.Data.regexp('^[^<]+ID(<[^<]*)*$'); % Should not match with ID under TData!
    for ii = 1:numel(Tag_Id),
        if Tag_Id(ii).Data ~= 0, % Ignore if zero
            Link = obj.Project.find_Data(Tag_Id(ii).Data);
            Link_new = Link.copy();
            Tag_Id(ii).Data = Link_new.Id; % DANGER! This modifies obj.Tag!
        end
    end
end
