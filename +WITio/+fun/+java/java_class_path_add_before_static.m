% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Add a file to custom URL ClassLoader, which is set as a new ancestor of
% Java's System ClassLoader. In effect, its classes are found first before
% those of System ClassLoader during the class search. For instance, some
% of the MATLAB's built-in jar files can perhaps be updated to newer
% version without conflicts. Unfortunately, this test has failed for
% commons-compress.jar. This also tries to make the file classes available
% on MATLAB side without need for external calls like importing. The
% following website has inspired developing this code:
% http://undocumentedmatlab.com/articles/static-java-classpath-hacks
function java_class_path_add_before_static(file),
    persistent jUCL cURLs;
    
    % Error if file does not exist
    jF = java.io.File(file);
    if ~jF.exists(),
        error('%s (The system cannot find the file specified)', file);
    end
    
    % Construct URL
    jURL = jF.toURI().toURL();
    cURL = char(jURL.toString());
    
    % Add if not already added or exit
    if any(strcmp(cURLs, cURL)),
        return;
    end
    cURLs{end+1} = cURL;
    
    % Create new custom URL ClassLoader if missing
    if isempty(jUCL),
        args = javaArray('java.net.URL', 1);
        args(1) = jURL;
        jUCL = java.net.URLClassLoader(args, []); % Set its parent to Bootstrap ClassLoader
        % Change Application ClassLoader ancestor to it
        jC_CL = java.lang.Class.forName('java.lang.ClassLoader');
        jF_parent = jC_CL.getDeclaredField('parent');
        jF_parent.setAccessible(1); % Set field public
        root = java.lang.ClassLoader.getSystemClassLoader(); % Application ClassLoader
        while true, % Loop until the Bootstrap ClassLoader is found
            parent_new = jF_parent.get(root); % Parent of Application ClassLoader is Extension ClassLoader. % Parent of Extension ClassLoader may be Bootstrap ClassLoader.
            if isempty(parent_new), break; % Bootstrap ClassLoader is null
            else, root = parent_new; end
        end
        jF_parent.set(root, jUCL); % Make it the highest ancestor
    else, % Otherwise, append to custom URL ClassLoader
        jC_UCL = java.lang.Class.forName('java.net.URLClassLoader');
        params = javaArray('java.lang.Class', 1);
        params(1) = java.lang.Class.forName('java.net.URL');
        jM_addURL = jC_UCL.getDeclaredMethod('addURL', params);
        jM_addURL.setAccessible(1); % Set method public
        jM_addURL.invoke(jUCL, jURL); % Append file to the java class path
    end
    
    % Try to make file class content visible on MATLAB side without need for external calls
    [~, name, ext] = fileparts(file);
    if strcmpi(ext, '.jar'),
        jJF = java.util.jar.JarFile(file); % Benefits from java.io.RandomAccessFile
        ocu_jJF = onCleanup(@() jJF.close()); % Safe cleanup of the file reading
        entries = jJF.entries();
        while entries.hasMoreElements(),
            entry = entries.nextElement();
            entry_file = char(entry.getName());
            [entry_path, entry_name, entry_ext] = fileparts(entry_file);
            if strcmpi(entry_ext, '.class'),
                % Assume that entry_path describes the package route to the entry_name.class
                entry_classname = [strrep(entry_path, '/', '.') '.' entry_name]; % JAR file separator always '/'
                try,
                    java.lang.Class.forName(entry_classname, 1, jUCL); % Try to initialize class
                    break; % On success, stop loop.
                catch,
                    % Failed. Try next.
                end
            end
        end
    elseif strcmpi(ext, '.class'),
        % Assume that bare *.class file does not belong to a package
        classname = name;
        try,
            java.lang.Class.forName(classname, 1, jUCL); % Try to initialize class
        catch,
            % Failed.
        end
    end
end
