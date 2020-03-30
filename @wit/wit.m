% BSD 3-Clause License
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% * Redistributions of source code must retain the above copyright notice, this
%   list of conditions and the following disclaimer.
% 
% * Redistributions in binary form must reproduce the above copyright notice,
%   this list of conditions and the following disclaimer in the documentation
%   and/or other materials provided with the distribution.
% 
% * Neither the name of Aalto University nor the names of its
%   contributors may be used to endorse or promote products derived from
%   this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

% Class for tree tags
classdef wit < handle, % Since R2008a and Octave-compatible
    %% MAIN PROPERTIES
    properties (SetAccess = private) % READ-ONLY
        File = '';
    end
    
    % Main file-format parameters
    properties % READ-WRITE
        Name = '';
        Data; % = wit.empty; % latter is Octave-incompatible!
    end
    properties (SetAccess = private) % READ-ONLY
        Type = uint32(0); % Always updated before writing!
    end
    
    %% OTHER PROPERTIES
    % References to other relevant tags
    properties % READ-WRITE
        Parent; % = wit.empty; % latter is Octave-incompatible!
    end
    properties (Dependent) % READ-WRITE, DEPENDENT
        % Dependent on Data
        Children;
        % Dependent on Parent
        Root;
        Siblings;
        Next; % Next sibling
        Prev; % Previous sibling
    end
    properties (SetAccess = private, Dependent) % READ-ONLY, DEPENDENT
        % Dependent on Name and Parent
        FullName;
    end
    
    % File-specific parameters
    properties % READ-WRITE
        % Accepts only fixed-length (8 bytes) char array as magic string, used in the beginning of the file
        Magic = 'WIT_TREE'; % Only the root value is used!
    end
    properties (SetAccess = private) % READ-ONLY
        % Other file-format parameters
        NameLength = uint32(0); % Always updated before writing!
        Start = uint64(0); % Always updated before writing!
        End = uint64(0); % Always updated before writing!
        % Helper parameters
        Header = uint64(0); % Always updated before writing!
        HasData = false; % Useful flag for the reloading cases
    end
    
    % Handle-specific internal parameters
    properties (SetAccess = private) % READ-ONLY
        Id = uint64(0); % Used internally enable handle-like comparison in Octave
    end
    
    % Class-specific internal parameters
    properties (SetAccess = private, Hidden) % READ-ONLY
        skipRedundant = false; % Used internally to speed-up set.Data and set.Parent
    end
    
    %% PUBLIC METHODS
    methods
        % CONSTRUCTOR
        function obj = wit(ParentOrName, NameOrData, DataOrNone),
            % Store object Id in order to enable handle-like comparisons
            persistent NextId;
            if isempty(NextId), NextId = uint64(1);
            else, NextId = NextId + 1; end
            obj.Id = NextId;
            
            % Set empty objects to Data and Parent in Octave-compatible way
            empty_obj = obj([]); % Octave-compatible way to construct empty array of objects
            obj.Data = empty_obj; % Avoiding wit.empty due to infinite loop
            obj.Parent = empty_obj; % Avoiding wit.empty due to infinite loop
            
            % Parse input
            if nargin > 0,
                if isa(ParentOrName, 'wit'), % Set new Parent
                    obj.Parent = ParentOrName;
                elseif isa(ParentOrName, 'char'), % Set new Name
                    if nargin > 2, error('Too many input arguments.'); end
                    obj.Name = ParentOrName;
                else, error('First input must be either wit-class or char!'); end
            end
            if nargin > 1,
                if isa(ParentOrName, 'wit'), % After new Parent
                    if isa(NameOrData, 'char'), % Set new Name
                        obj.Name = NameOrData;
                        if nargin > 2, obj.Data = DataOrNone; end % Set new Data
                    else, error('If first input is wit-class, then second must be char!'); end
                else, obj.Data = NameOrData; end % After new Name set new Data
            end
        end
        
        function delete(obj), % Delete tag and all its contents (including its children)
            % Disconnect parent and all descendants from each other and
            % delete this and its descendants permanently. Although this
            % uses recursion, it is unlikely to become a problem within the
            % WIT-tag formatted files.
            persistent skipRedundant;
            if isempty(skipRedundant), skipRedundant = false; end
            % If called from delete, then skip all redundant code
            if ~skipRedundant,
                obj.Parent = wit.empty; % Disconnect parent (only for the first)
                % Delete descendants
                skipRedundant = true; % Speed-up next delete-calls
                Descendants = obj.Children;
                while ~isempty(Descendants),
                    NextDescendants = [Descendants.Children];
                    delete(Descendants);
                    Descendants = NextDescendants;
                end
                skipRedundant = false;
            end
            % Useful resources:
            % https://se.mathworks.com/help/matlab/matlab_oop/handle-class-destructors.html
            % https://se.mathworks.com/help/matlab/matlab_oop/example-implementing-linked-lists.html
            % https://blogs.mathworks.com/loren/2013/07/23/deconstructing-destructors/
        end
        
        
        
        %% MAIN PROPERTIES
        % File (READ-ONLY)
        function File = get.File(obj),
            % Inherit this property from the root when not specified
            if ~isempty(obj.File), File = obj.File; % If available, obtain it from this
            else, File = obj.Root.File; end % Otherwise, obtain it from the root
        end
        
        % Name (READ-WRITE)
        function set.Name(obj, Name),
            % Validate the given input
            if ischar(Name), obj.Name = reshape(Name, 1, []);
            else, error('Only a char array can be a name!'); end
        end
        
        % Data (READ-WRITE)
        function set.Data(obj, Data),
            if ~isa(Data, 'wit'), % GENERAL CASE: Add new data to the obj
                obj.Data = Data;
            else, % SPECIAL CASE: Add new children to the obj
                % If called from set.Parent, then skip all redundant code
                if obj.skipRedundant, % Speed-up and avoid infinite recursive loop
                    obj.skipRedundant = false; % Toggle the flag
                else,
                    % Error if the new children are not unique
                    for ii = 1:numel(Data),
                        if any(Data(ii) == Data(ii+1:end)),
                            error('A parent can adopt a child only once! A duplicate was found at index %d!', ii);
                        end
                    end
                    % Error if a loop is being created
                    Ancestor = obj;
                    while ~isempty(Ancestor),
                        if any(Ancestor == Data),
                            error('Loops cannot be created with wit tree objects!');
                        end
                        Ancestor = Ancestor.Parent;
                    end
                    % Remove parent of those old children that are not found among the new children
                    Data_old = obj.Data;
                    if isa(Data_old, 'wit'),
                        for ii = 1:numel(Data_old),
                            % Remove parent of an old child if it is not found among the new children
                            if all(Data_old(ii) ~= Data),
                                Data_old(ii).skipRedundant = true; % Speed-up and avoid infinite recursive loop
                                Data_old(ii).Parent = wit.empty;
                            end
                        end
                    end
                    % Set parent
                    for ii = 1:numel(Data),
                        Data(ii).skipRedundant = true; % Speed-up and avoid infinite recursive loop
                        Data(ii).Parent = obj;
                    end
                end
                % Parent the new children
                obj.Data = reshape(Data, 1, []);
            end
            % Update HasData-flag
            obj.HasData = ~isempty(Data);
        end
        
        % Type (READ-ONLY)
        
        %% OTHER PROPERTIES
        % Parent (READ-WRITE)
        function set.Parent(obj, Parent),
            % If called from set.Data, then skip all redundant code
            if obj.skipRedundant, % Speed-up and avoid infinite recursive loop
                obj.skipRedundant = false; % Toggle the flag
            else,
                % Validate the given input
                if ~isa(Parent, 'wit') || numel(Parent) > 1,
                    error('Parent can be set by either an empty or a single wit tree object!');
                end
                % Get old parent
                Parent_old = obj.Parent;
                % Stop if both old and new parents are empty
                if isempty(Parent) && isempty(Parent_old),
                    if ~isa(Parent_old, 'wit'),
                        obj.Parent = Parent;
                    end
                    return;
                end
                % Stop if both old and new parents are same
                if ~isempty(Parent) && ~isempty(Parent_old) && Parent == Parent_old,
                    return;
                end
                % Error if a loop is being created
                Ancestor = Parent;
                while ~isempty(Ancestor),
                    if Ancestor == obj,
                        error('Loops cannot be created with wit tree objects!');
                    end
                    Ancestor = Ancestor.Parent;
                end
                % Adopt this object by the new non-empty parent
                if ~isempty(Parent),
                    Parent.skipRedundant = true; % Speed-up and avoid infinite recursive loop
                    Parent.Data = [Parent.Children obj];
                end
                % Remove this object from the old non-empty parent
                if ~isempty(Parent_old),
                    Parent_old.skipRedundant = true; % Speed-up and avoid infinite recursive loop
                    Parent_old.Data = Parent_old.Data(Parent_old.Data ~= obj);
                end
            end
            % If this object becomes a root, then inherit the old root's key properties
            if isempty(Parent),
                obj.File = obj.File; % Inherit the file string from this or the old root
                obj.Magic = obj.Magic; % Inherit the magic string from the old root
            end
            % Set the new parent
            obj.Parent = Parent;
        end
        
        % Children (READ-WRITE, DEPENDENT)
        function Children = get.Children(obj),
            Children = wit.empty;
            if isa(obj.Data, 'wit'), Children = obj.Data; end
        end
        function set.Children(obj, Children),
            % Validate the given input
            if ~isa(Children, 'wit'),
                error('Children can be set an array of wit tree objects!');
            end
            obj.Data = Children; % Try to update this object children
        end
        
        % Root (READ-WRITE, DEPENDENT)
        function Root = get.Root(obj),
            Root = obj;
            while ~isempty(Root.Parent), Root = Root.Parent; end
        end
        function set.Root(obj, Root),
            % Validate the given input
            if ~isa(Root, 'wit') && numel(Root) ~= 1,
                error('Root can be set by a single wit tree object!');
            end
            Root.Data = obj.Root.Data; % Transfer data (that may be children) of the old root to the new root
        end
        
        % Siblings (READ-WRITE, DEPENDENT)
        function Siblings = get.Siblings(obj),
            Siblings = wit.empty;
            if ~isempty(obj.Parent),
                Siblings = obj.Parent.Data; % Including itself
                Siblings = Siblings(Siblings ~= obj); % Exclude itself
            end
        end
        function set.Siblings(obj, Siblings),
            % Validate the given input
            if ~isa(Siblings, 'wit'),
                error('Siblings can be set by an array of wit tree objects! It can optionally include the main object to choose its position within its new siblings. Otherwise, the main object will be first!');
            end
            ind = find(Siblings == obj, 1); % Get index of this object
            if isempty(ind), Siblings = [obj Siblings]; end % SPECIAL CASE: Make this object first if its position was not chosen
            obj.Parent.Data = Siblings; % Try to update parent children
        end
        
        % Next (READ-WRITE, DEPENDENT)
        function Next = get.Next(obj),
            Next = wit.empty;
            if ~isempty(obj.Parent),
                Siblings = obj.Parent.Data; % Including itself
                ind_Next = find(Siblings == obj, 1) + 1;
                if ind_Next <= numel(Siblings), Next = Siblings(ind_Next); end
            end
        end
        function set.Next(obj, Next),
            % Validate the given input
            if ~isa(Next, 'wit'),
                error('Next can be set by an array of wit tree objects!');
            end
            Children = obj.Parent.Data; % Get parent children
            ind = find(Children == obj, 1); % Get index of this object
            Children = [Children(1:ind) reshape(Next, 1, [])]; % Keep the previous siblings and replace the next siblings
            obj.Parent.Data = Children; % Try to update parent children
        end
        
        % Prev (READ-WRITE, DEPENDENT)
        function Prev = get.Prev(obj),
            Prev = wit.empty;
            if ~isempty(obj.Parent),
                Siblings = obj.Parent.Data; % Including itself
                ind_Prev = find(Siblings == obj, 1) - 1;
                if ind_Prev >= 1, Prev = Siblings(ind_Prev); end
            end
        end
        function set.Prev(obj, Prev),
            % Validate the given input
            if ~isa(Prev, 'wit'),
                error('Prev can be set by an array of wit tree objects! Its content will be added in reversed order.');
            end
            Children = obj.Parent.Data; % Get parent children
            ind = find(Children == obj, 1); % Get index of this object
            Children = [fliplr(reshape(Prev, 1, [])) Children(ind:end)]; % Keep the next siblings and replace the previous siblings
            obj.Parent.Data = Children; % Try to update parent children
        end
        
        % FullName (READ-ONLY, DEPENDENT)
        function FullName = get.FullName(obj), % Potential bottleneck!
            FullName = obj.Name;
            while ~isempty(obj.Parent),
                FullName = [FullName '<' obj.Parent.Name];
                obj = obj.Parent;
            end
        end
        
        % Magic (READ-WRITE)
        function Magic = get.Magic(obj),
            % Always inherit this property from the root (that may be this)
            Magic = obj.Root.Magic;
        end
        function set.Magic(obj, Magic),
            % Validate the given input and modify this property from the root
            if ischar(Magic) && numel(Magic) == 8, obj.Root.Magic = reshape(Magic, 1, []);
            else, error('Only an 8-bytes-long char array can be a magic string!'); end
        end
        
        % NameLength (READ-ONLY)
        
        % Start (READ-ONLY)
        
        % End (READ-ONLY)
        
        % Header (READ-ONLY)
        
        % HasData (READ-ONLY)
        
        % Id (READ-ONLY)
        
        
        
        %% METHODS
