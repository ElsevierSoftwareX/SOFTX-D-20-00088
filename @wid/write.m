% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% CAUTION: When writing multiple objects of multiple Versions to a single
% WID-file, then this MAY produce corrupted files if Versions are
% incompatible with each other!
function write(obj, File) % For saving WIT-formatted WID-files!
    if nargin < 2 || iscell(File), % If no or many filenames specified
        for ii = 1:numel(obj),
            if nargin < 2 || isempty(File{ii}), File{ii} = obj(ii).Tag.Data.File; end
            C_wit = wid.new(wip.get_Root_Version(obj(ii))); % Create minimal data for each object
            if all(isfield(obj(ii).Tag, {'DataClassName', 'Data'})),
                C_wits = [obj(ii).Tag.DataClassName obj(ii).Tag.Data];
            end
            AllLinks = struct2cell(obj(ii).AllLinks);
            for jj = 1:numel(AllLinks), % Also add the linked object such as transformations and interpretations
                if all(isfield(AllLinks{jj}.Tag, {'DataClassName', 'Data'})),
                    C_wits = [C_wits AllLinks{jj}.Tag.DataClassName AllLinks{jj}.Tag.Data];
                end
            end
            C_wit = wip.append(C_wit, unique(C_wits));
            C_wit.write(File{ii});
            C_wit.destroy();
        end
    elseif ischar(File), % If only one filename specified for all, then save all to the same
        Version = wip.get_Root_Version(obj(1));
        if numel(obj) > 0, C_wit = wid.new(Version);
        else, C_wit = wid.new(); end % Create minimal data for all objects
        C_wits = wit.Empty;
        for ii = 1:numel(obj),
            if wip.get_Root_Version(obj(ii)) ~= Version,
                warning('Object with index ii has mismatching Version numbering.', ii);
            end
            if all(isfield(obj(ii).Tag, {'DataClassName', 'Data'})),
                C_wits = [C_wits obj(ii).Tag.DataClassName obj(ii).Tag.Data];
            end
            AllLinks = struct2cell(obj(ii).AllLinks);
            for jj = 1:numel(AllLinks), % Also add the linked object such as transformations and interpretations
                if ~isempty(AllLinks{jj}) && all(isfield(AllLinks{jj}.Tag, {'DataClassName', 'Data'})),
                    C_wits = [C_wits AllLinks{jj}.Tag.DataClassName AllLinks{jj}.Tag.Data];
                end
            end
        end
        C_wit = wip.append(C_wit, unique(C_wits));
        C_wit.write(File);
        C_wit.destroy();
    end
end
