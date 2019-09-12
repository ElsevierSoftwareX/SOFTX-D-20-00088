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
    properties
        % Main file-format parameters
        Name = '';
        Data; % = wit.empty; % latter is Octave-incompatible!
        % References to other relevant tags
        Parent; % = wit.empty; % latter is Octave-incompatible!
    end

    % Depend either on Data (for Children) or Parent (for the others)
    properties (SetAccess = private, Dependent) % READ-ONLY
        % Depends on Data
        Children;
        % Depend on Parent
        Root;
        Siblings;
        Next; % Next sibling
        Prev; % Previous sibling
        % Depends on Name and Parent
        FullName;
    end

    % File-specific read-only parameters
    properties (SetAccess = private)
        % Extra file-format parameters
        NameLength = uint32(0); % Always updated before writing!
        Type = uint32(0); % Always updated before writing!
        Start = uint64(0); % Always updated before writing!
        End = uint64(0); % Always updated before writing!
        % Other extra parameters
        Header = uint64(0); % Always updated before writing!
        HasData = false; % Useful flag for the reloading cases
        File = ''; % NOTE: IS THE CURRENT IMPLEMENTATION BUG FREE? (1.7.2017)
    end
    
    properties
        Magic = 'WIT_TREE'; % Practically only the Magic string of Root matters
        IsValid = true; % Used internally by fread and binaryread functions
        Id = uint64(0); % Used internally enable handle-like comparison in Octave
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
        
        %% READ-WRITE
        % Validate the given input
        function set.Name(obj, Name),
            if ischar(Name), obj.Name = reshape(Name, 1, []);
            else, error('Only a char array can be a name!'); end
        end
        
        % Needed to handle special case of adding Children to the obj
        function set.Data(obj, Data),
            if isa(Data, 'wit'), % If Children, then add Parent to them
                for ii = 1:numel(Data), Data(ii).Parent = obj; end
            end
            obj.Data = Data;
            obj.HasData = ~isempty(Data);
        end
        
        % Validate the given input
        function set.Parent(obj, Parent),
            if isa(Parent, 'wit'),
                if numel(Parent) <= 1, obj.Parent = Parent; % But parent wont be notified!
                else, error('A tag cannot have more than one parent!'); end
            else, error('Only a wit-tag can be a parent!'); end
        end
        
        %% READ-ONLY
        function Children = get.Children(obj),
            Children = wit.empty;
            if isa(obj.Data, 'wit'), Children = obj.Data; end
        end
        
        function Root = get.Root(obj),
            Root = obj;
            while ~isempty(Root.Parent), Root = Root.Parent; end
        end
        
        function Siblings = get.Siblings(obj),
            Siblings = wit.empty;
            if ~isempty(obj.Parent),
                Siblings = obj.Parent.Data; % Including itself
                Siblings = Siblings(Siblings ~= obj); % Exclude itself
            end
        end
        
        function Next = get.Next(obj),
            Next = wit.empty;
            if ~isempty(obj.Parent),
                Siblings = obj.Parent.Data; % Including itself
                ind_Next = find(Siblings == obj, 1) + 1;
                if ind_Next <= numel(Siblings), Next = Siblings(ind_Next); end
            end
        end
        
        function Prev = get.Prev(obj),
            Prev = wit.empty;
            if ~isempty(obj.Parent),
                Siblings = obj.Parent.Data; % Including itself
                ind_Prev = find(Siblings == obj, 1) - 1;
                if ind_Prev >= 1, Prev = Siblings(ind_Prev); end
            end
        end
        
        function FullName = get.FullName(obj), % Potential bottleneck!
            FullName = obj.Name;
            while ~isempty(obj.Parent),
                FullName = [FullName '<' obj.Parent.Name];
                obj = obj.Parent;
            end
