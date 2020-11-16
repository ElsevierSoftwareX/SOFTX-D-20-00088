% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Experimental code to remove classname jar from its ClassLoader. If the
% class has not yet been used, then this seems to have an effect on MATLAB.
% Inspired by codes at https://stackoverflow.com/a/39146471 and
% http://www.docjar.com/html/api/sun/misc/URLClassPath.java.html
function path = java_class_path_rm(classname),
    path = ''; % Empty is returned on failure
    
    % Get related classes
    jC_UCL = java.lang.Class.forName('java.net.URLClassLoader');
    jC_UCP = java.lang.Class.forName('sun.misc.URLClassPath');
    
    % Get related fields
    jF_ucp = jC_UCL.getDeclaredField('ucp');
    jF_ucp.setAccessible(1);
    
    % Find classname resource or exit
    jSCL = java.lang.ClassLoader.getSystemClassLoader(); % Subclass of URLClassLoader
    jClass = java.lang.Class.forName(classname, 0, jSCL); % Get class
    jCL = jClass.getClassLoader();
    if ~isempty(jCL), jCL_ucp = jF_ucp.get(jCL); % For Non-Bootstrap ClassLoader
    else, jCL_ucp = sun.misc.Launcher.getBootstrapClassPath(); end % For Bootstrap ClassLoader
    name = [strrep(char(jClass.getName()), '.', '/') '.class'];
    res = jCL_ucp.getResource(name);
    if isempty(res), return; end
    jURL = res.getCodeSourceURL();
    
    % First, find and remove file URL from path's ArrayList
    jF_path = jC_UCP.getDeclaredField('path'); % The URL search path
    jF_path.setAccessible(1);
    jUCP_path = jF_path.get(jCL_ucp);
    ind_path = jUCP_path.indexOf(jURL);
    if ind_path == -1, return; end % Stop if file URL cannot be found
    jUCP_path.remove(ind_path);
    path = char(jURL.toString()); % Set path to be returned
    
    % Inspect if URL has already been loaded
    
    % Second, find and remove file Loader from lmap's HashMap
    jF_lmap = jC_UCP.getDeclaredField('lmap'); % Maps each URL opened to its corresponding Loader
    jF_lmap.setAccessible(1);
    jUCP_lmap = jF_lmap.get(jCL_ucp);
    urlNoFragString = sun.net.util.URLUtil.urlNoFragString(jURL);
    if ~jUCP_lmap.containsKey(urlNoFragString), return; end % Stop if file Loader cannot be found
    jLoader = jUCP_lmap.get(urlNoFragString); % Get loader to be removed
    jUCP_lmap.remove(urlNoFragString);
    
    % Third, find and remove file Loader from loaders' ArrayList
    jF_loaders = jC_UCP.getDeclaredField('loaders'); % The Loader search path
    jF_loaders.setAccessible(1);
    jUCP_loaders = jF_loaders.get(jCL_ucp);
    ind_loaders = jUCP_loaders.indexOf(jLoader);
    if ind_loaders == -1, return; end % Stop if file Loader cannot be found
    jUCP_loaders.remove(ind_loaders);
end
