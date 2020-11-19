% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% NOTE: When working with multiple objects and temporary wip states, then
% remember to push same state for each object before calling this function.
function [obj, N_bests, Datas] = unpattern_video_stitching(obj, varargin),
    % Parse input
    B_valid = cellfun(@(str) strcmp(str, 'TDBitmap'), {obj.Type});
    if any(~B_valid),
        warning('Discarding all %d non-TDBitmaps from the given objects.', sum(~B_valid));
    end
    obj = obj(B_valid); % Discard all non-TDBitmap
    
    Datas = cell(size(obj));
    N_bests = nan(size(obj));
    
    % Check if TDText was specified and keep only valid objects
    TDText = WITio.parse.varargin_dashed_str_datas('TDText', varargin);
    TDText = TDText(cellfun(@(x) isa(x, 'WITio.wid'), TDText)); % Keep only wid
    TDText = cellfun(@(x) x(:), TDText, 'UniformOutput', false); % Force to column vectors
    TDText = cat(1, TDText{:}); % Merge column vectors to a single column vector
    if ~isempty(TDText), TDText = TDText(strcmp({TDText.Type}, 'TDText')); end % Keep only TDText
    if ~isempty(TDText) && numel(TDText) ~= numel(obj),
        error('Number of TDText objects (= %d) must match with the number of TDBitmap objects (= %d)!', numel(TDText), numel(obj));
    end
    
    % Call a helper function
    for ii = 1:numel(obj),
        % Pop states for each object (even if not used to avoid push-pop bugs)
        AutoCopyObj = obj(ii).Project.popAutoCopyObj; % Get the latest value (may be temporary or permanent or default)
        AutoModifyObj = obj(ii).Project.popAutoModifyObj; % Get the latest value (may be temporary or permanent or default)
        
        % Get the related TDText object (or error)
        if ~isempty(TDText), O_Text = TDText(ii);
        else, O_Text = obj(ii).Project.find_Data(obj(ii).Id+1); end % Next object after TDBitmap should be the related TDText object
        if isempty(O_Text) || ~strcmp(O_Text.Type, 'TDText'),
            error('Cannot find the related TDText object at index %d! Consider using ''-TDText''-functionality.', ii);
        end
        
        % Search for the Video Stitching info
        T = O_Text.Data;
        str_x = 'Number of Stitching Images X';
        str_y = 'Number of Stitching Images Y';
        B_X = cellfun(@(str) strncmp(str, str_x, numel(str_x)), T(:,1));
        B_Y = cellfun(@(str) strncmp(str, str_y, numel(str_y)), T(:,1));
        if sum(B_X) ~= 1 || sum(B_Y) ~= 1 || size(T,2) < 2,
            error('Cannot find ''%s'' or ''%s'' or their values in the related TDText object at index %d!', str_x, str_y, ii);
        end
        N_X = str2double(T{B_X,2});
        N_Y = str2double(T{B_Y,2});
        
        % Unpattern the Video Stitching image
        [Datas{ii}, N_bests(ii), cropIndices] = WITio.wid.unpattern_video_stitching_helper(obj(ii).Data, [N_X N_Y], varargin{:});
        
        % Copy the object if permitted
        if AutoCopyObj, obj(ii) = obj(ii).copy(); end
        
        % Modify the object (or its copy) if permitted
        if AutoModifyObj,
            obj(ii).Data = Datas{ii};
            obj(ii).Name = sprintf('Pattern Removal<%s', obj(ii).Name);
        end
        
        % Crop image transformations if needed
        if ~isempty(cropIndices),
            obj(ii).Project.pushAutoCopyObj(false); % Temporarily don't allow copying
            obj(ii).Project.pushAutoModifyObj(true); % Temporarily allow modifying
            obj(ii).crop(cropIndices(1), cropIndices(2), cropIndices(3), cropIndices(4), [], [], [], [], true);
        end
    end
end
