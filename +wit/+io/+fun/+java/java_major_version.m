% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Get Java major version in order to safely use version dependent code.
% Returns NaN if Java is not in use.
function major_version = java_major_version(),
    if usejava('jvm'),
        java_version = char(java.lang.System.getProperty('java.version'));
        % For Java 8 or lower, remove '1.' from the beginning. For Java 9 or
        % higher, it has already been removed, in which case this has no
        % effect.
        java_version = regexprep(java_version, '^1\.', '');
        % Extract major version
        major_version = regexp(java_version, '^([^\.]+)', 'tokens', 'once');
        major_version = str2double(major_version{1});
    else,
        major_version = NaN;
    end
end
