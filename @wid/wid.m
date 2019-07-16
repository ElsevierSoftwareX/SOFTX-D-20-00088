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
    % Hidden constant to reduce calls to moderately used wid.empty
    properties (Constant, Hidden)
        % Using wid.Empty is up to 30 times faster than wid.empty
        Empty = wid.empty; % Call wid.empty only once
    end
    
	properties (Dependent) % Everything rely on the underlying wit-classes
        Type;
		Name;
        Data;
        Info;
        DataTree;
        Version;
        Id;
        ImageIndex;
        OrdinalNumber;
        SubType;
        Links;
        AllLinks;
    end
	
    properties (SetAccess = private)
        Tag = struct.empty; % Either empty OR contains all the fields defined in wid-constructor
    end
    
    properties
        Project = wip.empty;
    end
    
    %% PUBLIC METHODS
    methods
        % CONSTRUCTOR
        function obj = wid(O_wit),
            % Loops through each element in O_wit array. It checks whether
            % the element points directly to a specific Data/DataClassName
            % (or its children) or not. If yes, then it only adds that as
            % new wid. If no, then it adds all found Data/DataClassName
            % pairs as new wid.
            
            if nargin == 0, % Create minimal TDGraph data
                obj.destroy(); % Destroy the created template
                obj = wid.new_Graph();
                return;
            end
            
            % Get valid tag pairs
            Pairs = wip.get_Data_DataClassName_pairs(O_wit);
            
            % Loop the found pairs to construct wids
            N_pairs = size(Pairs, 1);
            if N_pairs == 0,
                obj.destroy(); % Destroy the created template
                obj = wid.Empty;
            else,
                if N_pairs > 1, % Avoid endless loop
                    obj(N_pairs,1) = wid(); % Preallocate the array first
                end
                for ii = 1:N_pairs,
                    obj(ii).Tag(1).Root = Pairs(ii,1).Root;
                    obj(ii).Tag(1).RootVersion = Pairs(ii,1).Root.search('Version', {'WITec (Project|Data)'});
                    obj(ii).Tag(1).DataClassName = Pairs(ii,1);
                    obj(ii).Tag(1).Data = Pairs(ii,2);
                    obj(ii).Tag(1).Caption = Pairs(ii,2).search('Caption', 'TData', {'^Data \d+$'});
                    obj(ii).Tag(1).Id = Pairs(ii,2).search('ID', 'TData', {'^Data \d+$'});
                    obj(ii).Tag(1).ImageIndex = Pairs(ii,2).search('ImageIndex', 'TData', {'^Data \d+$'});
                end
            end
        end
        
        % GET/SET OF DEPENDENT PROPERTIES
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
        
        function Info = get.Info(obj),
            Info = obj.wid_Info_get();
        end
        
        function set.Info(obj, Info),
            obj.wid_Info_set(Info);
        end
        
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
        
        function SubType = get.SubType(obj),
            SubType = obj.wid_SubType_get();
        end
        
        function set.SubType(obj, SubType),
            obj.wid_SubType_set(SubType);
        end
        
        % Struct of linked wid-classes
        function Links = get.Links(obj),
            Links = struct.empty;
            if isfield(obj.Tag, 'Data'),
                Tag_Id = obj.Tag.Data.regexp('^[^<]+ID(<[^<]*)*$'); % Should not match with ID under TData!
                strs = get_valid_and_unique_names({Tag_Id.Name}); % Convert all wit Names to struct-compatible versions
                for ii = 1:numel(Tag_Id),
                    if Tag_Id(ii).Data ~= 0, % Ignore if zero
                        Links(1).(strs{ii}) = obj.Project.find_Data(Tag_Id(ii).Data);
                    end
                end
            end
        end
        
        % Same as Links but includes also the Links of Links and so on.
        function AllLinks = get.AllLinks(obj),
            Links = obj.Links;
            N = fieldnames(Links);
            C = struct2cell(Links);
            ii = 1;
            while ii <= numel(C),
                if isempty(C{ii}), NewLinks = struct();
                else, NewLinks = C{ii}.Links; end
                NewN = cellfun(@(x) [N{ii} '_' x], fieldnames(NewLinks), 'UniformOutput', false);
                NewC = struct2cell(NewLinks);
                if ~isempty(NewN), N = [N; NewN]; end
                if ~isempty(NewC), C = [C; NewC]; end
                ii = ii + 1;
            end
            AllLinks = cell2struct(C, N, 1);
        end
        
        
        
        %% OTHER PUBLIC METHODS
        % Object plotting
        plot(obj, varargin);
        
        % Object copying, destroying, writing
        new = copy(obj); % Copy-method
        copy_Links(obj); % Copy linked objects (i.e. transformations and interpretations) and relink
        destroy(obj); % Destructor-method
        destroy_Links(obj); % Destroy links to objects (i.e. transformations and interpretations)
        write(obj, File); % Ability to write selected objects to *.WID-format
        
        % Merge multiple object Data or Graph together (if possible)
        Data_merged = merge_Data(obj, dim);
        Info_Graph_merged = merge_Info_Graph(obj);
        
        % Get object Html-name, which includes the data type icon
        HtmlName = get_HtmlName(obj, isWorkspaceOptimized);
        
        % Reduce object Data
        [Data_cropped, Graph_cropped] = crop_Graph(obj, ind_range, Data_cropped, Graph_cropped);
        [Data_reduced, Graph_reduced] = reduce_Graph(obj, ind_range, Data_reduced, Graph_reduced); % DEPRECATED! USE ABOVE INSTEAD!
        [obj, Data_cropped, X_cropped, Y_cropped, Graph_cropped, Z_cropped] = crop(obj, ind_X_begin, ind_X_end, ind_Y_begin, ind_Y_end, ind_Graph_begin, ind_Graph_end, ind_Z_begin, ind_Z_end);
        [obj, Data_reduced, X_reduced, Y_reduced, Graph_reduced, Z_reduced] = reduce(obj, ind_X_begin, ind_X_end, ind_Y_begin, ind_Y_end, ind_Graph_begin, ind_Graph_end, ind_Z_begin, ind_Z_end); % DEPRECATED! USE ABOVE INSTEAD!
        [obj, Data_range, Graph_range, Data_range_bg] = filter_bg(obj, varargin);
        
        % Filter object Data
        % If obj.Project.AutoCreateObj == false, then isempty(new_obj) == true.
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
        [Data_range, Graph_range, Data_range_bg, range] = reduce_Graph_with_bg_helper(Data, Graph, range, bg_avg_lower, bg_avg_upper); % DEPRECATED! USE ABOVE INSTEAD!
        [Graph, Data, W, D] = spectral_stitch_helper(Graphs_nm, Datas, isdebug);
    end
    
    %% PRIVATE METHODS
    methods (Access = private)
        Data = wid_get_LineValid(obj, Data);
        
        Data = wid_get_DataType(obj, Data);
        Data = wid_set_DataType(obj, Data);
        
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
        wid_Info_set(obj, in);
        
        out = wid_SubType_get(obj);
        wid_SubType_set(obj, in);
    end
end
