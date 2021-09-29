% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function update(obj), %#ok
    update_helper(obj, WITio.obj.wit.empty); % Hide use of helper variables from user
    
    function update_helper(obj, Prev), %#ok
        % NameLength (4 bytes)
        obj.NameLength = uint32(numel(obj.NameNow));

        % Reload Data if not loaded yet
        if isempty(obj.DataNow) && obj.HasData, obj.reload(); end

        % Type (4 bytes)
        switch(class(obj.DataNow)), %#ok
            case 'WITio.obj.wit', %#ok % List of Tags
                obj.Type = uint32(0);
            case 'double', %#ok % Double (8 bytes)
                obj.Type = uint32(2);
            case 'single', %#ok % Float (4 bytes)
                obj.Type = uint32(3);
            case 'int64', %#ok % Int64 (8 bytes)
                obj.Type = uint32(4);
            case 'int32', %#ok % Int32 (4 bytes)
                obj.Type = uint32(5);
            case 'uint32', %#ok % Uint32 (4 bytes)
                obj.Type = uint32(6);
            case 'uint16', %#ok % SPECIAL CASE: Uint16 for 'Dates'-tag (2 bytes)
                obj.Type = uint32(6);
            case 'uint8', %#ok % Uint8 (1 byte)
                obj.Type = uint32(7);
            case 'logical', %#ok % Bool (1 byte)
                obj.Type = uint32(8);
            case 'char', %#ok % Char (1 byte)
                obj.Type = uint32(9); % A char array
            otherwise, %#ok
                if iscellstr(obj.DataNow), %#ok
                    obj.Type = uint32(9); % An array of char arrays
                else, %#ok
                    error('Tag(%s): Unsupported Type (%s)!', obj.FullName, class(obj.DataNow));
                end
        end

        % Start (8 bytes)
        obj.Header = uint64(4 + obj.NameLength + 4 + 8 + 8);
        if ~isempty(Prev), %#ok
            obj.Start = Prev.End + obj.Header; % Add offset from Prev-child if child
        elseif ~isempty(obj.ParentNow), %#ok
            obj.Start = obj.ParentNow.Start + obj.Header; % Add offset from Parent if child
        else, %#ok
            obj.Start = 8 + obj.Header; % Add Magic offset if root
        end

        % End (8 bytes)
        switch(obj.Type), %#ok
            case 0, %#ok % List of Tags
                Prev = WITio.obj.wit.empty;
                N_bytes = zeros(numel(obj.DataNow), 1, 'uint64');
                for ii = 1:numel(obj.DataNow), %#ok % Loop the children
                    child_ii = obj.DataNow(ii);
                    update_helper(child_ii, Prev); % Update the child first
                    N_bytes(ii) = child_ii.Header + child_ii.End - child_ii.Start;
                    Prev = child_ii;
                end
                obj.End = obj.Start + sum(N_bytes);
            case 2, %#ok % Double (8 bytes)
                obj.End = obj.Start + uint64(8.*numel(obj.DataNow));
            case 3, %#ok % Float (4 bytes)
                obj.End = obj.Start + uint64(4.*numel(obj.DataNow));
            case 4, %#ok % Int64 (8 bytes)
                obj.End = obj.Start + uint64(8.*numel(obj.DataNow));
            case 5, %#ok % Int32 (4 bytes)
                obj.End = obj.Start + uint64(4.*numel(obj.DataNow));
            case 6, %#ok % Uint32 (4 bytes)
                if isa(obj.DataNow, 'uint32'), obj.End = obj.Start + uint64(4.*numel(obj.DataNow));
                else, obj.End = obj.Start + uint64(2.*numel(obj.DataNow)); end % SPECIAL CASE: Uint16 for 'Dates'-tag (2 bytes)
            case 7, %#ok % Char (1 byte)
                obj.End = obj.Start + uint64(numel(obj.DataNow));
            case 8, %#ok % Bool (1 byte)
                obj.End = obj.Start + uint64(numel(obj.DataNow));
            case 9, %#ok % NameLength (4 bytes) + String (NameLength # of bytes)
                if isempty(obj.DataNow), obj.End = obj.Start; %#ok
                elseif ischar(obj.DataNow), obj.End = obj.Start + uint64(4 + numel(obj.DataNow)); % A char array
                elseif iscell(obj.DataNow), obj.End = obj.Start + uint64(4.*numel(obj.DataNow) + sum(cellfun(@numel, obj.DataNow))); end % An array of char arrays
            otherwise, %#ok
                error('Tag(%s): Unsupported Type (%d)!', obj.FullName, obj.Type);
        end
    end
end
