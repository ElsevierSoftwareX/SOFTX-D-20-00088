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
        Data = WITio.obj.wid.empty;
    end
    properties (Dependent) % READ-WRITE, DEPENDENT
        Type;
    end
    
    %% OTHER PROPERTIES
    properties (Dependent) % READ-WRITE, DEPENDENT
        Version; % WIP/WID-file version. See 'README on WIT-tag formatting.txt'.
    end
    properties % READ-WRITE
        Tree = WITio.obj.wit.empty;
    end
    
    properties (SetAccess = private, Hidden) % READ-ONLY, HIDDEN
        TreeData = WITio.obj.wit.empty;
        TreeDataModifiedCount = [];
        wip_listener;
        TreeObjectBeingDestroyedListener;
        TreeObjectModifiedListener;
        DataObjectBeingDestroyedListener;
        DataObjectModifiedListener;
        isUpdatingData = false;
        isUpdatingTree = false;
    end
    
    properties % READ-WRITE
        % DataUnit, SpaceUnit, SpectralUnit or TimeUnit
        ForceDataUnit = '';
        ForceSpaceUnit = '';
        ForceSpectralUnit = '';
        ForceTimeUnit = '';
        % Configure writing behaviour
        OnWriteDestroyAllViewers = true; % If true, then removes all the Viewer windows (shown on the WITec software side). This avoids possible corruption of the modified files, because WITio mostly ignores Viewers.
        OnWriteDestroyDuplicateTransformations = true; % If true, then removes all the duplicate Transformations (and keeps the first one).
    end
    
    properties (Dependent) % READ-WRITE, DEPENDENT
        % The following properties are shared by all wip Project objects!
        AutoNanInvalid; % A feature of TDGraph and TDImage. If used, shows NaN where invalid.
        AutoCreateObj; % Automatically create a new object (whenever applicable). If false, then new_obj output should be empty.
        AutoCopyObj; % Automatically make a copy of the original object (whenever applicable). If false, then obj output should be originals.
        AutoModifyObj; % Automatically modify either the original object or its copy (whenever applicable). If false, then obj output should not be modified.
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
        ArbitraryUnit = WITio.obj.wip.interpret_StandardUnit('a.u.');
        DefaultSpaceUnit = WITio.obj.wip.interpret_StandardUnit('µm');
        DefaultSpectralUnit = WITio.obj.wip.interpret_StandardUnit('nm');
        DefaultTimeUnit = WITio.obj.wip.interpret_StandardUnit('s');
    end
    
    properties (Constant) % READ-ONLY, CONSTANT
        Projects = WITio.obj.handle_listener(); % Generates a shared Project listener
    end
    
    %% PUBLIC METHODS
    methods
        % CONSTRUCTOR
        function obj = wip(TreeOrData),
            if nargin == 0, TreeOrData = WITio.obj.wip.new(); end % Create minimal project
            
            % SPECIAL CASE: Empty wip object
            if isempty(TreeOrData),
                obj = obj([]); % WITio.obj.wip.empty
                return;
            end
            
            try,
                % Validate the given input
                if isa(TreeOrData, 'WITio.obj.wit') && numel(TreeOrData) == 1,
                    Tree = TreeOrData.Root;
                elseif isa(TreeOrData, 'WITio.obj.wid'),
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
                O_wip = WITio.obj.wip.Projects.match_any(@(O_wip) O_wip.Tree == Tree); % Due to syncronous link between Project and its Tree, Project's Tree is always Root AND never invalid/deleted!
                
                % Use already existing wip Project object or this
                if ~isempty(O_wip),
                    obj = O_wip;
                else,
                    obj.Tree = Tree;
                    % Enable tracking of this wip Project object
                    obj.wip_listener = WITio.obj.wip.Projects.add(obj);
                    % Get user preferences (or default values if not found)
                    obj.ForceDataUnit = WITio.tbx.pref.get('wip_ForceDataUnit', obj.ForceDataUnit);
                    obj.ForceSpaceUnit = WITio.tbx.pref.get('wip_ForceSpaceUnit', obj.ForceSpaceUnit);
                    obj.ForceSpectralUnit = WITio.tbx.pref.get('wip_ForceSpectralUnit', obj.ForceSpectralUnit);
                    obj.ForceTimeUnit = WITio.tbx.pref.get('wip_ForceTimeUnit', obj.ForceTimeUnit);
                    obj.OnWriteDestroyAllViewers = WITio.tbx.pref.get('wip_OnWriteDestroyAllViewers', obj.OnWriteDestroyAllViewers);
                    obj.OnWriteDestroyDuplicateTransformations = WITio.tbx.pref.get('wip_OnWriteDestroyDuplicateTransformations', obj.OnWriteDestroyDuplicateTransformations);
                    obj.AutoNanInvalid = WITio.tbx.pref.get('wip_AutoNanInvalid', obj.AutoNanInvalid);
                    obj.AutoCreateObj = WITio.tbx.pref.get('wip_AutoCreateObj', obj.AutoCreateObj);
                    obj.AutoCopyObj = WITio.tbx.pref.get('wip_AutoCopyObj', obj.AutoCopyObj);
                    obj.AutoModifyObj = WITio.tbx.pref.get('wip_AutoModifyObj', obj.AutoModifyObj);
                    % Enable link between Tree and Project
                    obj.TreeObjectBeingDestroyedListener = Tree.addlistener('ObjectBeingDestroyed', @(s,e) delete(obj));
                    obj.TreeObjectModifiedListener = Tree.addlistener('ObjectModified', @(s,e) wip_update_Tree(obj));
                    wip_update_Data(obj);
                end
            catch me, % Handle invalid or deleted object -case
                switch me.identifier,
                    case 'MATLAB:class:InvalidHandle', obj = obj([]); % WITio.obj.wid.empty
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
            Children_prior = [Tree_prior.Children WITio.obj.wit.empty];
            [names_prior, ind_prior] = sort({Children_prior.Name});
            Children_prior = Children_prior(ind_prior);
            
            % Generate new tree structure template
            Tree = WITio.obj.wit.empty;
            switch(Type),
                case 'WITec Project',
                    Tree = WITio.obj.wip.new(obj.Version);
                case 'WITec Data',
                    Tree = WITio.obj.wid.new(obj.Version);
                otherwise,
                    obj.Tree.Name = Type;
            end
            
            % Use the new tree structure if generated
            if ~isempty(Tree),
                % Sort posterior children by names
                Children = [Tree.Children WITio.obj.wit.empty];
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
            Version = WITio.obj.wip.get_Root_Version(obj.Tree);
        end
        function set.Version(obj, Version),
            WITio.obj.wip.set_Root_Version(obj.Tree, Version);
        end
        
        % Tree (READ-ONLY)
        function Tree = get.Tree(obj),
            Tree = obj.Tree; % Auto-updated by an event listener
        end
        
        % ForceDataUnit (READ-WRITE)
        function set.ForceDataUnit(obj, Value),
            if ~isempty(Value),
                try, Value = WITio.obj.wip.interpret('TDZInterpretation', Value); % Try interpret
                catch, Value = ''; end % Reset to empty on failure
            end
            obj.ForceDataUnit = Value;
        end
        
        % ForceSpaceUnit (READ-WRITE)
        function set.ForceSpaceUnit(obj, Value),
            if ~isempty(Value),
                try, Value = WITio.obj.wip.interpret('TDSpaceInterpretation', Value); % Try interpret
                catch, Value = ''; end % Reset to empty on failure
            end
            obj.ForceSpaceUnit = Value;
        end
        
        % ForceSpectralUnit (READ-WRITE)
        function set.ForceSpectralUnit(obj, Value),
            if ~isempty(Value),
                try, Value = WITio.obj.wip.interpret('TDSpectralInterpretation', Value); % Try interpret
                catch, Value = ''; end % Reset to empty on failure
            end
            obj.ForceSpectralUnit = Value;
        end
        
        % ForceTimeUnit (READ-WRITE)
        function set.ForceTimeUnit(obj, Value),
            if ~isempty(Value),
                try, Value = WITio.obj.wip.interpret('TDTimeInterpretation', Value); % Try interpret
                catch, Value = ''; end % Reset to empty on failure
            end
            obj.ForceTimeUnit = Value;
        end
        
        
        
        %% OTHER METHODS
        % LIFO (last in, first out) concept for AutoNanInvalid
        function latest = popUseLineValid(obj),
            warning('Deprecated call! Use globally dependent AutoNanInvalid-property instead!');
            latest = WITio.tbx.pref.get('wip_AutoNanInvalid', true); % With default
        end
        function pushUseLineValid(obj, latest),
            warning('Deprecated call! Use globally dependent AutoNanInvalid-property instead!');
            WITio.tbx.pref.set('wip_AutoNanInvalid', latest);
        end
        
        % LIFO (last in, first out) concept for AutoCreateObj
        function latest = popAutoCreateObj(obj),
            warning('Deprecated call! Use globally dependent AutoCreateObj-property instead!');
            latest = WITio.tbx.pref.get('wip_AutoCreateObj', true); % With default
        end
        function pushAutoCreateObj(obj, latest),
            warning('Deprecated call! Use globally dependent AutoCreateObj-property instead!');
            WITio.tbx.pref.set('wip_AutoCreateObj', latest);
        end
        
        % LIFO (last in, first out) concept for AutoCopyObj
        function latest = popAutoCopyObj(obj),
            warning('Deprecated call! Use globally dependent AutoCopyObj-property instead!');
            latest = WITio.tbx.pref.get('wip_AutoCopyObj', true); % With default
        end
        function pushAutoCopyObj(obj, latest),
            warning('Deprecated call! Use globally dependent AutoCopyObj-property instead!');
            WITio.tbx.pref.set('wip_AutoCopyObj', latest);
        end
        
        % LIFO (last in, first out) concept for AutoModifyObj
        function latest = popAutoModifyObj(obj),
            warning('Deprecated call! Use globally dependent AutoModifyObj-property instead!');
            latest = WITio.tbx.pref.get('wip_AutoModifyObj', true); % With default
        end
        function pushAutoModifyObj(obj, latest),
            warning('Deprecated call! Use globally dependent AutoModifyObj-property instead!');
            WITio.tbx.pref.set('wip_AutoModifyObj', latest);
        end
        
        function value = get.AutoNanInvalid(obj),
            value = WITio.tbx.pref.get('wip_AutoNanInvalid', true); % With default
        end
        function set.AutoNanInvalid(obj, value),
            WITio.tbx.pref.set('wip_AutoNanInvalid', value);
        end
        function value = get.AutoCreateObj(obj),
            value = WITio.tbx.pref.get('wip_AutoCreateObj', true); % With default
        end
        function set.AutoCreateObj(obj, value),
            WITio.tbx.pref.set('wip_AutoCreateObj', value);
        end
        function value = get.AutoCopyObj(obj),
            value = WITio.tbx.pref.get('wip_AutoCopyObj', true); % With default
        end
        function set.AutoCopyObj(obj, value),
            WITio.tbx.pref.set('wip_AutoCopyObj', value);
        end
        function value = get.AutoModifyObj(obj),
            value = WITio.tbx.pref.get('wip_AutoModifyObj', true); % With default
        end
        function set.AutoModifyObj(obj, value),
            WITio.tbx.pref.set('wip_AutoModifyObj', value);
        end
        
        
        
        % Open Project Manager with the given parameters
        O_wid = manager(obj, varargin);
        
        % File writer
        write(obj, varargin);
        
        % Update Data-property according to Tree-property contents
        update(obj); % DEPRECATED!
        
        % Destroy duplicate transformations 
        destroy_duplicate_Transformations(obj);
        
        % Remove saved Viewer-settings
        destroy_all_Viewers(obj);
        
        % Helper functions for adding, removing and finding wid-objects
        add_Data(obj, varargin); % DEPRECATED!
        destroy_Data(obj, varargin); % DEPRECATED!
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
