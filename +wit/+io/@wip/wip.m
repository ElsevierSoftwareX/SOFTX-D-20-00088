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
    %% MAIN PROPERTIES
    properties (SetAccess = private, Dependent) % READ-ONLY, DEPENDENT
        File;
        Name;
    end
    properties % READ-WRITE
        Data = wit.io.wid.empty;
    end
    properties (Dependent) % READ-WRITE, DEPENDENT
        Type;
    end
    
    %% OTHER PROPERTIES
    properties (Dependent) % READ-WRITE, DEPENDENT
        Version; % WIP/WID-file version. See 'README on WIT-tag formatting.txt'.
    end
    properties % READ-WRITE
        Tree = wit.io.wit.empty;
    end
    
    properties (SetAccess = private, Hidden) % READ-ONLY, HIDDEN
        TreeData = wit.io.wit.empty;
        TreeDataModifiedCount = [];
        wip_listener;
        TreeObjectBeingDestroyedListener;
        TreeObjectModifiedListener;
        DataObjectBeingDestroyedListener;
        DataObjectModifiedListener;
    end
    
    properties % READ-WRITE
        % DataUnit, SpaceUnit, SpectralUnit or TimeUnit
        ForceDataUnit = '';
        ForceSpaceUnit = '';
        ForceSpectralUnit = '';
        ForceTimeUnit = '';
        % Configure writing behaviour
        OnWriteDestroyAllViewers = true; % If true, then removes all the Viewer windows (shown on the WITec software side). This avoids possible corruption of the modified files, because wit_io mostly ignores Viewers.
        OnWriteDestroyDuplicateTransformations = true; % If true, then removes all the duplicate Transformations (and keeps the first one).
        % Below LIFO (last in, first out) arrays with their default values.
        % Update the default values (if changed) in their pop-functions.
        UseLineValid = true; % A feature of TDGraph and TDImage. If used, shows NaN where invalid.
        AutoCreateObj = true; % Automatically create a new object (whenever applicable). If false, then new_obj output should be empty.
        AutoCopyObj = true; % Automatically make a copy of the original object (whenever applicable). If false, then obj output should be originals.
        AutoModifyObj = true; % Automatically modify either the original object or its copy (whenever applicable). If false, then obj output should not be modified.
    end
    
    properties (Constant) % READ-ONLY, CONSTANT
        FullStandardUnits = {'Arbitrary Unit (a.u.)', ...
            'Energy (eV)', 'Energy (meV)', 'Femtoseconds (fs)', ...
            'Hours (h)', 'Meters (m)', 'Micrometers (µm)', ...
            'Microseconds (µs)', 'Millimeters (mm)', ...
            'Milliseconds (ms)', 'Minutes (min)', 'Nanometers (nm)', ...
            'Nanoseconds (ns)', 'Picometers (pm)', 'Picoseconds (ps)', ...
            'Raman Shift (rel. 1/cm)', 'Relative Energy (rel. eV)', ...
            'Relative Energy (rel. meV)', 'Seconds (s)', ...
            'Spectroscopic Wavenumber (1/cm)', 'Ångströms (Å)'};
        ArbitraryUnit = wit.io.wip.interpret_StandardUnit('a.u.');
        DefaultSpaceUnit = wit.io.wip.interpret_StandardUnit('µm');
        DefaultSpectralUnit = wit.io.wip.interpret_StandardUnit('nm');
        DefaultTimeUnit = wit.io.wip.interpret_StandardUnit('s');
    end
    
    properties (Constant) % READ-ONLY, CONSTANT
        Projects = wit.io.handle_listener(); % Generates a shared Project listener
    end
    
    %% PUBLIC METHODS
    methods
        % CONSTRUCTOR
        function obj = wip(TreeOrData),
            if nargin == 0, TreeOrData = wit.io.wip.new(); end % Create minimal project
            
            % SPECIAL CASE: Empty wip object
            if isempty(TreeOrData),
                obj = obj([]); % wit.io.wip.empty
                return;
            end
            
            try,
                % Validate the given input
                if isa(TreeOrData, 'wit.io.wit') && numel(TreeOrData) == 1,
                    Tree = TreeOrData.Root;
                elseif isa(TreeOrData, 'wit.io.wid'),
                    Data = TreeOrData;
                    Tags = [Data.Tag];
                    Roots = unique([Tags.Root]);
                    if numel(Roots) ~= 1,
                        error('Provide a wit Tree object array with only one common Root!');
                    end
                    Tree = Roots;
                else,
                    error('Provide either a wit Tree object or a wid Data object array!');
                end
                
                % Check whether or not similar project already exists!
                O_wip = wit.io.wip.Projects.match_any(@(O_wip) O_wip.Tree == Tree); % Due to syncronous link between Project and its Tree, Project's Tree is always Root AND never invalid/deleted!
                
                % Use already existing wip Project object or this
                if ~isempty(O_wip),
                    obj = O_wip;
                else,
                    obj.Tree = Tree;
                    % Enable tracking of this wip Project object
                    obj.wip_listener = wit.io.wip.Projects.add(obj);
                    % Get user preferences (or default values if not found)
                    obj.ForceDataUnit = wit_io_pref_get('wip_ForceDataUnit', obj.ForceDataUnit);
                    obj.ForceSpaceUnit = wit_io_pref_get('wip_ForceSpaceUnit', obj.ForceSpaceUnit);
                    obj.ForceSpectralUnit = wit_io_pref_get('wip_ForceSpectralUnit', obj.ForceSpectralUnit);
                    obj.ForceTimeUnit = wit_io_pref_get('wip_ForceTimeUnit', obj.ForceTimeUnit);
                    obj.OnWriteDestroyAllViewers = wit_io_pref_get('wip_OnWriteDestroyAllViewers', obj.OnWriteDestroyAllViewers);
                    obj.OnWriteDestroyDuplicateTransformations = wit_io_pref_get('wip_OnWriteDestroyDuplicateTransformations', obj.OnWriteDestroyDuplicateTransformations);
                    obj.UseLineValid = wit_io_pref_get('wip_UseLineValid', obj.UseLineValid);
                    obj.AutoCreateObj = wit_io_pref_get('wip_AutoCreateObj', obj.AutoCreateObj);
                    obj.AutoCopyObj = wit_io_pref_get('wip_AutoCopyObj', obj.AutoCopyObj);
                    obj.AutoModifyObj = wit_io_pref_get('wip_AutoModifyObj', obj.AutoModifyObj);
                    % Enable link between Tree and Project
                    obj.TreeObjectBeingDestroyedListener = Tree.addlistener('ObjectBeingDestroyed', @(s,e) delete(obj));
                    obj.TreeObjectModifiedListener = Tree.addlistener('ObjectModified', @(s,e) wip_update_Tree(obj));
                    wip_update_Data(obj);
                end
            catch me, % Handle invalid or deleted object -case
                switch me.identifier,
                    case 'MATLAB:class:InvalidHandle', obj = obj([]); % wit.io.wid.empty
                    otherwise, rethrow(me);
                end
            end
        end
        
        function delete(obj),
            try, % Delete event listeners before toughing the wit Tree
                delete(obj.TreeObjectBeingDestroyedListener);
                delete(obj.TreeObjectModifiedListener);
                delete(obj.DataObjectBeingDestroyedListener);
                delete(obj.DataObjectModifiedListener);
            catch, return; end % Do nothing if already deleted (backward compatible with R2011a)
            % Delete the underlying wid Data objects (only the wrappers)
            delete_wrapper(obj.Data);
            % Delete the underlying wit Tree objects
            delete(obj.Tree);
            % Useful resources:
            % https://se.mathworks.com/help/matlab/matlab_oop/handle-class-destructors.html
            % https://se.mathworks.com/help/matlab/matlab_oop/example-implementing-linked-lists.html
            % https://blogs.mathworks.com/loren/2013/07/23/deconstructing-destructors/
        end
        
        
        
        %% MAIN PROPERTIES
        % File (READ-ONLY, DEPENDENT)
        function File = get.File(obj),
            File = obj.Tree.File;
        end
        
        % Name (READ-ONLY, DEPENDENT)
        function Name = get.Name(obj),
            [~, name, ext] = fileparts(obj.Tree.File);
            Name = [name ext];
        end
        
        % Data (READ-ONLY)
        function Data = get.Data(obj),
            Data = obj.Data; % Auto-updated by an event listener
        end
        
        % Type (READ-WRITE, DEPENDENT)
        function Type = get.Type(obj),
            Type = obj.Tree.Name;
        end
        function set.Type(obj, Type),
            % Validate the given input
            if ischar(Type), Type = reshape(Type, 1, []);
            else, error('Only a char array can be a type!'); end
            
            % Do nothing if no change
            if strcmp(Type, obj.Tree.Name), return; end
            
            % Sort prior children by names
            Tree_prior = obj.Tree;
            Children_prior = [Tree_prior.Children wit.io.wit.empty];
            [names_prior, ind_prior] = sort({Children_prior.Name});
            Children_prior = Children_prior(ind_prior);
            
            % Generate new tree structure template
            Tree = wit.io.wit.empty;
            switch(Type),
                case 'WITec Project',
                    Tree = wit.io.wip.new(obj.Version);
                case 'WITec Data',
                    Tree = wit.io.wid.new(obj.Version);
                otherwise,
                    obj.Tree.Name = Type;
            end
            
            % Use the new tree structure if generated
            if ~isempty(Tree),
                % Sort posterior children by names
                Children = [Tree.Children wit.io.wit.empty];
                [names, ind] = sort({Children.Name});
                Children = Children(ind);
                % Find prior children by matching child names and adopt them
                jj_begin = 1;
                for ii = 1:numel(names),
                    for jj = jj_begin:numel(names_prior),
                        if strcmp(names{ii}, names_prior{jj}),
                            % Adopt the prior child and destroy template
                            delete(Children(ii));
                            Children(ii) = Children_prior(jj);
                            break;
                        elseif strcmp(names{ii}, 'NextDataID'),
                            offset = max([Tree_prior.regexp('^ID<TData<Data \d+(<Data)?$').Data])+1;
                            if isempty(offset), offset = 1; end % No data yet
                            Children(ii).Data = int32(offset);
                        end
                    end
                    jj_begin = jj+1; % Due to sorting, we can skip the previously matched prior children
                end
                % Update posterior tree children
                Children(ind) = Children; % Unsort posterior children
                Tree.Data = Children;
                % Use the new tree and destroy the old tree
                obj.Tree = Tree;
                delete(Tree_prior); % Destroy whatever remains of the old tree
            end
        end
        
        %% OTHER PROPERTIES
        % Version (READ-WRITE, DEPENDENT)
        function Version = get.Version(obj),
            Version = wit.io.wip.get_Root_Version(obj.Tree);
        end
        function set.Version(obj, Version),
            wit.io.wip.set_Root_Version(obj.Tree, Version);
        end
        
        % Tree (READ-ONLY)
        function Tree = get.Tree(obj),
            Tree = obj.Tree; % Auto-updated by an event listener
        end
        
        % ForceDataUnit (READ-WRITE)
        function set.ForceDataUnit(obj, Value),
            if ~isempty(Value),
                try, Value = wit.io.wip.interpret('TDZInterpretation', Value); % Try interpret
                catch, Value = ''; end % Reset to empty on failure
            end
            obj.ForceDataUnit = Value;
        end
        
        % ForceSpaceUnit (READ-WRITE)
        function set.ForceSpaceUnit(obj, Value),
            if ~isempty(Value),
                try, Value = wit.io.wip.interpret('TDSpaceInterpretation', Value); % Try interpret
                catch, Value = ''; end % Reset to empty on failure
            end
            obj.ForceSpaceUnit = Value;
        end
        
        % ForceSpectralUnit (READ-WRITE)
        function set.ForceSpectralUnit(obj, Value),
            if ~isempty(Value),
                try, Value = wit.io.wip.interpret('TDSpectralInterpretation', Value); % Try interpret
                catch, Value = ''; end % Reset to empty on failure
            end
            obj.ForceSpectralUnit = Value;
        end
        
        % ForceTimeUnit (READ-WRITE)
        function set.ForceTimeUnit(obj, Value),
            if ~isempty(Value),
                try, Value = wit.io.wip.interpret('TDTimeInterpretation', Value); % Try interpret
                catch, Value = ''; end % Reset to empty on failure
            end
            obj.ForceTimeUnit = Value;
        end
        
        
        
        %% OTHER METHODS
        % LIFO (last in, first out) concept for UseLineValid
        function latest = popUseLineValid(obj),
            latest = obj.popBoolean('UseLineValid', wit_io_pref_get('wip_UseLineValid', true)); % With default
        end
        function pushUseLineValid(obj, latest),
            obj.pushBoolean('UseLineValid', latest);
        end
        
        % LIFO (last in, first out) concept for AutoCreateObj
        function latest = popAutoCreateObj(obj),
            latest = obj.popBoolean('AutoCreateObj', wit_io_pref_get('wip_AutoCreateObj', true)); % With default
        end
        function pushAutoCreateObj(obj, latest),
            obj.pushBoolean('AutoCreateObj', latest);
        end
        
        % LIFO (last in, first out) concept for AutoCopyObj
        function latest = popAutoCopyObj(obj),
            latest = obj.popBoolean('AutoCopyObj', wit_io_pref_get('wip_AutoCopyObj', true)); % With default
        end
        function pushAutoCopyObj(obj, latest),
            obj.pushBoolean('AutoCopyObj', latest);
        end
        
        % LIFO (last in, first out) concept for AutoModifyObj
        function latest = popAutoModifyObj(obj),
            latest = obj.popBoolean('AutoModifyObj', wit_io_pref_get('wip_AutoModifyObj', true)); % With default
        end
        function pushAutoModifyObj(obj, latest),
            obj.pushBoolean('AutoModifyObj', latest);
        end
        
        
        
        % Open Project Manager with the given parameters
        O_wid = manager(obj, varargin);
        
        % File writer
        write(obj, varargin);
        
        % Update Data-property according to Tree-property contents
        update(obj);
        
        % Destroy duplicate transformations 
        destroy_duplicate_Transformations(obj);
        
        % Remove saved Viewer-settings
        destroy_all_Viewers(obj);
        reset_Viewers(obj); % Deprecated version! Use destroy_all_Viewers.m instead.
        
        % Helper functions for adding, removing and finding wid-objects
        O_wid = find_Data(obj, ID);
        
        % Transformations and interpretations (project version)
        [ValueUnit, varargout] = transform_forced(obj, S, varargin);
        [ValueUnit, varargout] = interpret_forced(obj, S, Unit_new, Unit_old, varargin);
    end
    
    %% PRIVATE METHODS
    methods (Access = private)
        % Update Tree- and Data-properties according to wit Tree object changes
        wip_update_Tree(obj);
        wip_update_Data(obj, isObjectBeingDestroyed);
        
        % GENERIC BOOLEAN LIFO (last in, first out) concept
        function latest = popBoolean(obj, field, default),
            if isempty(obj),
                latest = default(end); % Return (last) default value if an empty wip
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
        
        % Get valid pairs within the given wit Tree objects
        [Pairs, Roots] = get_Data_DataClassName_pairs(O_wit);
        [Pairs, Roots] = get_Viewer_ViewerClassName_pairs(O_wit);
        
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
