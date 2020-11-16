% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% It quickly reads the file until it finds Version information.
function Version = read_Version(File),
    Version = []; % Default value if no Version is found
    
    try,
        % Read UNTIL Version-tag is found, skipping everything unessential
        wit.io.wit.read(File, 4096, @skip_Data_criteria_for_obj, @error_criteria_for_obj);
    catch,
        % DO NOTHING ELSE
    end
    
    function tf = skip_Data_criteria_for_obj(O_wit),
        tf = isempty(O_wit.regexp('^(Version<)?WITec (Project|Data)$', true));
    end
    
    function error_criteria_for_obj(O_wit),
        if ~isempty(O_wit.Parent) && O_wit.Parent == O_wit.Root && ... % Test if tag's Parent is its Root
                strcmp(O_wit.Name, 'Version'), % Test if tag's name is 'Version'
            Version = O_wit.Data; % Store the Version
            error('File Version was found!'); % Abort the file reading by throwing an error
        end
    end
end
