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
classdef wit < handle, % Since R2008a
    % This class becomes Octave-compatible (except for events) by
    % uncommenting the related code segments. This compatibility has been
    % disabled for best performance with big datas.
    %% MAIN EVENTS (not used internally to preserve Octave-compatibility)
    events (ListenAccess = private, NotifyAccess = private) % May be subject to change in some future release if full Octave-compatibility is pursued!
        % ObjectBeingDestroyed; % Automatically defined by the handle class
        ObjectModified;
    end
    
    %% MAIN PROPERTIES
    properties (SetAccess = private) % READ-ONLY
        File = '';
    end
    
    % Main file-format parameters
    properties (Dependent) % READ-WRITE, DEPENDENT
        Name; % Rely on internal NameNow
        Data; % Rely on internal DataNow
    end
    properties (SetAccess = private) % READ-ONLY
        Type = uint32(2); % Always updated before writing!
    end
    
    %% OTHER PROPERTIES
    % References to other relevant tags
    properties (Dependent) % READ-WRITE, DEPENDENT
        Parent; % Rely on internal ParentNow
        % Dependent on Data
        Children; % Rely on internal ChildrenNow
        % Dependent on Parent
        Root; % Rely on internal RootNow
        Siblings;
        Next; % Next sibling
        Prev; % Previous sibling
    end
    properties (SetAccess = private, Dependent) % READ-ONLY, DEPENDENT
        % Dependent on Name and Parent
        FullName; % Rely on internal FullNameNow
    end
    
    % File-specific parameters
    properties % READ-WRITE
        % Accepts only fixed-length (8 bytes) char array as magic string, used in the beginning of the file
        Magic = 'WIT_TREE'; % Only the root value is used!
    end
    properties (SetAccess = private, Hidden) % READ-ONLY
        % Other file-format parameters
        NameLength = uint32(0); % Always updated before writing!
        Start = uint64(0); % Always updated before writing!
        End = uint64(0); % Always updated before writing!
        % Helper parameters
        Header = uint64(0); % Always updated before writing!
        HasData = false; % Useful flag for the reloading cases
    end
    
    % Internal parameters for maximum performance due to use of big datas
    properties (SetAccess = private, Hidden) % READ-ONLY
        NameNow = '';
        % Update the following along with OrdinalNumber-property!
        DataNow = [];
        ParentNow = []; % = wit.empty; % Only [] is Octave-compatible!
        ChildrenNow = []; % = wit.empty; % Only [] is Octave-compatible!
    end
    
    % Tree-specific internal parameters
    properties (SetAccess = private) % READ-ONLY
        Listeners = {}; % Storage of all listeners attached to this object
        % ModifiedCount is incremented once per successful set.Name,
        % set.Data or set.Parent for each affected object. By default, when
        % obj.ModifiedAncestors == true, then also the ancestors are
        % updated as well.
        ModifiedCount = 0; % Number of modifications % Use of double is faster than uint64
        ModifiedDescendantProperty = ''; % 'Name', 'Data', 'Children' or 'Parent'
        ModifiedDescendantMeta; % Empty unless obj.ModifiedDescendantProperty is 'Children'
        ModifiedDescendantIndices = []; % Related to OrdinalNumber-property
        ModifiedDescendantIds = []; % Related to Id-property
    end
    properties (SetAccess = private, Hidden) % READ-ONLY
        % modification optimizations
        ModifiedAncestors = true;
        ModifiedEvents = false; % Used for optimizations and is automatically set true when addlistener is called with 'ObjectModified'
        % get.Root optimizations
        RootNow;
        RootModifiedCount = 0;
        % get.FullName optimizations
        FullNameNow;
        FullName_RootNow;
        FullName_RootModifiedCount = 0;
    end
    
    % Handle-specific internal parameters
    properties (SetAccess = private) % READ-ONLY
        % Use of double is faster than uint64
        % ChildrenIdToOrdinalNumber = spalloc(0, 1, 0); % Sparse map from Id to OrdinalNumber
        OrdinalNumber = 1; % Array index among its Parent's Children
        Id = 0; % Used internally to enable handle-like comparison in Octave
    end
    properties (SetAccess = private, Hidden) % READ-ONLY
        IsValid = true; % Used internally to mark object invalid and that it should be deleted
    end
    
    %% PUBLIC METHODS
    methods
        % CONSTRUCTOR
        function obj = wit(ParentOrName, NameOrData, DataOrNone),
            % Store object Id in order to enable handle-like comparisons
            persistent NextId;
            if isempty(NextId), NextId = 1; % Use of double is faster than uint64
            else, NextId = NextId + 1; end
            obj.Id = NextId;
            
            % Parse input
            if nargin > 0,
                if isa(ParentOrName, 'wit'), % Set new Parent
                    obj.ModifiedAncestors = ParentOrName.ModifiedAncestors; % Inherit this property from parent
                    obj.Parent = ParentOrName;
                elseif isa(ParentOrName, 'char'), % Set new Name
                    if nargin > 2, error('Too many input arguments.'); end
                    obj.Name = ParentOrName;
                else, error('First input must be either wit-class or char!'); end
                if nargin > 1,
                    if isa(ParentOrName, 'wit'), % After new Parent
                        if isa(NameOrData, 'char'), % Set new Name
                            obj.Name = NameOrData;
                            if nargin > 2, obj.Data = DataOrNone; end % Set new Data
                        else, error('If first input is wit-class, then second must be char!'); end
                    else, obj.Data = NameOrData; end % After new Name set new Data
                end
            end
        end
        
        function delete(obj), % Delete tag and all its contents (including its children)
            % Disconnect parent and all descendants from each other and
            % delete this and its descendants permanently. Although this
            % uses recursion, it is unlikely to become a problem within the
            % WIT-tag formatted files.
            persistent subdelete;
            if isempty(subdelete), subdelete = false; end
            % If called from within delete, then skip all redundant code
            if subdelete,
                delete(obj.Children);
            else,
                obj.Parent = wit.empty; % Disconnect parent (only for the first)
                % Delete descendants
                subdelete = true; % Speed-up next delete-calls
                delete(obj.Children);
                subdelete = false;
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
        
        % Name (READ-WRITE, DEPENDENT) % Changes counted by ModifiedCount-property!
        function Name = get.Name(obj),
            Name = obj.NameNow;
        end
        function set.Name(obj, Name),
            if ischar(Name), % Validate the given input
                obj.NameNow = reshape(Name, 1, []);
                % Update obj's ModifiedCount and notify its ancestors
                obj.modification('Name');
            else,
                error('Only a char array can be a name!');
            end
        end
        
        % Data (READ-WRITE, DEPENDENT) % Changes counted by ModifiedCount-property!
        function Data = get.Data(obj),
            Data = obj.DataNow;
        end
        function set.Data(obj, Data),
            if ~isa(Data, 'wit'), % GENERAL CASE: Add new data to the obj
                obj.DataNow = Data;
                obj.ChildrenNow = wit.empty;
                % Update HasData-flag
                obj.HasData = ~isempty(Data);
                % Update obj's ModifiedCount and notify its ancestors
                obj.modification('Data');
            else, % SPECIAL CASE: Add new children to the obj
                Data_old = obj.ChildrenNow;
                if isempty(Data_old), Data_old_Id = [];
                else, Data_old_Id = [Data_old.Id]; end % Load once
                ones_old = ones(size(Data_old_Id));
                % Get new and old Children Ids
                Data_Id = [Data.Id]; % Load once
                ones_new = ones(size(Data_Id));
                % Get maximum Id
                max_Id = max([max(Data_Id) max(Data_old_Id) 1]);
                % Error if the new children are not unique
                sparse_count_new_Ids = sparse(Data_Id, ones_new, ones_new, max_Id, 1); % Use sparse vectors that are fast and suitable for big datas
                B_duplicates = sparse_count_new_Ids > 1;
                if any(B_duplicates),
                    error('A parent can adopt a child only once! A duplicate was found at index %d!', find(B_duplicates));
                end
                % Error if a loop is being created
                Ancestor = obj;
                while ~isempty(Ancestor),
                    Ancestor_Id = Ancestor.Id;
                    if Ancestor_Id <= max_Id && sparse_count_new_Ids(Ancestor_Id) > 0, % Same as Ancestor == Data but Octave-compatible way
                        error('Loops cannot be created with wit tree objects!');
                    end
                    Ancestor = Ancestor.ParentNow;
                end
                % Remove parent of those old children that are not found among the new children
                sparse_count_old_Ids = sparse(Data_old_Id, ones_old, ones_old, max_Id, 1); % Use sparse vectors that are fast and suitable for big datas
                B_old_at_new = sparse_count_new_Ids(Data_old_Id) > 0;
                B_new_at_old = sparse_count_old_Ids(Data_Id) > 0;
                for ii = 1:numel(Data_old),
                    % Remove parent of an old child if it is not found among the new children
                    if B_old_at_new(ii), continue; end % Skip if among new
                    Data_old(ii).ParentNow = wit.empty;
                    Data_old(ii).OrdinalNumber = 1;
                    % Update old child's ModifiedCount but do not notify its ancestors
                    Data_old(ii).ModifiedAncestors = false;
                    Data_old(ii).modification('Parent');
                    Data_old(ii).ModifiedAncestors = true;
                end
                % Collect old parents and OrdinalNumbers
                N_Data = numel(Data);
                OD_old = ones(size(Data));
                Parent_old = cell(size(Data));
                Parent_old_Id = zeros(size(Data));
                for ii = 1:N_Data,
                    OD_old(ii) = Data(ii).OrdinalNumber;
                    Parent_old{ii} = Data(ii).ParentNow;
                    if ~isempty(Parent_old{ii}), Parent_old_Id(ii) = Parent_old{ii}.Id; end
                end
                [Parent_old_Id_unique, ind_unique, ind_Parent_old_unique] = unique(Parent_old_Id); % Store unique old Parents
                if N_Data > 0 && Parent_old_Id_unique(1) == 0,
                    ind_unique = ind_unique(2:end); % Discard zero Id
                    ind_Parent_old_unique = ind_Parent_old_unique - 1; % Shift due to discarding zero Id
                end
                Parent_old_unique = [Parent_old{ind_unique}];
                % Set new parent
                for ii = 1:N_Data,
                    Data(ii).OrdinalNumber = ii;
                    if B_new_at_old(ii), continue; end % Skip if already parented
                    Data(ii).ParentNow = obj;
                    % Update new child's ModifiedCount but do not notify its ancestors
                    Data(ii).ModifiedAncestors = false;
                    Data(ii).modification('Parent');
                    Data(ii).ModifiedAncestors = true;
                end
                % Remove old Parent's transferred children and update all OrdinalNumbers
                for ii = 1:numel(Parent_old_unique),
                    Parent_old = Parent_old_unique(ii);
                    B_transferred = ind_Parent_old_unique == ii;
                    B_old = true(size(Parent_old.DataNow));
                    B_old(OD_old(B_transferred)) = false;
                    Children_old = Parent_old.DataNow(B_old);
                    Parent_old.DataNow = Children_old;
                    Parent_old.ChildrenNow = Children_old;
                    for jj = 1:numel(Children_old),
                        Children_old(jj).OrdinalNumber = jj;
                    end
                    % Update old parent's ModifiedCount and notify its ancestors
                    meta = {'added Ids', []; 'removed Ids', Data_Id(B_transferred)}; % Meta of added and removed Ids
                    Parent_old.modification('Children', meta);
                end
                % Parent the new children
                Children(1:N_Data) = Data; % Octave-compatible way to generate a row vector of wit objects
                obj.DataNow = Children;
                obj.ChildrenNow = Children;
                % Update HasData-flag
                obj.HasData = ~isempty(Children);
                % Update obj's ModifiedCount and notify its ancestors
                meta = {'added Ids', Data_Id(~B_new_at_old); 'removed Ids', Data_old_Id(~B_old_at_new)}; % Meta of added and removed Ids
                obj.modification('Children', meta);
            end
        end
        
        % Type (READ-ONLY)
        
        %% OTHER PROPERTIES
        % Parent (READ-WRITE, DEPENDENT) % Changes counted by ModifiedCount-property!
        function Parent = get.Parent(obj),
            Parent = obj.ParentNow;
        end
        function set.Parent(obj, Parent),
            % If called from set.Data, then skip all redundant code
            % Validate the given input
            if ~isa(Parent, 'wit') || numel(Parent) > 1,
                error('Parent can be set by either an empty or a single wit tree object!');
            end
            % Get old parent
            Parent_old = obj.ParentNow;
            % Stop if both old and new parents are empty
            if isempty(Parent) && isempty(Parent_old),
                if ~isa(Parent_old, 'wit'),
                    obj.ParentNow = Parent;
                end
                return;
            end
            % Stop if both old and new parents are same
            if ~isempty(Parent) && ~isempty(Parent_old) && Parent.Id == Parent_old.Id, % Same as Parent == Parent_old but Octave-compatible way
                return;
            end
            % Error if a loop is being created
            Ancestor = Parent;
            obj_Id = obj.Id; % Load once
            while ~isempty(Ancestor),
                if Ancestor.Id == obj_Id, % Same as Ancestor == obj but Octave-compatible way
                    error('Loops cannot be created with wit tree objects!');
                end
                Ancestor = Ancestor.ParentNow;
            end
            % Adopt this object by the new non-empty parent
            if ~isempty(Parent),
                if isempty(Parent.ChildrenNow), Parent.ChildrenNow = obj;
                else, Parent.ChildrenNow(end+1) = obj; end % Octave-compatible way
                Parent.DataNow = Parent.ChildrenNow;
                obj.OrdinalNumber = numel(Parent.ChildrenNow);
            end
            % Remove this object from the old non-empty parent
            if ~isempty(Parent_old),
                B_obj = Parent_old.DataNow == obj;
                ind_obj = find(B_obj, 1);
                Children_old = Parent_old.DataNow(~B_obj);
                Parent_old.DataNow = Children_old;
                Parent_old.ChildrenNow = Children_old;
                for ii = ind_obj:numel(Children_old),
                    Children_old(ii).OrdinalNumber = ii;
                end
                % Update old parent's ModifiedCount and notify its ancestors
                meta = {'added Ids', []; 'removed Ids', obj_Id}; % Meta of added and removed Ids
                Parent_old.modification('Children', meta);
            end
            % If this object becomes a root, then inherit the old root's key properties
            if isempty(Parent) && ~isempty(obj.ParentNow),
                obj.File = obj.File; % Inherit the file string from this or the old root
                obj.Magic = obj.Magic; % Inherit the magic string from the old root
            end
            % Set the new parent
            obj.ParentNow = Parent;
            % Update obj's ModifiedCount and notify its ancestors
            obj.modification('Parent');
        end
        
        % Children (READ-WRITE, DEPENDENT)
        function Children = get.Children(obj),
            Children = obj.ChildrenNow;
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
            Root = obj.RootNow;
            % Update returned and stored Root if any change is detected
            if isempty(Root) || ...
                    obj.RootModifiedCount ~= Root.ModifiedCount && ~strcmp(Root.ModifiedDescendantProperty, 'Name'),
                % Find new Root
                Root = obj;
                while ~isempty(Root.ParentNow), Root = Root.ParentNow; end
                % Update the related modification tracking variables
                obj.RootModifiedCount = Root.ModifiedCount;
                % Update stored Root
                obj.RootNow = Root;
            end
        end
        function set.Root(obj, Root),
            % Validate the given input
            if ~isa(Root, 'wit') && numel(Root) ~= 1,
                error('Root can be set by a single wit tree object!');
            end
            OldRoot = obj.Root; % Call get.Root only once
            if OldRoot == obj, % SPECIAL CASE: This object is its own root
                Root.Data = obj; % Make the old root (or this object) the only child of the new root
            else, % Otherwise, disconnect the old root by transfering its contents to the new root
                Root.Data = OldRoot.DataNow; % Transfer children from the old root to the new root
            end
        end
        
        % Siblings (READ-WRITE, DEPENDENT)
        function Siblings = get.Siblings(obj),
            Siblings = wit.empty;
            if ~isempty(obj.ParentNow),
                Siblings = obj.ParentNow.DataNow; % Including itself
                Siblings = Siblings(Siblings ~= obj); % Exclude itself
            end
        end
        function set.Siblings(obj, Siblings),
            % Validate the given input
            if isempty(obj.ParentNow),
                error('Root cannot have siblings!');
            end
            if ~isa(Siblings, 'wit'),
                error('Siblings can be set by an array of wit tree objects! It can optionally include the main object to choose its position within its new siblings. Otherwise, the main object will be first!');
            end
            ind = find(Siblings == obj, 1); % Get index of this object
            if isempty(ind), Siblings = [obj Siblings]; end % SPECIAL CASE: Make this object first if its position was not chosen
            obj.ParentNow.Data = Siblings; % Try to update parent children
        end
        
        % Next (READ-WRITE, DEPENDENT)
        function Next = get.Next(obj),
            Next = wit.empty;
            if ~isempty(obj.ParentNow),
                Siblings = obj.ParentNow.DataNow; % Including itself
                ind_Next = find(Siblings == obj, 1) + 1;
                if ind_Next <= numel(Siblings), Next = Siblings(ind_Next); end
            end
        end
        function set.Next(obj, Next),
            % Validate the given input
            if isempty(obj.ParentNow),
                error('Root cannot have next sibling!');
            end
            if ~isa(Next, 'wit'),
                error('Next can be set by an array of wit tree objects!');
            end
            Children = obj.ParentNow.DataNow; % Get parent children
            ind = find(Children == obj, 1); % Get index of this object
            Children = [Children(1:ind) reshape(Next, 1, [])]; % Keep the previous siblings and replace the next siblings
            obj.ParentNow.Data = Children; % Try to update parent children
        end
        
        % Prev (READ-WRITE, DEPENDENT)
        function Prev = get.Prev(obj),
            Prev = wit.empty;
            if ~isempty(obj.ParentNow),
                Siblings = obj.ParentNow.DataNow; % Including itself
                ind_Prev = find(Siblings == obj, 1) - 1;
                if ind_Prev >= 1, Prev = Siblings(ind_Prev); end
            end
        end
        function set.Prev(obj, Prev),
            % Validate the given input
            if isempty(obj.ParentNow),
                error('Root cannot have previous sibling!');
            end
            if ~isa(Prev, 'wit'),
                error('Prev can be set by an array of wit tree objects! Its content will be added in reversed order.');
            end
            Children = obj.ParentNow.DataNow; % Get parent children
            ind = find(Children == obj, 1); % Get index of this object
            Children = [fliplr(reshape(Prev, 1, [])) Children(ind:end)]; % Keep the next siblings and replace the previous siblings
            obj.ParentNow.Data = Children; % Try to update parent children
        end
        
        % FullName (READ-ONLY, DEPENDENT)
        function FullName = get.FullName(obj),
            Root = obj.FullName_RootNow;
            % Update stored FullName if any change is detected
            if isempty(Root) || ...
                    obj.FullName_RootModifiedCount ~= Root.ModifiedCount,
                % Find new FullName (and Root)
                FullName = obj.NameNow;
                Root = obj;
                while ~isempty(Root.ParentNow),
                    FullName = [FullName '<' Root.ParentNow.NameNow];
                    Root = Root.ParentNow;
                end
                % Update the related modification tracking variables
                obj.FullName_RootModifiedCount = Root.ModifiedCount;
                % Update obj.FullNameNow (and obj.FullName_RootNow)
                obj.FullNameNow = FullName;
                obj.FullName_RootNow = Root;
            else, % Otherwise, return the stored FullName untouched
                FullName = obj.FullNameNow;
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
        
        % ModifiedCount (READ-ONLY)
        
        % Id (READ-ONLY)
        
        
        
        %% METHODS
        % Define Octave-compatible handle-like eq, ne, lt, le, gt and ge:
        % https://se.mathworks.com/help/matlab/ref/handle.relationaloperators.html
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
        
        % Define horzcat, vertcat, reshape missing in Octave
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
        destroy(obj); % Deprecated! Use delete instead!
        write(obj, varargin); % Write obj to file
        update(obj); % Update file format header information
        reload(obj); % Reload obj.Data from file
        
        % Add children
        adopt(obj, varargin); % DEPRECATED! TO BE REMOVED!
        
        % Conversion to/from binary form
        buffer = binary(obj, swapEndianess); % DEPRECATED! Use bwrite instead!
        binaryread(obj, buffer, N_bytes_max, swapEndianess, skip_Data_criteria_for_obj, error_criteria_for_obj); % DEPRECATED! Use bread instead!
        ind_begin = binaryread_Data(obj, buffer, N_bytes_max, swapEndianess); % DEPRECATED! Use bread_Data instead!
        
        buffer = bwrite(obj, swapEndianess, fun_progress_bar);
        bread(obj, buffer, N_bytes_max, swapEndianess, skip_Data_criteria_for_obj, error_criteria_for_obj, fun_progress_bar);
        bread_Data(obj, buffer, N_bytes_max, swapEndianess);
        
        [best_dist, best_obj] = binary_ind2obj(obj, ind); % For debugging
        
        % Object search
        varargout = search_children(obj, varargin);
        varargout = regexp_children(obj, varargin);
        tags = regexp_all_Names(obj, pattern);
        tags = regexp(obj, pattern, FirstOnly, LayersFurther, PrevFullNames);
        tags = search(obj, varargin);
        tags = regexp_ancestors(obj, pattern, FirstOnly, LayersFurther);
        tags = search_ancestors(obj, varargin);
        tags = match_by_Data_criteria(obj, test_fun);
        
        % Object debugging
        S = collapse(obj);
        
        % Override built-in addlistener to include some optimizations
        function event_listener = addlistener(obj, varargin),
            event_listener = event.listener(obj, varargin{:}); % This line is incompatible with Octave
            isObjectModified = strcmp(varargin{1}, 'ObjectModified');
            for ii = 1:numel(obj),
                obj(ii).Listeners{end+1,1} = event_listener; % By default, bound to this object's lifetime
                if isObjectModified, obj(ii).ModifiedEvents = true; end % Required for optimizations
            end
        end
    end
    
    %% STATIC METHODS
    methods (Static)
        % Read file to obj
        obj = read(File, N_bytes_max, skip_Data_criteria_for_obj, error_criteria_for_obj, varargin);
        
        % Default Command Window progress bar used in content reading and writing
        [fun_start, fun_now, fun_end] = progress_bar(N_bytes_max, varargin);
        
        % Determine whether or not to swap endianess to achieve little
        % endian ordering
        swapEndianess = swap_endianess();
        
        % Getters and setters for (un)formatted DataTree, also for debugging
        DataTree_set(parent, in, format); % For (un)formatted structs
        out = DataTree_get(parent, format); % For (un)formatted structs
        
        % Define Octave-compatible empty-function
        function empty = empty(), % Faster than MATLAB's built-in empty!
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
        fwrite(obj, fid, swapEndianess, fun_progress_bar);
        fread(obj, fid, N_bytes_max, swapEndianess, skip_Data_criteria_for_obj, error_criteria_for_obj, fun_progress_bar);
        fread_Data(obj, fid, N_bytes_max, swapEndianess);
        
        % Increments obj's ModifiedCount-property by one and notifies
        % ancestors if permitted. This carefully avoids creating references
        % to wit Tree objects, what seems to be extremely cumbersome.
        function modification(obj, property, meta),
            % Initialize arrays
            Indices = obj.ModifiedDescendantIndices([]);
            Ids = obj.ModifiedDescendantIds([]);
            if obj.ModifiedAncestors,
                while true,
                    obj.ModifiedCount = obj.ModifiedCount + 1;
                    obj.ModifiedDescendantProperty = property;
                    if nargin > 2, obj.ModifiedDescendantMeta = meta; end
                    obj.ModifiedDescendantIndices = Indices;
                    obj.ModifiedDescendantIds = Ids;
                    if obj.ModifiedEvents, notify(obj, 'ObjectModified'); end % Trigger attached events % This line is Octave-incompatible!
                    % Update arrays
                    Indices = [obj.OrdinalNumber Indices];
                    Ids = [obj.Id Ids];
                    % Get next ancestor and exit if none exists
                    obj = obj.ParentNow;
                    if isempty(obj), break; end
                end
            else,
                obj.ModifiedCount = obj.ModifiedCount + 1;
                obj.ModifiedDescendantProperty = property;
                if nargin > 2, obj.ModifiedDescendantMeta = meta; end
                obj.ModifiedDescendantIndices = Indices;
                obj.ModifiedDescendantIds = Ids;
                if obj.ModifiedEvents, notify(obj, 'ObjectModified'); end % Trigger attached events % This line is Octave-incompatible!
            end
        end
    end
end
