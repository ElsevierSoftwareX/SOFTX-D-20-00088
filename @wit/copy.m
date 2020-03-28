% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Make hard copy of the wit-tree and its nodes. Please note that the links
% to the root and the parents are destroyed to keep the trees consistent!
function new = copy(obj),
    new = wit.empty; % Return empty if no obj given
    if numel(obj) > 0,
        % Using constructor to automatically reset Root and Parent
%         new(numel(obj)) = wit(); % Causes same-Id-bug when using Octave-compatible NextId-scheme!
        for ii = 1:numel(obj),
            new(ii) = wit(); % Avoids same-Id-bug when using Octave-compatible NextId-scheme!
            new(ii).Name = obj(ii).Name;
            new(ii).NameLength = obj(ii).NameLength;
            new(ii).Type = obj(ii).Type;
            new(ii).Start = obj(ii).Start;
            new(ii).End = obj(ii).End;
            new(ii).Magic = obj(ii).Magic; % Sufficient but not an exact copy
            new(ii).Header = obj(ii).Header;
            new(ii).File = obj(ii).File; % Sufficient but not an exact copy
            
            % But do not copy Parent in order to preserve the tree
            % consistency!
            
            % Test if a data tag or a list of tags
            if ~isa(obj(ii).Data, 'wit'), new(ii).Data = obj(ii).Data; % Data
            else, new(ii).Data = obj(ii).Data.copy(); end % Children
            
            % Finally, update HasData because it is set false when setting empty Data
            new(ii).HasData = obj(ii).HasData;
        end
    end
end
