% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Sorts ID, keeps unique, and finds Project Data (wid) with matching Id. 
function C_wid = find_Data(obj, ID)
    C_wid = wid.Empty;
    if isempty(obj), return; end % Return nothing if empty Project.
    if nargin < 2 || isempty(ID), return; end % Return nothing if no ID or empty ID.
    ID = unique(ID);
    Data = obj.Data;
    Data_Ids = [Data.Id];
    for ii = 1:numel(ID),
        C_wid_found = Data(Data_Ids == ID(ii)); % Keep only the matching ID tags
        C_wid = [C_wid; C_wid_found(:)]; % Returns always a column vector
    end
end
