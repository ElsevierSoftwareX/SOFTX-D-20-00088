% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% It quickly reads the file until it finds Version information.
function Version = read_Version(File),
    Version = []; % Default value if no Version is found
    
    warning off;
    try,
        wit.read(File, 4096, @error_by_obj_criteria); % Read UNTIL Version-tag is found
    catch,
        % DO NOTHING ELSE
    end
    warning on;
    
    function error_by_obj_criteria(O_wit),
        if O_wit.Parent == O_wit.Root && ... % Test if tag's Parent is its Root
                strcmp(O_wit.Name, 'Version'), % Test if tag's name is 'Version'
            Version = O_wit.Data; % Store the Version
            error('File Version was found!'); % Abort the file reading by throwing an error
        end
    end
end
