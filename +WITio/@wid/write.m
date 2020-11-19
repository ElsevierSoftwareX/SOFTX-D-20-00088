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
            O_wit = WITio.wid.new(WITio.wip.get_Root_Version(obj(ii))); % Create minimal data for each object
            if all(isfield(obj(ii).Tag, {'DataClassName', 'Data'})),
                O_wits = [obj(ii).Tag.DataClassName obj(ii).Tag.Data];
            end
            AllLinksToOthers = struct2cell(obj(ii).AllLinksToOthers);
            for jj = 1:numel(AllLinksToOthers), % Also add the linked object such as transformations and interpretations
                if all(isfield(AllLinksToOthers{jj}.Tag, {'DataClassName', 'Data'})),
                    O_wits = [O_wits AllLinksToOthers{jj}.Tag.DataClassName AllLinksToOthers{jj}.Tag.Data];
                end
            end
            O_wit = WITio.wip.append(O_wit, unique(O_wits));
            O_wit.write(File{ii});
            delete(O_wit);
        end
    elseif ischar(File), % If only one filename specified for all, then save all to the same
        Version = WITio.wip.get_Root_Version(obj(1));
        if numel(obj) > 0, O_wit = WITio.wid.new(Version);
        else, O_wit = WITio.wid.new(); end % Create minimal data for all objects
        O_wits = WITio.wit.empty;
        for ii = 1:numel(obj),
            if WITio.wip.get_Root_Version(obj(ii)) ~= Version,
                warning('Object with index ii has mismatching Version numbering.', ii);
            end
            if all(isfield(obj(ii).Tag, {'DataClassName', 'Data'})),
                O_wits = [O_wits obj(ii).Tag.DataClassName obj(ii).Tag.Data];
            end
            AllLinksToOthers = struct2cell(obj(ii).AllLinksToOthers);
            for jj = 1:numel(AllLinksToOthers), % Also add the linked object such as transformations and interpretations
                if ~isempty(AllLinksToOthers{jj}) && all(isfield(AllLinksToOthers{jj}.Tag, {'DataClassName', 'Data'})),
                    O_wits = [O_wits AllLinksToOthers{jj}.Tag.DataClassName AllLinksToOthers{jj}.Tag.Data];
                end
            end
        end
        O_wit = WITio.wip.append(O_wit, unique(O_wits));
        O_wit.write(File);
        delete(O_wit);
    end
end
