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

% Handle class with basic struct-functionality. Attempts to combine the
% best properties of struct (simplicity) and handle (low-on-memory).
% Significant speed performance losses are unavoidable if using loops.
classdef handle_struct < dynamicprops, % Since R2008a
    methods % Implementing the basic struct-like functionality
        % Needed to make a deep copy of the object. Use delete to destroy.
        function new = copy(obj),
            new = handle_struct();
            fields = obj.fieldnames();
            new.addfield(fields); % The missing fields must be added in this case
            for ii = 1:numel(fields),
                new.(fields{ii}) = obj.(fields{ii}); % Does not call the overloaded functions!
            end
        end
        
        % Called if the object appears on the left side of an assignment.
        % This replaces setfield-functionality.
        function obj = subsasgn(obj, S, B), % Overload dot-operator only
            if strcmp(S(1).type, '.') && isempty(findprop(obj, S(1).subs)), % Test if field exists
                addprop(obj, S(1).subs); % Add missing field
            end
            obj = builtin('subsasgn', obj, S, B);
        end
        
        % Called if the object appears on the right side of an assignment.
        % This replaces getfield-functionality. Comment for ~4x speed-up
        % without losing any struct-like functionality.
        function B = subsref(obj, S), % Overload dot-operator only
            if strcmp(S(1).type, '.') && isempty(findprop(obj, S(1).subs)), % Test if field exists
                error('Reference to non-existent field ''%s''.', S(1).subs);
            end
            B = builtin('subsref', obj, S);
        end
        
        % Simple way to add multiple fields at once. Extra functionality.
        function addfield(obj, varargin),
            for ii = 1:numel(varargin),
                field = varargin{ii};
                if iscell(field),
                    obj.addfield(field{:});
                elseif isempty(findprop(obj, field)), % Skip if exists
                    addprop(obj, field);
                end
            end
        end
        
        % Mimics isfield for struct
        function tf = isfield(obj, varargin),
            tf = logical.empty;
            for ii = 1:numel(varargin),
                field = varargin{ii};
                if iscell(field),
                    tf = [tf obj.isfield(field{:})];
                else, % Reversed to initialize only once
                    tf(end+1) = ~isempty(findprop(obj, field));
                end
            end
        end
        
        % Mimics rmfield for struct
        function rmfield(obj, varargin),
            for ii = 1:numel(varargin),
                field = varargin{ii};
                if iscell(field),
                    obj.rmfield(field{:});
                elseif ~isempty(findprop(obj, field)), % Remove if exists
                    delete(findprop(obj, field));
                end
            end
        end
        
        % Mimics fieldnames for struct
        function fields = fieldnames(obj),
            fields = properties(obj);
        end
    end
end
