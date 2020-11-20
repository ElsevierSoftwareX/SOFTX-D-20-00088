% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function update(obj),
    update_helper(obj, WITio.core.wit.empty); % Hide use of helper variables from user
    
    function update_helper(obj, Prev),
        % NameLength (4 bytes)
        obj.NameLength = uint32(numel(obj.Name));

        % Reload Data if not loaded yet
        if isempty(obj.Data) && obj.HasData, obj.reload(); end

        % Type (4 bytes)
        switch(class(obj.Data)),
            case 'WITio.core.wit', % List of Tags
                obj.Type = uint32(0);
            case 'double', % Double (8 bytes)
                obj.Type = uint32(2);
            case 'single', % Float (4 bytes)
                obj.Type = uint32(3);
            case 'int64', % Int64 (8 bytes)
                obj.Type = uint32(4);
            case 'int32', % Int32 (4 bytes)
                obj.Type = uint32(5);
            case 'uint32', % Uint32 (4 bytes)
                obj.Type = uint32(6);
            case 'uint16', % SPECIAL CASE: Uint16 for 'Dates'-tag (2 bytes)
                obj.Type = uint32(6);
            case 'uint8', % Uint8 (1 byte)
                obj.Type = uint32(7);
            case 'logical', % Bool (1 byte)
                obj.Type = uint32(8);
            case 'char', % Char (1 byte)
                obj.Type = uint32(9); % A char array
            otherwise,
                if iscellstr(obj.Data),
                    obj.Type = uint32(9); % An array of char arrays
                else,
                    error('Tag(%s): Unsupported Type (%s)!', obj.FullName, class(obj.Data));
                end
        end

        % Start (8 bytes)
        obj.Header = uint64(4 + obj.NameLength + 4 + 8 + 8);
        if ~isempty(Prev),
            obj.Start = Prev.End + obj.Header; % Add offset from Prev-child if child
        elseif ~isempty(obj.Parent),
            obj.Start = obj.Parent.Start + obj.Header; % Add offset from Parent if child
        else,
            obj.Start = 8 + obj.Header; % Add Magic offset if root
        end

        % End (8 bytes)
        switch(obj.Type),
            case 0, % List of Tags
                Prev = WITio.core.wit.empty;
                N_bytes = zeros(numel(obj.Data), 1, 'uint64');
                for ii = 1:numel(obj.Data), % Loop the children
                    child_ii = obj.Data(ii);
                    update_helper(child_ii, Prev); % Update the child first
                    N_bytes(ii) = child_ii.Header + child_ii.End - child_ii.Start;
                    Prev = child_ii;
                end
                obj.End = obj.Start + sum(N_bytes);
            case 2, % Double (8 bytes)
                obj.End = obj.Start + uint64(8.*numel(obj.Data));
            case 3, % Float (4 bytes)
                obj.End = obj.Start + uint64(4.*numel(obj.Data));
            case 4, % Int64 (8 bytes)
                obj.End = obj.Start + uint64(8.*numel(obj.Data));
            case 5, % Int32 (4 bytes)
                obj.End = obj.Start + uint64(4.*numel(obj.Data));
            case 6, % Uint32 (4 bytes)
                if isa(obj.Data, 'uint32'), obj.End = obj.Start + uint64(4.*numel(obj.Data));
                else, obj.End = obj.Start + uint64(2.*numel(obj.Data)); end % SPECIAL CASE: Uint16 for 'Dates'-tag (2 bytes)
            case 7, % Char (1 byte)
                obj.End = obj.Start + uint64(numel(obj.Data));
            case 8, % Bool (1 byte)
                obj.End = obj.Start + uint64(numel(obj.Data));
            case 9, % NameLength (4 bytes) + String (NameLength # of bytes)
                if isempty(obj.Data), obj.End = obj.Start;
                elseif ischar(obj.Data), obj.End = obj.Start + uint64(4 + numel(obj.Data)); % A char array
                elseif iscell(obj.Data), obj.End = obj.Start + uint64(4.*numel(obj.Data) + sum(cellfun(@numel, obj.Data))); end % An array of char arrays
            otherwise,
                error('Tag(%s): Unsupported Type (%d)!', obj.FullName, obj.Type);
        end
    end
end
