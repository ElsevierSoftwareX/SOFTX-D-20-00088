% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Add a file to the end of System ClassLoader.
function java_class_path_add_after_static(file),
    % Error if file does not exist
    jF = java.io.File(file);
    if ~jF.exists(),
        error('%s (The system cannot find the file specified)', file);
    end
    
    % Construct URL
    jURL = jF.toURI().toURL();
    
    % Append to System ClassLoader
    jSCL = java.lang.ClassLoader.getSystemClassLoader(); % Application ClassLoader
    jC_UCL = java.lang.Class.forName('java.net.URLClassLoader');
    params = javaArray('java.lang.Class', 1);
    params(1) = java.lang.Class.forName('java.net.URL');
    jM_addURL = jC_UCL.getDeclaredMethod('addURL', params);
    jM_addURL.setAccessible(1); % Set method public
    jM_addURL.invoke(jSCL, jURL); % Append file to the java class path
    
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
                    java.lang.Class.forName(entry_classname, 1, jSCL); % Try to initialize class
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
            java.lang.Class.forName(classname, 1, jSCL); % Try to initialize class
        catch,
            % Failed.
        end
    end
end
