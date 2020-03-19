% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function destroy_LinksToOthers(obj),
    % Handle transformations and interpretations
    Tag_Id = obj.Tag.Data.regexp('^[^<]+ID(<[^<]*)*$'); % Should not match with ID under TData!
    for ii = 1:numel(Tag_Id),
        Tag_Id(ii).Data = int32(0); % Must be int32!
    end
end