%             % Buffered version (slower)
%             FullName(4096) = char(0);
%             str = obj.Name;
%             FullName(1:numel(str)) = str;
%             N = numel(str);
%             while ~isempty(obj.Parent),
%                 FullName(N+1) = '<';
%                 str = obj.Parent.Name; % Bottleneck!
%                 FullName(N+1+(1:numel(str))) = str;
%                 N = N + 1 + numel(str);
%                 obj = obj.Parent;
%             end
%             FullName = FullName(1:N); % Discard buffered zeros
        end
        
        %% READ-WRITE
        % Needed to inherit this property from the root when not specified
        function File = get.File(obj),
            if ~isempty(obj.File), File = obj.File; % If available, obtain it from this
            else, File = obj.Root.File; end % Otherwise, obtain it from the root
        end
        
        % Needed to inherit this property from the root when not specified
        function Magic = get.Magic(obj),
            if ~isempty(obj.Magic), Magic = obj.Magic; % If available, obtain it from this
            else, Magic = obj.Root.Magic; end % Otherwise, obtain it from the root
        end
        
        
        
        % Define Octave-compatible handle-like eq, ne, lt, le, gt and ge:
        % https://se.mathworks.com/help/matlab/ref/handle.relationaloperators.html
        function tf = compare(O1, O2, fun, default),
            if numel(O1) == 1 || numel(O2) == 1 || ... % Either O1 or O2 is scalar
                    ndims(O1) == ndims(O2) && all(size(O1) == size(O2)), % Or size(O1) == size(O2)
                if isa(O2, 'wit'), tf = fun(reshape([O1.Id], size(O1)), reshape([O2.Id], size(O2)));
                elseif numel(O1) == 1, tf = repmat(default, size(O2));
                else, tf = repmat(default, size(O1)); end
            else, error('Matrix dimensions must agree.'); end
        end
        function tf = eq(O1, O2), tf = O1.compare(O2, @eq, false); end % Equal
        function tf = ne(O1, O2), tf = O1.compare(O2, @ne, true); end % Not equal
        function tf = lt(O1, O2), tf = O1.compare(O2, @lt, false); end % Less than
        function tf = le(O1, O2), tf = O1.compare(O2, @le, false); end % Less than or equal
        function tf = gt(O1, O2), tf = O1.compare(O2, @gt, false); end % Greater than
        function tf = ge(O1, O2), tf = O1.compare(O2, @ge, false); end % Greater than or equal
        
        % Define horzcat, vertcat, reshape missing in Octave
        function obj = horzcat(varargin), % Enables [O1 O2 ...]
            if ~is_octave(), obj = builtin('horzcat', varargin{:}); % MATLAB-way
            else, % Octave-way
                obj = wit.empty;
                varargin = varargin(~cellfun(@isempty, varargin)); % Skip empty
                if ~isempty(varargin),
                    D = max(cellfun(@ndims, varargin)); % Number of dimensions
                    obj = varargin{1}; % Get the 1st non-empty object array
                    [S{1:D}] = size(obj); % and its size
                    for ii = 2:numel(varargin),
                        obj_ii = varargin{ii}; % Get the ii'th non-empty object array
                        [S_ii{1:D}] = size(obj_ii); % and its size
                        if any([S{[1 3:D]}] ~= [S_ii{[1 3:D]}]), % Test if the sizes are compatible
                            error('Dimensions of arrays being concatenated are not consistent.');
                        end
                        obj(end+1:end+numel(obj_ii)) = obj_ii; % Append to the 1st non-empty object array
                    end
                    obj = reshape(obj, S{1}, [], S{3:D}); % Restore the shape accordingly
                end
            end
        end
        function obj = vertcat(varargin), % Enables [O1; O2; ...]
            if ~is_octave(), obj = builtin('vertcat', varargin{:}); % MATLAB-way
            else, % Octave-way
                obj = wit.empty;
                varargin = varargin(~cellfun(@isempty, varargin)); % Skip empty
                if ~isempty(varargin),
                    D = max(cellfun(@ndims, varargin)); % Number of dimensions
                    obj = varargin{1}; % Get the 1st non-empty object array
                    [S{1:D}] = size(obj); % and its size
                    for ii = 2:numel(varargin),
                        obj_ii = varargin{ii}; % Get the ii'th non-empty object array
                        [S_ii{1:D}] = size(obj_ii); % and its size
                        if any([S{2:D}] ~= [S_ii{2:D}]), % Test if the sizes are compatible
                            error('Dimensions of arrays being concatenated are not consistent.');
                        end
                        obj(end+1:end+numel(obj_ii)) = obj_ii; % Append to the 1st non-empty object array
                    end
                    obj = reshape(obj, [], S{2:D}); % Restore the shape accordingly
                end
            end
        end
        function obj = reshape(obj, varargin), % Enables object array reshaping
            if ~is_octave(), obj = builtin('reshape', obj, varargin{:}); % MATLAB-way
            else, obj = obj(reshape(1:numel(obj), varargin{:})); end % Octave-way
        end
        
        
        
        %% OTHER METHODS
        % Object copying, destroying, writing, reloading
        new = copy(obj); % Copy obj
        destroy(obj, skipParent); % Delete obj
        write(obj, File); % Write obj to file
        update(obj); % Update file format header information
        reload(obj); % Reload obj.Data from file
        
        % Add new children
        adopt(obj, varargin);
        
        % Conversion to/from binary form
        buffer = binary(obj, swapEndianess);
        ind_begin = binaryread(obj, buffer, ind_begin, N_bytes_max, swapEndianess);
        ind_begin = binaryread_Data(obj, buffer, N_bytes_max, swapEndianess);
        
        % Object search
        tags = regexp(obj, pattern, FirstOnly, LayersFurther, PrevFullNames);
        tags = search(obj, varargin);
        tags = match_by_Data_criteria(obj, test_fun);
        
        % Object debugging
        S = collapse(obj);
    end
    
    %% STATIC METHODS
    methods (Static)
        % Read file to obj
        obj = read(File, N_bytes_max);
        
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
        fread(obj, fid, N_bytes_max, swapEndianess);
        fread_Data(obj, fid, N_bytes_max, swapEndianess);
    end
end
