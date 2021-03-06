% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function wip_wid_context_menus(),
    % Implemented by Joonas T. Holmi (18.7.2018) based on the idea worked out
    % by Petri Mustonen. Supports only Microsoft Windows operating systems.
    
    disp('*Generating a reg-file in order to add ''MATLAB''-option to the *.WIP and *.WID context menus to enable a quick WITio.obj.wip.read call.');
    if ~ispc, error('*Only Microsoft Windows operating systems are currently supported!'); end
    
    [filepath, name, ~] = fileparts(mfilename('fullpath'));
    reg_file = fullfile(filepath, [name '.reg']);
    
    % Open as text file and overwrite: https://se.mathworks.com/help/matlab/ref/fopen.html
    fid = fopen(reg_file, 'wt+');
    
    % Close the file ONLY WHEN out of the function scope
    C = onCleanup(@() fclose(fid)); % https://blogs.mathworks.com/loren/2008/03/10/keeping-things-tidy/
    
    % Get current MATLAB version and release number
    [v, d] = builtin('version');
    tokens = regexp(v, '(\d+\.\d+\.\d+)[^\(]*\(([^\)]*)\)', 'tokens', 'once');
    
    % Determine the MATLAB executable path
    if strcmp(computer, 'PCWIN'), MatlabExe = fullfile(matlabroot, 'bin', 'matlab.exe'); % Assumed rather than tested
    else, MatlabExe = fullfile(matlabroot, 'bin', 'win64', 'matlab.exe'); end % Verified
    MatlabExe = strrep(MatlabExe, filesep, '\\'); % Make file separator correct for the reg import
    
    % Determine the MATLAB DDE ShellVerbs
    ShellVerbs = 'ShellVerbs.MATLAB'; % For R2012b or less
    year = str2double(regexprep(d, '^.*\s(\d+)$', '$1'));
    if year >= 2013, ShellVerbs = [ShellVerbs '.' tokens{1}]; end % For R2013a or more (Comments at https://undocumentedmatlab.com/blog/matlab-dde-support)
    
    % General idea: https://msdn.microsoft.com/en-us/library/windows/desktop/cc144101(v=vs.85).aspx
    % Undocumented: https://undocumentedmatlab.com/blog/matlab-dde-support
    % Here \\ is \ and %% is % (due to usage of fprintf): https://se.mathworks.com/help/matlab/matlab_prog/matlab-operators-and-special-characters.html
    root = 'HKEY_LOCAL_MACHINE\SOFTWARE\Classes';
    fprintf(fid, 'Windows Registry Editor Version 5.00\n');
    
    MatlabCmd = '[file, O_wid, O_wip, O_wit] = WITio.tbx.wip_wid_context_menus_cmd(''%1'');';
    
    subroot1 = [root '\WITec Data File\shell\MATLAB'];
    fprintf(fid, '\n; Context menu for WITec Data File\n');
    fprintf(fid, '[%s]\n', subroot1);
    fprintf(fid, '@="WITio @ MATLAB %s"\n', v); % The text shown under the context menu
    fprintf(fid, '[%s\\command]\n', subroot1);
    fprintf(fid, '@="%s"\n', MatlabExe);
    fprintf(fid, '[%s\\ddeexec]\n', subroot1);
    fprintf(fid, '@="%s"\n', MatlabCmd);
    fprintf(fid, '[%s\\ddeexec\\application]\n', subroot1);
    fprintf(fid, '@="%s"\n', ShellVerbs);
    fprintf(fid, '[%s\\ddeexec\\topic]\n', subroot1);
    fprintf(fid, '@="system"\n');
    
    subroot2 = [root '\WITec Project File\shell\MATLAB'];
    fprintf(fid, '\n; Context menu for WITec Project File\n');
    fprintf(fid, '[%s]\n', subroot2);
    fprintf(fid, '@="WITio @ MATLAB %s"\n', v); % The text shown under the context menu
    fprintf(fid, '[%s\\command]\n', subroot2);
    fprintf(fid, '@="%s"\n', MatlabExe);
    fprintf(fid, '[%s\\ddeexec]\n', subroot2);
    fprintf(fid, '@="%s"\n', MatlabCmd);
    fprintf(fid, '[%s\\ddeexec\\application]\n', subroot2);
    fprintf(fid, '@="%s"\n', ShellVerbs);
    fprintf(fid, '[%s\\ddeexec\\topic]\n', subroot2);
    fprintf(fid, '@="system"\n');
    clear C; % Release the file by closing its file stream (to avoid errors)
    
    disp('*Reg-file successfully created:');
    disp(reg_file);
    
    % Attempt to call REG through MATLAB
    status = dos(sprintf('REG IMPORT "%s"', reg_file));
    if status == 0,
        disp('*Try REG IMPORT: SUCCESS! The *.WIP and *.WID context menus should now be updated accordingly.');
    else,
        disp('*Try REG IMPORT: FAIL! Either re-run MATLAB under administration rights or manually double-click the reg-file to install it.');
    end
end
