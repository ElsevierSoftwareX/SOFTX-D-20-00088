% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Display the content of the toolbox
function WITio(),
    folder_latest_WITio = WITio.tbx.path;
    WITio.fun.href_dir(WITio.tbx.path, [], @WITio_helper);
    
    function WITio_helper(),
        % Determine whether or not to use html links
        isDesktop = usejava('desktop'); % The html links are possible only if MATLAB is running in Desktop-mode
        
        p = path; % Get old path
        p_split = regexp(p, pathsep, 'split'); % Split by the path separator
        isThisToolbox = strncmp(p_split, folder_latest_WITio, numel(folder_latest_WITio)); % Find this toolbox
        if ~any(isThisToolbox),
            if isDesktop,
                fprintf('Cannot find this version in the MATLAB search path! Click <a href="matlab:WITio.tbx.rmpath_addpath(WITio.tbx.path);">here</a> to resolve it.\n\n');
            else,
                fprintf('Cannot find this version in the MATLAB search path! Executing WITio.tbx.rmpath_addpath(WITio.tbx.path); to resolve it.\n\n');
                WITio.tbx.rmpath_addpath(folder_latest_WITio);
                fprintf('\n');
            end
        else,
            p_match = regexp(p_split(~isThisToolbox), ['.*\' filesep '(wit_io|WITio)\' filesep '?.*'], 'match', 'once'); % Match any old toolboxes
            isOldToolbox = ~cellfun(@isempty, p_match); % Find old toolboxes
            if any(isOldToolbox),
                if isDesktop,
                    fprintf('Found other versions in the MATLAB search path! Click <a href="matlab:WITio.tbx.rmpath_addpath(WITio.tbx.path);">here</a> to resolve it.\n\n');
                else,
                    fprintf('Found other versions in the MATLAB search path! Executing WITio.tbx.rmpath_addpath(WITio.tbx.path); to resolve it.\n\n');
                    WITio.tbx.rmpath_addpath(folder_latest_WITio);
                    fprintf('\n');
                end
            end
        end
    end
end