%         % Define Octave-compatible handle-like eq, ne, lt, le, gt and ge:
%         % https://se.mathworks.com/help/matlab/ref/handle.relationaloperators.html
%         function tf = compare(O1, O2, fun, default),
%             if numel(O1) == 1 || numel(O2) == 1 || ... % Either O1 or O2 is scalar
%                     ndims(O1) == ndims(O2) && all(size(O1) == size(O2)), % Or size(O1) == size(O2)
%                 if isa(O2, 'wit'), tf = fun(reshape([O1.Id], size(O1)), reshape([O2.Id], size(O2)));
%                 elseif numel(O1) == 1, tf = repmat(default, size(O2));
%                 else, tf = repmat(default, size(O1)); end
%             else, error('Matrix dimensions must agree.'); end
%         end
%         function tf = eq(O1, O2), tf = O1.compare(O2, @eq, false); end % Equal
%         function tf = ne(O1, O2), tf = O1.compare(O2, @ne, true); end % Not equal
%         function tf = lt(O1, O2), tf = O1.compare(O2, @lt, false); end % Less than
%         function tf = le(O1, O2), tf = O1.compare(O2, @le, false); end % Less than or equal
%         function tf = gt(O1, O2), tf = O1.compare(O2, @gt, false); end % Greater than
%         function tf = ge(O1, O2), tf = O1.compare(O2, @ge, false); end % Greater than or equal
%         
%         % Define horzcat, vertcat, reshape missing in Octave
%         function obj = horzcat(varargin), % Enables [O1 O2 ...]
%             if ~is_octave(), obj = builtin('horzcat', varargin{:}); % MATLAB-way
%             else, % Octave-way
%                 obj = wit.empty;
%                 varargin = varargin(~cellfun(@isempty, varargin)); % Skip empty
%                 if ~isempty(varargin),
%                     D = max(cellfun(@ndims, varargin)); % Number of dimensions
%                     obj = varargin{1}; % Get the 1st non-empty object array
%                     [S{1:D}] = size(obj); % and its size
%                     for ii = 2:numel(varargin),
%                         obj_ii = varargin{ii}; % Get the ii'th non-empty object array
%                         [S_ii{1:D}] = size(obj_ii); % and its size
%                         if any([S{[1 3:D]}] ~= [S_ii{[1 3:D]}]), % Test if the sizes are compatible
%                             error('Dimensions of arrays being concatenated are not consistent.');
%                         end
%                         obj(end+1:end+numel(obj_ii)) = obj_ii; % Append to the 1st non-empty object array
%                     end
%                     obj = reshape(obj, S{1}, [], S{3:D}); % Restore the shape accordingly
%                 end
%             end
%         end
%         function obj = vertcat(varargin), % Enables [O1; O2; ...]
%             if ~is_octave(), obj = builtin('vertcat', varargin{:}); % MATLAB-way
%             else, % Octave-way
%                 obj = wit.empty;
%                 varargin = varargin(~cellfun(@isempty, varargin)); % Skip empty
%                 if ~isempty(varargin),
%                     D = max(cellfun(@ndims, varargin)); % Number of dimensions
%                     obj = varargin{1}; % Get the 1st non-empty object array
%                     [S{1:D}] = size(obj); % and its size
%                     for ii = 2:numel(varargin),
%                         obj_ii = varargin{ii}; % Get the ii'th non-empty object array
%                         [S_ii{1:D}] = size(obj_ii); % and its size
%                         if any([S{2:D}] ~= [S_ii{2:D}]), % Test if the sizes are compatible
%                             error('Dimensions of arrays being concatenated are not consistent.');
%                         end
%                         obj(end+1:end+numel(obj_ii)) = obj_ii; % Append to the 1st non-empty object array
%                     end
%                     obj = reshape(obj, [], S{2:D}); % Restore the shape accordingly
%                 end
%             end
%         end
%         function obj = reshape(obj, varargin), % Enables object array reshaping
%             if ~is_octave(), obj = builtin('reshape', obj, varargin{:}); % MATLAB-way
%             else, obj = obj(reshape(1:numel(obj), varargin{:})); end % Octave-way
%         end
        
        
        
        %% OTHER METHODS
        % Object copying, destroying, writing, reloading
        new = copy(obj); % Copy obj
        destroy(obj); % Delete obj
        write(obj, File); % Write obj to file
        update(obj); % Update file format header information
        reload(obj); % Reload obj.Data from file
        
        % Add/remove children
        add(obj, varargin);
        remove(obj, varargin);
        adopt(obj, varargin); % Deprecated! Use add instead!
        
        % Conversion to/from binary form
        buffer = binary(obj, swapEndianess);
        ind_begin = binaryread(obj, buffer, ind_begin, N_bytes_max, swapEndianess, skip_Data_criteria_for_obj, error_criteria_for_obj);
        ind_begin = binaryread_Data(obj, buffer, N_bytes_max, swapEndianess);
        
        % Object search
        tags = regexp(obj, pattern, FirstOnly, LayersFurther, PrevFullNames);
        tags = search(obj, varargin);
        tags = regexp_ancestors(obj, pattern, FirstOnly, LayersFurther);
        tags = search_ancestors(obj, varargin);
        tags = match_by_Data_criteria(obj, test_fun);
        
        % Object debugging
        S = collapse(obj);
    end
    
    %% STATIC METHODS
    methods (Static)
        % Read file to obj
        obj = read(File, N_bytes_max, skip_Data_criteria_for_obj, error_criteria_for_obj);
        
        % Getters and setters for (un)formatted DataTree, also for debugging
        DataTree_set(parent, in, format); % For (un)formatted structs
        out = DataTree_get(parent, format); % For (un)formatted structs
        
        % Define Octave-compatible empty-function
        function empty = empty(),
            persistent empty_obj;
            if ~isa(empty_obj, 'wit'), % Do only once to achieve best performance
                dummy_obj = wit(); % Create a dummy wit-class
                empty_obj = dummy_obj([]); % Octave-compatible way to construct empty array of objects
                delete(dummy_obj); % Delete the dummy wit-class
            end
            empty = empty_obj;
        end
    end
    
    %% PRIVATE METHODS
    methods (Access = private)
        fwrite(obj, fid, swapEndianess);
        fread(obj, fid, N_bytes_max, swapEndianess, skip_Data_criteria_for_obj, error_criteria_for_obj);
        fread_Data(obj, fid, N_bytes_max, swapEndianess);
    end
end
