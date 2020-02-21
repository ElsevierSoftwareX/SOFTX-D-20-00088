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

% Class for project
classdef wip < handle, % Since R2008a
    properties (Dependent)
        File;
        Version; % WIP/WID-file version. See 'README on WIT-tag formatting.txt'.
    end
    
    properties % If field names are added or altered, then also update storeState and restoreState!
        Data = wid.Empty;
        Tree = wit.empty;
        % DataUnit, SpaceUnit, SpectralUnit or TimeUnit
        ForceDataUnit = '';
        ForceSpaceUnit = '';
        ForceSpectralUnit = '';
        ForceTimeUnit = '';
        % Configure writing behaviour
        OnWriteResetViewers = true; % If true, then remove all the Viewer windows (shown on the WITec software side). This avoids possible corruption of the modified files, because wit_io mostly ignores Viewers.
        % Below LIFO (last in, first out) arrays with their default values.
        % Update the default values (if changed) in their pop-functions.
        UseLineValid = true; % A feature of TDGraph and TDImage. If used, shows NaN where invalid.
        AutoCreateObj = true; % Automatically create a new object (whenever applicable). If false, then new_obj output should be empty.
        AutoCopyObj = true; % Automatically make a copy of the original object (whenever applicable). If false, then obj output should be originals.
        AutoModifyObj = true; % Automatically modify either the original object or its copy (whenever applicable). If false, then obj output should not be modified.
    end
    
    properties (Constant)
        FullStandardUnits = {'Arbitrary Unit (a.u.)', ...
            'Energy (eV)', 'Energy (meV)', 'Femtoseconds (fs)', ...
            'Hours (h)', 'Meters (m)', 'Micrometers (µm)', ...
            'Microseconds (µs)', 'Millimeters (mm)', ...
            'Milliseconds (ms)', 'Minutes (min)', 'Nanometers (nm)', ...
            'Nanoseconds (ns)', 'Picometers (pm)', 'Picoseconds (ps)', ...
            'Raman Shift (rel. 1/cm)', 'Relative Energy (rel. eV)', ...
            'Relative Energy (rel. meV)', 'Seconds (s)', ...
            'Spectroscopic Wavenumber (1/cm)', 'Ångströms (Å)'};
        ArbitraryUnit = wip.interpret_StandardUnit('a.u.');
        DefaultSpaceUnit = wip.interpret_StandardUnit('µm');
        DefaultSpectralUnit = wip.interpret_StandardUnit('nm');
        DefaultTimeUnit = wip.interpret_StandardUnit('s');
    end
    
    %% PUBLIC METHODS
    methods
        % CONSTRUCTOR
        function obj = wip(O_wit),
            if nargin == 0, O_wit = wip.new(); end % Create minimal project
            if ~isempty(O_wit),
                obj.Tree = O_wit;
                obj.Data = wid(O_wit);
            end
            obj.storeState(); % Store this state
        end
        
        function set.Data(obj, Data),
            for ii = 1:numel(Data),
                Data(ii).Project = obj;
            end
            obj.Data = Data(:); % Force column vector
        end
        
        function File = get.File(obj),
            File = obj.Tree.File;
        end
        
        function set.File(obj, File),
            obj.Tree.File = char(File);
        end
        
        function Version = get.Version(obj),
            Version = wip.get_Root_Version(obj.Tree);
        end
        
        function set.Version(obj, Version),
            wip.set_Root_Version(obj.Tree, Version);
        end
        
        function set.ForceDataUnit(obj, Value),
            if ~isempty(Value),
                try, Value = wip.interpret('TDZInterpretation', Value); % Try interpret
                catch, Value = ''; end % Reset to empty on failure
            end
            obj.ForceDataUnit = Value;
        end
        
        function set.ForceSpaceUnit(obj, Value),
            if ~isempty(Value),
                try, Value = wip.interpret('TDSpaceInterpretation', Value); % Try interpret
                catch, Value = ''; end % Reset to empty on failure
            end
            obj.ForceSpaceUnit = Value;
        end
        
        function set.ForceSpectralUnit(obj, Value),
            if ~isempty(Value),
                try, Value = wip.interpret('TDSpectralInterpretation', Value); % Try interpret
                catch, Value = ''; end % Reset to empty on failure
            end
            obj.ForceSpectralUnit = Value;
        end
        
        function set.ForceTimeUnit(obj, Value),
            if ~isempty(Value),
                try, Value = wip.interpret('TDTimeInterpretation', Value); % Try interpret
                catch, Value = ''; end % Reset to empty on failure
            end
            obj.ForceTimeUnit = Value;
        end
        
        
        
        %% OTHER METHODS
        % Call storeState-function in order to save previous state and
        % temporarily alter any of the wip-class parameters and finally use
        % restoreState-function to reload previous state.
        % NOTE (1.8.2019): Prefer pop- and push- functions below instead as
        % these two may be removed in the future releases.
        function storedState = storeState(obj),
            storedState = {obj.ForceDataUnit, obj.ForceSpaceUnit, obj.ForceSpectralUnit, obj.ForceTimeUnit, obj.UseLineValid, obj.AutoCreateObj, obj.AutoCopyObj, obj.AutoModifyObj};
        end
        function restoreState(obj, storedState),
            if ~isempty(storedState),
                [obj.ForceDataUnit, obj.ForceSpaceUnit, obj.ForceSpectralUnit, obj.ForceTimeUnit, obj.UseLineValid, obj.AutoCreateObj, obj.AutoCopyObj, obj.AutoModifyObj] = deal(storedState{:});
            end
        end
        
        % LIFO (last in, first out) concept for UseLineValid
        function latest = popUseLineValid(obj),
            latest = obj.popBoolean('UseLineValid', true); % With default
        end
        function pushUseLineValid(obj, latest),
            obj.pushBoolean('UseLineValid', latest);
        end
        
        % LIFO (last in, first out) concept for AutoCreateObj
        function latest = popAutoCreateObj(obj),
            latest = obj.popBoolean('AutoCreateObj', true); % With default
        end
        function pushAutoCreateObj(obj, latest),
            obj.pushBoolean('AutoCreateObj', latest);
        end
        
        % LIFO (last in, first out) concept for AutoCopyObj
        function latest = popAutoCopyObj(obj),
            latest = obj.popBoolean('AutoCopyObj', true); % With default
        end
        function pushAutoCopyObj(obj, latest),
            obj.pushBoolean('AutoCopyObj', latest);
        end
        
        % LIFO (last in, first out) concept for AutoModifyObj
        function latest = popAutoModifyObj(obj),
            latest = obj.popBoolean('AutoModifyObj', true); % With default
        end
        function pushAutoModifyObj(obj, latest),
            obj.pushBoolean('AutoModifyObj', latest);
        end
        
        
        
        % Open Project Manager with the given parameters
        O_wid = manager(obj, varargin);
        
        % File writer
        write(obj, File);
        
        % Update Data-property according to Tree-property contents
        update(obj);
        
        % Destroy duplicate transformations 
        destroy_duplicate_Transformations(obj);
        
        % Remove saved Viewer-settings
        reset_Viewers(obj);
        
        % Helper functions for adding, removing and finding wid-objects
        add_Data(obj, varargin);
        destroy_Data(obj, varargin);
        O_wid = find_Data(obj, ID);
        
        % Transformations and interpretations (project version)
        [ValueUnit, varargout] = transform_forced(obj, S, varargin);
        [ValueUnit, varargout] = interpret_forced(obj, S, Unit_new, Unit_old, varargin);
    end
    
    %% PRIVATE METHODS
    methods (Access = private)
        % GENERIC BOOLEAN LIFO (last in, first out) concept
        function latest = popBoolean(obj, field, default),
            if isempty(obj),
                latest = default; % Return default value if an empty wip
            else,
                lifo_array = obj.(field);
                latest = lifo_array(end);
                if numel(lifo_array) > 1, % Pop element if not first
                    obj.(field) = lifo_array(1:end-1);
                end
            end
        end
        function pushBoolean(obj, field, latest),
            if ~islogical(latest) && ~isnumeric(latest),
                error('Accepting only logical or numeric arrays!');
            end
            if ~isempty(obj), % Continue only if non-empty wip
                latest = logical(latest(:)); % Force to logical column vector
                ind_latest = 1:numel(latest);
                obj.(field)(end+ind_latest) = latest; % Push elements in the given order
            end
        end
    end
    
    methods (Static)
        % Constructor WIP-formatted WIT-tree
        O_wit = new(Version); % WITec Project WIT-tree
        O_wit = new_TData(Version, Caption); % Only TData WIT-tree
        
        % Get valid DataClassName-Data pairs from the given WIT-tree
        Pairs = get_Data_DataClassName_pairs(O_wit);
        
        % Appender of multiple WIT-trees (or Projects)
        [O_wit, varargout] = append(varargin);
        
        % File reader
        [O_wid, O_wip, O_wid_HtmlNames] = read(varargin);
        Version = read_Version(File);
        
        % File version
        Version = get_Root_Version(obj); % Can be wid-, wip- or wit-class
        set_Root_Version(obj, Version); % Can be wid-, wip- or wit-class
        
        % Transformations and interpretations (static version)
        [ValueUnit, varargout] = transform(S, varargin);
        [ValueUnit, varargout] = interpret(S, Unit_new, Unit_old, varargin);
        ValueUnit = interpret_StandardUnit(StandardUnit);
    end
end
