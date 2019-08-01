% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function obj = new_Interpretation_Spectral(O_wit),
    if nargin == 0 || isempty(O_wit), O_wit = wid.new(); end % Create O_wit
    Version = wip.get_Root_Version(O_wit);
    
    Tag_Extra = wit('TDSpectralInterpretation', [ ...
        wit('Version', int32(0)) ...
        wit('ExcitationWaveLength', double(NaN)) ...
        ]);
    
    Tag_DataClassName = wit('DataClassName 0', 'TDSpectralInterpretation');
    Tag_Data = wit('Data 0');
    
    Tag_TData = wip.new_TData(Version, sprintf('New %s', Tag_DataClassName.Data));
    Tag_TDInterpretation = wit('TDInterpretation', [ ...
        wit('Version', int32(0)) ...
        wit('UnitIndex', int32(0)) ...
        ]);
    Tag_Data.Data = [Tag_TData Tag_TDInterpretation Tag_Extra];
    
    % Append these to the given (or created) O_wit
    [~, Pair] = wip.append(O_wit, [Tag_DataClassName Tag_Data]);
    
    % Create new wid
    obj = wid(Pair(2));
end
