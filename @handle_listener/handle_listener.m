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

% Class for handle controller via weak references
classdef handle_listener < handle, % Since R2008a
    events
        listen_handle_event;
    end
    properties (SetAccess = private, Dependent) % READ-ONLY, DEPENDENT
        all;
    end
    properties (SetAccess = private, Hidden) % READ-ONLY
        temporary_objects; % This must always be cleared to avoid issues with MATLAB's garbace collector!
        empty_handle_listener = event.listener.empty; % To avoid repeated calls to empty!
    end
    %% PUBLIC METHODS
    methods
        % To keep only weak references to the objects array, each returned
        % event.listener must be only be stored in its corresponding object
        % of the objects array! Omit property-input to decide elsewhere
        % where to store the handle_listeners array content. If given, then
        % they will be stored to each object's property in the objects
        % array.
        function handle_listeners = add(obj, objects, property),
            setProperty = nargin > 2;
            handle_listeners = obj.empty_handle_listener;
            % Loop to create one event per object handle
            for ii = numel(objects):-1:1,
                fun = @(src, event_data) event_data.fun(objects(ii), event_data.varargin{:});
                handle_listeners(ii) = event.listener(obj, 'listen_handle_event', fun);
                if setProperty, objects(ii).(property) = handle_listeners(ii); end
            end
        end
        function objects = get.all(obj),
            objects = obj.listen_handle(@obj.fun_all);
        end
        function varargout = all_parsed(obj, parser, UniformOutput),
            if nargin < 3, UniformOutput = false; end % By default, assume non-uniform parser output
            obj.temporary_objects = obj.all;
            varargout = obj.postconditioner(parser, nargout, UniformOutput);
        end
        function objects = match_all(obj, tester),
            objects = obj.listen_handle(@obj.fun_match_all, tester);
        end
        function varargout = match_all_parsed(obj, tester, parser, UniformOutput),
            if nargin < 4, UniformOutput = false; end % By default, assume non-uniform parser output
            obj.temporary_objects = obj.match_all(tester);
            varargout = obj.postconditioner(parser, nargout, UniformOutput);
        end
        function object = match_any(obj, tester),
            object = obj.listen_handle(@obj.fun_match_any, tester);
        end
        function varargout = match_any_parsed(obj, tester, parser, UniformOutput),
            if nargin < 4, UniformOutput = false; end % By default, assume non-uniform parser output
            obj.temporary_objects = obj.match_any(tester);
            varargout = obj.postconditioner(parser, nargout, UniformOutput);
        end
    end
    %% PRIVATE METHODS
    methods (Access = private)
        function objects = listen_handle(obj, fun, varargin),
            ocu = onCleanup(@() obj.clear()); % Ensure safe clearing of temporary values on exit
            notify(obj, 'listen_handle_event', handle_listener_event_data(fun, varargin{:}));
            % According to MATLAB's documentation, all listener callbacks
            % must be synchronously fired with notify-call [1].
            % [1] https://www.mathworks.com/help/matlab/matlab_oop/callback-execution.html
            objects = obj.temporary_objects;
        end
        function clear(obj),
            obj.temporary_objects = []; % Clearing any references to objects is crucial to allow MATLAB's garbage collector to work
        end
        function fun_all(obj, object),
            if isempty(obj.temporary_objects), obj.temporary_objects = object;
            else, obj.temporary_objects(end+1,1) = object; end
        end
        function fun_match_all(obj, object, tester),
            if tester(object),
                if isempty(obj.temporary_objects), obj.temporary_objects = object;
                else, obj.temporary_objects(end+1,1) = object; end
            end
        end
        function fun_match_any(obj, object, tester),
            if isempty(obj.temporary_objects) && tester(object),
                obj.temporary_objects = object;
            end
        end
        % Parse obj.temporary_objects into the requested number of outputs.
        % It returns a cell array (or a nested cell array for non-uniform
        % outputs) that can be directly passed to varargout in an external
        % call.
        function outputs = postconditioner(obj, parser, N_outputs, UniformOutput),
            ocu = onCleanup(@() obj.clear()); % Ensure safe clearing of temporary values on exit
            objects = obj.temporary_objects;
            N_objects = numel(objects);
            if N_objects == 0,
                if UniformOutput, outputs = {[]}; % Empty cell array
                else, outputs = {{}}; end % Empty nested cell array
                return;
            end
            % Collect all outputs for all objects
            temporary_outputs = cell(N_objects, N_outputs);
            for ii = 1:N_objects,
                [temporary_outputs{ii,1:N_outputs}] = parser(objects(ii));
            end
            % For uniform output, force all outputs to row vectors
            if UniformOutput,
                for ii = 1:numel(temporary_outputs),
                    temporary_outputs{ii} = reshape(temporary_outputs{ii}, 1, []);
                end
            end
            % Create final output
            outputs = cell(1, N_outputs);
            if UniformOutput, % For uniform output, construct a cell array
                for ii = 1:N_outputs,
                    outputs{ii} = cat(1, temporary_outputs{:,ii});
                end
            else, % For non-uniform output, construct a nested cell array
                for ii = 1:N_outputs,
                    outputs{ii} = temporary_outputs(:,ii);
                end
            end
        end
    end
end
