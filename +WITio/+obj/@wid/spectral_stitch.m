% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Spectral stitching of the given TDGraph objects into a large spectrum.
% Each TDGraph must be of same spatial size. Stitching of each individual
% overlap is linear, but, due to a product rule, becomes non-linear for
% more generalized case of multiple simultaneous overlaps. Linear case
% behaves like WITec's Spectral Stitching measurement scheme.

% WARNING! The related instrumental errors, if NOT corrected for, can lead
% to UNPHYSICAL stitching result in the overlapping regions, even if their
% apparent stitching result looks smooth!
function [new_obj, Graph, Data, W, D] = spectral_stitch(obj, varargin),
    % Pop states (even if not used to avoid push-pop bugs)
    AutoCreateObj = obj(1).Project.popAutoCreateObj; % Get the latest value (may be temporary or permanent or default)
    
    new_obj = WITio.obj.wid.empty;
    
    % Add obj(s) as varargin
    varargin = [{obj}; varargin(:)];
    
    % Test if '-debug' was given
    isdebug = WITio.fun.varargin_dashed_str.exists('debug', varargin);
    
    % Parse the input and keep only TDGraph wid objects
    bw_valid_wid = cellfun(@(x) isa(x, 'WITio.obj.wid'), varargin); % Test if wid
    varargin = varargin(bw_valid_wid); % Keep only wid
    varargin = cellfun(@(x) x(:), varargin, 'UniformOutput', false); % Force to column vectors
    O_wid = cat(1, varargin{:}); % Merge column vectors to a single column vector
    if ~isempty(O_wid),
        bw_valid_TDGraph = strcmp({O_wid.Type}, 'TDGraph'); % Test if TDGraph
        O_wid = O_wid(bw_valid_TDGraph); % Keep only TDGraph
    end
    
    N_TDGraph = numel(O_wid); % Number of TDGraph
    if N_TDGraph == 0, error('No TDGraph input!'); end % Test if TDGraphs OR ABORT
    
    % Store Datas and Graphs (in nm)
    Datas = reshape({O_wid.Data}, [], 1);
    Graphs_nm = cell(N_TDGraph, 1);
    for ii = 1:N_TDGraph,
        Graphs_nm{ii} = reshape(O_wid(ii).interpret_Graph('nm'), [], 1);
    end
    
    % Call a helper function
    [Graph, Data, W, D] = WITio.obj.wid.spectral_stitch_helper(Graphs_nm, Datas, isdebug);
    
    % Create new object if permitted
    obj = O_wid(1);
    if AutoCreateObj,
        new_obj = obj.copy(); % Copy first object, because all of them must be of same spatial size
        delete(new_obj.LinksToOthers.XTransformationID); % But destroy copied TDSpectralTransformation
        
        new_obj.Name = sprintf('Spectral Stitch[%d spectra]<%s', N_TDGraph, new_obj.Name); % Generate new name
        new_obj.Data = Data;
        
        new_SpectralT = WITio.obj.wid.new_Transformation_LUT(obj.Tag.Root, numel(Graph)); % This does not add newly created object to Project yet!
        new_SpectralT_Data = new_SpectralT.Data; % Get formatted struct once to speed-up
        new_SpectralT_Data.TDLUTTransformation.LUT = Graph;
        new_SpectralT_Data.TDLUTTransformation.LUTSize = numel(Graph); % Ignored by WITio, but used in WITec software
        new_SpectralT_Data.TDLUTTransformation.LUTIsIncreasing = true; % Ignored by WITio, but used in WITec software
        new_SpectralT.Data = new_SpectralT_Data; % Save all changes once

        new_obj.Tag.Data.regexp('^XTransformationID<TDGraph<', true).Data = new_SpectralT.Id; % Must be int32!
        
        % These were AUTOMATICALLY added to the wip Project object!
    end
end
