% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Sorts ID, keeps unique, and finds Project Data (wid) with matching Id. 
function O_wid = find_Data(obj, ID),
    O_wid = WITio.obj.wid.empty;
    for jj = 1:numel(obj),
        if nargin < 2 || isempty(ID), return; end % Return nothing if no ID or empty ID.
        ID = unique(ID);
        Data = obj(jj).Data;
        Data_Ids = [Data.Id];
        for ii = 1:numel(ID),
            O_wid_found = Data(Data_Ids == ID(ii)); % Keep only the matching ID tags
            O_wid = [O_wid; O_wid_found(:)]; % Returns always a column vector
        end
    end
end
