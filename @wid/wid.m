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

% Class for project datas
classdef wid < handle, % Since R2008a
    %% MAIN PROPERTIES
    % Everything rely on the underlying wit-classes
    properties (SetAccess = private, Dependent) % READ-ONLY, DEPENDENT
        File; % Data-specific full file name
    end
    properties (Dependent) % READ-WRITE, DEPENDENT
        Name;
        Data;
        Type;
    end
    
    %% OTHER PROPERTIES
    % Everything rely on the underlying wit-classes
    properties (Dependent) % READ-WRITE, DEPENDENT
        Version;
    end
    properties (SetAccess = private, Dependent) % READ-WRITE, DEPENDENT
        Info;
    end
    properties (Dependent) % READ-WRITE, DEPENDENT
        DataTree;
        Id;
        ImageIndex;
        OrdinalNumber;
        SubType;
    end
    properties (SetAccess = private, Dependent) % READ-ONLY, DEPENDENT
        LinksToOthers;
        AllLinksToOthers;
        LinksToThis;
        AllLinksToThis;
    end
    properties (SetAccess = private) % READ-ONLY
        Tag = struct.empty; % Either empty OR contains all the fields defined in wid-constructor
    end
    properties % READ-WRITE
        Project = wip.empty;
    end
    
    properties (SetAccess = private, Hidden) % READ-ONLY, HIDDEN
        OnDeleteUnwrap = false;
    end
    
    %% PUBLIC METHODS
    methods
        % CONSTRUCTOR
        function obj = wid(SizeOrTreeOrProject),
            % Loops through each element in O_wit array. It checks whether
            % the element points directly to a specific Data/DataClassName
            % (or its children) or not. If yes, then it only adds that as
            % new wid. If no, then it adds all found Data/DataClassName
            % pairs as new wid.
            
            persistent isSize;
            if isempty(isSize), isSize = false; end
            
            if nargin == 0, % Create minimal TDGraph data
                if ~isSize, obj = wid.new_Graph(); end
                return;
            end
            
            % SPECIAL CASE: Empty wid object
            if isempty(SizeOrTreeOrProject),
                obj = obj([]); % wid.empty
                return;
            elseif isnumeric(SizeOrTreeOrProject),
                isSize = true;
                if numel(SizeOrTreeOrProject) == 1, SizeOrTreeOrProject(2) = SizeOrTreeOrProject; end
                obj(prod(SizeOrTreeOrProject),1) = wid();
                obj = reshape(obj, SizeOrTreeOrProject);
                isSize = false;
                return;
            end
            
            try,
                % Validate the given input
                if isa(SizeOrTreeOrProject, 'wit'),
                    Tree = SizeOrTreeOrProject;
                    Roots = unique([Tree.Root]);
                    if numel(Roots) ~= 1,
                        error('Provide a wit Tree object array with only one common Root!');
                    end
                    setProjectHere = false;
                elseif isa(SizeOrTreeOrProject, 'wip') && numel(SizeOrTreeOrProject) == 1,
                    Project = SizeOrTreeOrProject;
                    Tree = Project.Tree;
                    setProjectHere = true;
                else,
                    error('Provide either a wit Tree object array or a wip Project object!');
                end
                
                % Get valid tag pairs
                Pairs = wip.get_Data_DataClassName_pairs(Tree);
                
                % Stop if no valid pairs found
                N_pairs = size(Pairs, 1);
                if N_pairs == 0,
                    obj = obj([]); % wid.empty
                    return;
                end
                
                % Loop the found pairs to construct wids
                obj = wid([N_pairs 1]); % Preallocate the array first
                for ii = 1:N_pairs,
                    DataClassName = Pairs(ii,1);
                    Data = Pairs(ii,2);
                    Root = DataClassName.Root;
                    obj(ii).Tag(1).Root = Root;
                    obj(ii).Tag(1).RootVersion = Root.search_children('Version');
                    obj(ii).Tag(1).DataClassName = DataClassName;
                    obj(ii).Tag(1).Data = Data;
                    [obj(ii).Tag(1).Caption, obj(ii).Tag(1).Id, obj(ii).Tag(1).ImageIndex] = Data.search_children('TData').search_children('Caption', 'ID', 'ImageIndex');
                end

                % Find Project
                if ~setProjectHere, Project = wip(obj); end
                
                for ii = 1:N_pairs,
                    obj(ii).Project = Project;
                end
            catch me, % Handle invalid or deleted object -case
                switch me.identifier,
                    case 'MATLAB:class:InvalidHandle', obj = obj([]); % wid.empty
                    otherwise, rethrow(me);
                end
            end
        end
        
        function delete(obj),
            if obj.OnDeleteUnwrap, return; end % Do nothing if to unwrap
            % Update its tree
            Tag = obj.Tag;
            if ~isempty(Tag),
                Tag_Root = Tag.Root;
                Tag_Data = Tag.Data;
                Tag_DataClassName = Tag.DataClassName;
                % Delete its tree tags on exit after obj has been deleted!
                % (Required to avoid hard-to-decode event-based bugs!)
                ocu = onCleanup(@() delete([Tag_DataClassName Tag_Data]));
                % Disable the Project related wit-class ObjectModified events
                if isvalid(Tag_Root), Tag_Root.disableObjectModified; end
                if isvalid(Tag_Data), Tag_Data.disableObjectModified; end
                % Try update its tree root counters
                if isvalid(Tag_Data)
                    Tag_NV = Tag_Data.Parent.search_children('NumberOfData');
                    if ~isempty(Tag_NV),
                        Tag_NV.Data = Tag_NV.Data - 1; % Reduce the number by one
                    end
                end
            end
            % Update its project
            Project = obj.Project;
            if ~isempty(Project) && isvalid(Project) && isvalid(Tag_Data) && isvalid(Tag_DataClassName),
                % Remove this from the project
                O_wid = Project.Data;
                O_wid = O_wid(O_wid ~= obj);
                % Try update the ordinal numberings
                ON = obj.OrdinalNumber;
                for ii = 1:numel(O_wid),
                    ON_ii = O_wid(ii).OrdinalNumber;
                    if ON_ii > ON, O_wid(ii).OrdinalNumber = ON_ii - 1; end
                end
            end
            % Useful resources:
            % https://se.mathworks.com/help/matlab/matlab_oop/handle-class-destructors.html
            % https://se.mathworks.com/help/matlab/matlab_oop/example-implementing-linked-lists.html
            % https://blogs.mathworks.com/loren/2013/07/23/deconstructing-destructors/
        end
        
        % Delete wid Data objects without deleting underlying wit Tree objects
        function delete_wrapper(obj),
            for ii = 1:numel(obj),
                try, obj(ii).OnDeleteUnwrap = true;
                catch, end % Handle invalid or deleted object -case
            end
            delete(obj);
        end
        
        
        
        %% MAIN PROPERTIES
        % File (READ-ONLY, DEPENDENT)
        function File = get.File(obj),
            File = '';
            if ~isempty(obj.Tag) && ~isempty(obj.Tag.Data),
                % This can differ from obj.Tag.Root.File, when wid-object
                % content has been merged from another project file to this
                % project file using wip.append-function, which uses copy-
                % function of wit-class.
                File = obj.Tag.Data.File;
            end
        end
        
        % Name (READ-WRITE, DEPENDENT)
        function Name = get.Name(obj),
            Name = '';
            if ~isempty(obj.Tag) && ~isempty(obj.Tag.Caption),
                Name = obj.Tag.Caption.Data;
            end
        end
        function set.Name(obj, Name),
            if ~isempty(obj.Tag) && ~isempty(obj.Tag.Caption),
                obj.Tag.Caption.Data = char(Name);
            end
        end
        
        % Data (READ-WRITE, DEPENDENT)
        function Data = get.Data(obj),
            Data = [];
            if ~isempty(obj.Tag) && ~isempty(obj.Tag.Data),
                Data = obj.wid_Data_get();
            end
        end
        function set.Data(obj, Data),
            if ~isempty(obj.Tag) && ~isempty(obj.Tag.Data),
                obj.wid_Data_set(Data);
            end
        end
        
        % Type (READ-WRITE, DEPENDENT)
        function Type = get.Type(obj),
            Type = '';
            if ~isempty(obj.Tag) && ~isempty(obj.Tag.DataClassName),
                Type = obj.Tag.DataClassName.Data;
            end
        end
        function set.Type(obj, Type),
            if ~isempty(obj.Tag) && ~isempty(obj.Tag.DataClassName),
                obj.Tag.DataClassName.Data = char(Type);
            end
        end
        
        %% OTHER PROPERTIES
        % Version (READ-WRITE, DEPENDENT)
        function Version = get.Version(obj),
            Version = [];
            if ~isempty(obj.Tag) && ~isempty(obj.Tag.RootVersion),
                Version = obj.Tag.RootVersion.Data;
            end
        end
        function set.Version(obj, Version),
            if ~isempty(obj.Tag) && ~isempty(obj.Tag.RootVersion),
                obj.Tag.RootVersion.Data = int32(Version);
            end
        end
        
        % Info (READ-ONLY, DEPENDENT)
        function Info = get.Info(obj),
            Info = obj.wid_Info_get();
        end
        
        % DataTree (READ-WRITE, DEPENDENT)
        function DataTree = get.DataTree(obj),
            DataTree = struct.empty;
            if ~isempty(obj.Tag) && ~isempty(obj.Tag.Data),
                DataTree = obj.wid_DataTree_get();
            end
        end
        function set.DataTree(obj, DataTree),
            if ~isempty(obj.Tag) && ~isempty(obj.Tag.Data),
                obj.wid_DataTree_set(DataTree);
            end
        end
        
        % Id (READ-WRITE, DEPENDENT)
        function Id = get.Id(obj),
            Id = [];
            if ~isempty(obj.Tag) && ~isempty(obj.Tag.Id),
                Id = obj.Tag.Id.Data;
            end
        end
        function set.Id(obj, Id),
            if ~isempty(obj.Tag) && ~isempty(obj.Tag.Id),
                obj.Tag.Id.Data = int32(Id);
            end
        end
        
        % ImageIndex (READ-WRITE, DEPENDENT)
        function ImageIndex = get.ImageIndex(obj),
            ImageIndex = [];
            if ~isempty(obj.Tag) && ~isempty(obj.Tag.ImageIndex),
                ImageIndex = obj.Tag.ImageIndex.Data;
            end
        end
        function set.ImageIndex(obj, ImageIndex),
            if ~isempty(obj.Tag) && ~isempty(obj.Tag.ImageIndex),
                obj.Tag.ImageIndex.Data = int32(ImageIndex);
            end
        end
        
        % OrdinalNumber (READ-WRITE, DEPENDENT)
        function OrdinalNumber = get.OrdinalNumber(obj),
            OrdinalNumber = [];
            if ~isempty(obj.Tag), % Sufficient test even if DataClassName or Data were empty!
                OrdinalNumber = sscanf(obj.Tag.DataClassName.Name, '%*s %d');
                if OrdinalNumber ~= sscanf(obj.Tag.Data.Name, '%*s %d'),
                    OrdinalNumber = []; % Inconsistent ordinal numbering!
                end
            end
        end
        function set.OrdinalNumber(obj, OrdinalNumber),
            if ~isempty(obj.Tag), % Sufficient test even if DataClassName or Data were empty!
                obj.Tag.DataClassName.Name = sprintf('DataClassName %d', OrdinalNumber);
                obj.Tag.Data.Name = sprintf('Data %d', OrdinalNumber);
            end
        end
        
        % SubType (READ-WRITE, DEPENDENT)
        function SubType = get.SubType(obj),
            SubType = obj.wid_SubType_get();
        end
        function set.SubType(obj, SubType),
            obj.wid_SubType_set(SubType);
        end
        
        % LinksToOthers (READ-ONLY, DEPENDENT)
        function LinksToOthers = get.LinksToOthers(obj),
            % Struct of linked wid-classes
            LinksToOthers = struct.empty;
            if isfield(obj.Tag, 'Data'),
                Tag_Id = obj.Tag.Data.regexp('^[^<]+ID(<[^<]*)*$'); % Should not match with ID under TData!
                strs = get_valid_and_unique_names({Tag_Id.Name}); % Convert all wit Names to struct-compatible versions
                for ii = 1:numel(Tag_Id),
                    if Tag_Id(ii).Data ~= 0, % Ignore if zero
                        LinksToOthers(1).(strs{ii}) = obj.Project.find_Data(Tag_Id(ii).Data);
                    end
                end
            end
        end
        
        % AllLinksToOthers (READ-ONLY, DEPENDENT)
        function AllLinksToOthers = get.AllLinksToOthers(obj),
            % Same as LinksToOthers but includes also the LinksToOthers of LinksToOthers and so on.
            NewLinksToOthers = obj.LinksToOthers;
            N = fieldnames(NewLinksToOthers);
            C = struct2cell(NewLinksToOthers);
            ii = 1;
            while ii <= numel(C),
                if isempty(C{ii}), NewLinksToOthers = struct();
                else, NewLinksToOthers = C{ii}.LinksToOthers; end
                NewN = cellfun(@(x) [N{ii} '_' x], fieldnames(NewLinksToOthers), 'UniformOutput', false);
                NewC = struct2cell(NewLinksToOthers);
                if ~isempty(NewN), N = [N; NewN]; end
                if ~isempty(NewC), C = [C; NewC]; end
                ii = ii + 1;
            end
            AllLinksToOthers = cell2struct(C, N, 1);
        end
        
        % LinksToThis (READ-ONLY, DEPENDENT)
        function LinksToThis = get.LinksToThis(obj),
            % Array of linked wid-classes
            linked_tags = wid.find_linked_wits_to_this_wid(obj);
            owner_ids = wid.find_owner_id_to_this_wit(linked_tags);
            LinksToThis = obj.Project.find_Data(owner_ids);
        end
        
        % AllLinksToThis (READ-ONLY, DEPENDENT)
        function AllLinksToThis = get.AllLinksToThis(obj),
            % Same as LinksToThis but includes also the LinksToThis of LinksToThis and so on.
            AllLinksToThis = wid.empty;
            if isfield(obj.Tag, 'Data'),
                % First get the object's wit-tree parent tag
                tags = [obj.Tag.Data.Parent wit.empty];
                % List all the project's ID-tags (except NextDataID and
                % ID<TData) under the Data tree tag
                tags = tags.regexp('^(?!NextDataID)([^<]+ID(List)?(<[^<]*)*(<Data(<WITec (Project|Data))?)?$)');
                ids = obj.Id;
                ii = 1;
                while ii <= numel(ids),
                    % Keep only those ID-tags, which point to this object
                    subtags = tags.match_by_Data_criteria(@(x) any(x == ids(ii)));
                    % Get their owner wid-objects' IDs
                    subids = wid.find_owner_id_to_this_wit(subtags);
                    % Detect duplicates (to avoid circular loops) and
                    % append without them
                    B_duplicates = any(bsxfun(@eq, ids, subids(:)), 2);
                    ids = [ids subids(~B_duplicates)];
                    % Proceed to next id
                    ii = ii + 1;
                end
                % Exclude this object
                ids = ids(2:end);
                % Get the wid-objects of the tags
                AllLinksToThis = obj.Project.find_Data(ids);
            end
        end
        
        
        
        %% OTHER PUBLIC METHODS
        % Object plotting
        h = plot(obj, varargin);
        h_position = plot_position(obj, FigAxNeither, varargin); % To show position of other objects on obj
        h_scalebar = plot_scalebar(obj, FigAxNeither, varargin);
        varargout = manager(obj, varargin); % A wrapper method that shows the given objects via Project Manager view.
        
        % Object copying, destroying, writing
        new = copy(obj); % Copy-method
        varargout = copy_Others_if_shared_and_unshare(obj, varargin); % Copy given shared linked objects and relink
        copy_LinksToOthers(obj); % Copy linked objects (i.e. transformations and interpretations) and relink
        copy_Links(obj); % Deprecated version! Use copy_LinksToOthers
        destroy(obj); % Deprecated! Use delete instead!
        destroy_LinksToOthers(obj); % Destroy links to objects (i.e. transformations and interpretations)
        destroy_Links(obj); % Deprecated version! Use destroy_LinksToOthers
        write(obj, File); % Ability to write selected objects to *.WID-format
        
        % Merge multiple object Data or Graph together (if possible)
        Data_merged = merge_Data(obj, dim);
        Info_Graph_merged = merge_Info_Graph(obj);
        
        % Get object Html-name, which includes the data type icon
        HtmlName = get_HtmlName(obj, isWorkspaceOptimized);
        
        % Reduce object Data
        [Data_cropped, Graph_cropped] = crop_Graph(obj, ind_range, Data_cropped, Graph_cropped);
        [obj, Data_cropped, X_cropped, Y_cropped, Graph_cropped, Z_cropped] = crop(obj, ind_X_begin, ind_X_end, ind_Y_begin, ind_Y_end, ind_Graph_begin, ind_Graph_end, ind_Z_begin, ind_Z_end, isDataCropped);
        [obj, Data_range, Graph_range, Data_range_bg] = filter_bg(obj, varargin);
        
        % Filter object Data
        % If obj.Project.popAutoCreateObj == false, then isempty(new_obj) == true.
        [new_obj, varargout] = filter_fun(obj, fun, str_fun, varargin); % Generic (but not yet for 4-D TDGraph!)
        [new_obj, Sum] = filter_sum(obj, varargin);
        [new_obj, Min] = filter_min(obj, varargin);
        [new_obj, Max] = filter_max(obj, varargin);
        [new_obj, CoM] = filter_center_of_mass(obj, varargin);
        [new_obj, I, Pos, Fwhm, I0, R2, Residuals, Fit] = filter_lorentzian(obj, varargin); % If varargin{1} is a cell, then it is treated as an input to the fitting algorithm!
        [new_obj, I, Pos, Fwhm, I0, R2, Residuals, Fit] = filter_gaussian(obj, varargin); % If varargin{1} is a cell, then it is treated as an input to the fitting algorithm!
        [new_obj, I, Pos, Fwhm_L, I0, Fwhm_G, R2, Residuals, Fit] = filter_voigtian(obj, varargin); % If varargin{1} is a cell, then it is treated as an input to the fitting algorithm!
        
        % Spatial filter object Data
        [obj, Average] = spatial_average(obj);
        
        % Spectral stitching
        [new_obj, Graph, Data, W, D] = spectral_stitch(obj, varargin); % Add '-debug' as input to see debug plots
        
        % Unpattern Video Stitching images
        [obj, N_bests, Datas] = unpattern_video_stitching(obj, varargin); % Add '-debug' as input to see debug plots
        
        % Masking tools
        [obj, Data_NaN_masked] = image_mask(obj, varargin);
        [new_obj, image_mask] = image_mask_editor(obj, image_mask);
        
        % Histogram tools
        [new_obj, Bin_Counts, Bin_Centers] = histogram(obj, N_bins, lower_quantile, upper_quantile, range_scaling);
        
        % Interpret various coordinates
        Graph = interpret_Graph(obj, Unit_new, Graph);
        X = interpret_X(obj, Unit_new, X);
        Y = interpret_Y(obj, Unit_new, Y);
        Z = interpret_Z(obj, Unit_new, Z);
    end
    
    %% STATIC PUBLIC METHODS
    methods (Static)
        % File reader
        varargout = read(varargin); % Simple wrapper for wip.read
        
        % Constructor WID-formatted WIT-tree
        O_wit = new(Version); % WITec Data WIT-tree
        
        % Constructors for various types of objects
        obj = new_Bitmap(O_wit);
        obj = new_Graph(O_wit);
        obj = new_Image(O_wit);
        obj = new_Interpretation_Space(O_wit);
        obj = new_Interpretation_Spectral(O_wit);
        obj = new_Interpretation_Time(O_wit);
        obj = new_Interpretation_Z(O_wit);
        obj = new_Text(O_wit);
        obj = new_Transformation_Linear(O_wit);
        obj = new_Transformation_LUT(O_wit, LUTSize);
        obj = new_Transformation_Space(O_wit);
        obj = new_Transformation_Spectral(O_wit);
        
        % Other wit-tree related helper functions
        Ids = find_owner_id_to_this_wit(O_wit);
        O_wit = find_linked_wits_to_this_wid(obj);
        
        % DataTree formats
        format = DataTree_format_TData(Version_or_obj);
        
        format = DataTree_format_TDInterpretation(Version_or_obj);
        format = DataTree_format_TDSpaceInterpretation(Version_or_obj);
        format = DataTree_format_TDSpectralInterpretation(Version_or_obj);
        format = DataTree_format_TDTimeInterpretation(Version_or_obj);
        format = DataTree_format_TDZInterpretation(Version_or_obj);
        
        format = DataTree_format_TDTransformation(Version_or_obj);
        format = DataTree_format_TDLinearTransformation(Version_or_obj);
        format = DataTree_format_TDLUTTransformation(Version_or_obj);
        format = DataTree_format_TDSpaceTransformation(Version_or_obj);
        format = DataTree_format_TDSpectralTransformation(Version_or_obj);
        
        %% OTHER PUBLIC METHODS
        [Data_range, Graph_range, Data_range_bg, range] = crop_Graph_with_bg_helper(Data, Graph, range, bg_avg_lower, bg_avg_upper);
        h_image = plot_position_Image_helper(Ax, positions, color);
        h_line = plot_position_Line_helper(Ax, positions, color);
        h_point = plot_position_Point_helper(Ax, positions, color);
        h = plot_scalebar_helper(Ax, image_size, image_size_in_SU, image_SU, varargin);
        [Graph, Data, W, D] = spectral_stitch_helper(Graphs_nm, Datas, isdebug);
        [I_best, N_best, cropIndices] = unpattern_video_stitching_helper(I, N_SI_XY, varargin); % Add '-debug' as input to see debug plots
    end
    
    %% PRIVATE METHODS
    methods (Access = private)
        Data = wid_Data_get_LineValid(obj, Data);
        
        Data = wid_Data_get_DataType(obj, Data);
        Data = wid_Data_set_DataType(obj, Data);
        
        out = wid_DataTree_get(obj, varargin); % For (un)formatted structs
        wid_DataTree_set(obj, in, varargin); % For (un)formatted structs
        
        out = wid_Data_get(obj);
        out = wid_Data_get_Bitmap(obj);
        out = wid_Data_get_Graph(obj);
        out = wid_Data_get_Image(obj);
        out = wid_Data_get_Text(obj);
        
        wid_Data_set(obj, in);
        wid_Data_set_Bitmap(obj, in);
        wid_Data_set_Graph(obj, in);
        wid_Data_set_Image(obj, in);
        wid_Data_set_Text(obj, in);
        
        out = wid_Info_get(obj); % Returns struct for TDBitmap, TDGraph and TDImage
        
        out = wid_SubType_get(obj);
        wid_SubType_set(obj, in);
    end
end
