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
    % Hidden constant to reduce calls to a lot used wit.empty
    properties (Constant, Hidden)
        % Using wit.Empty is up to 60 times faster than wit.empty
        Empty = wit.empty; % Call wit.empty only once
    end
    
    properties
        % Main file-format parameters
        Name = '';
        Data = wit.Empty;
        % References to other relevant tags
        Parent = wit.Empty;
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
    end
    
    %% PUBLIC METHODS
    methods
        % CONSTRUCTOR
        function obj = wit(ParentOrName, NameOrData, DataOrNone),
            if nargin > 0,
                if isa(ParentOrName, 'wit'),
                    obj.Parent = ParentOrName;
                elseif isa(ParentOrName, 'char'),
                    if nargin > 2, error('Too many input arguments.'); end
                    obj.Name = ParentOrName;
                else, error('First input must be either wit-class or char!'); end
            end
            if nargin > 1,
                if isa(ParentOrName, 'wit'),
                    if isa(NameOrData, 'char'),
                        obj.Name = NameOrData;
                        if nargin > 2, obj.Data = DataOrNone; end
                    else, error('If first input is wit-class, then second must be char!'); end
                else, obj.Data = NameOrData; end
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
            Children = wit.Empty;
            if isa(obj.Data, 'wit'), Children = obj.Data; end
        end
        
        function Root = get.Root(obj),
            Root = obj;
            while ~isempty(Root.Parent), Root = Root.Parent; end
        end
        
        function Siblings = get.Siblings(obj),
            Siblings = wit.Empty;
            if ~isempty(obj.Parent),
                Siblings = obj.Parent.Data; % Including itself
                Siblings = Siblings(Siblings ~= obj); % Exclude itself
            end
        end
        
        function Next = get.Next(obj),
            Next = wit.Empty;
            if ~isempty(obj.Parent),
                Siblings = obj.Parent.Data; % Including itself
                ind_Next = find(Siblings == obj, 1) + 1;
                if ind_Next <= numel(Siblings), Next = Siblings(ind_Next); end
            end
        end
        
        function Prev = get.Prev(obj),
            Prev = wit.Empty;
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
    end
    
    %% PRIVATE METHODS
    methods (Access = private)
        fwrite(obj, fid, swapEndianess);
        fread(obj, fid, N_bytes_max, swapEndianess);
        fread_Data(obj, fid, N_bytes_max, swapEndianess);
    end
end
