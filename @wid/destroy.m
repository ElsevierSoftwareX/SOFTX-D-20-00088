% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function destroy(obj)
    for ii = 1:numel(obj),
        if ~obj(ii).isvalid, continue; end % Skip deleted
        ON_ii = obj(ii).OrdinalNumber;
        Project_ii = obj(ii).Project; % Get project object
        if ~isempty(Project_ii),
            Data_ii = Project_ii.Data; % Get project data objects
            Project_ii.Data = Data_ii(Data_ii ~= obj(ii)); % Save without this data object
            for jj = 1:numel(Data_ii), % Update the ordinal numberings
                ON_jj = Data_ii(jj).OrdinalNumber;
                if ON_jj > ON_ii, Data_ii(jj).OrdinalNumber = ON_jj - 1; end
            end
        end
        Tag_ii = obj(ii).Tag; % Get tag struct
        if ~isempty(Tag_ii),
            Tag_NV = Tag_ii.Data.Parent.search('NumberOfData', 'Data');
            Tag_NV.Data = Tag_NV.Data - 1; % Reduce the number by one
            destroy([Tag_ii.DataClassName Tag_ii.Data]); % Destroy all related tags
        end
    end
    delete(obj); % Delete the object handles
end
