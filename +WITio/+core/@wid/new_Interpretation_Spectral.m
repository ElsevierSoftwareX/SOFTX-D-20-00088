% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function obj = new_Interpretation_Spectral(O_wit),
    if nargin == 0 || isempty(O_wit), O_wit = WITio.core.wid.new(); end % Create O_wit
    Version = WITio.core.wip.get_Root_Version(O_wit);
    
    Tag_Extra = WITio.core.wit('TDSpectralInterpretation', [ ...
        WITio.core.wit('Version', int32(0)) ...
        WITio.core.wit('ExcitationWaveLength', double(NaN)) ...
        ]);
    
    Tag_DataClassName = WITio.core.wit('DataClassName 0', 'TDSpectralInterpretation');
    Tag_Data = WITio.core.wit('Data 0');
    
    Tag_TData = WITio.core.wip.new_TData(Version, sprintf('New %s', Tag_DataClassName.Data));
    Tag_TDInterpretation = WITio.core.wit('TDInterpretation', [ ...
        WITio.core.wit('Version', int32(0)) ...
        WITio.core.wit('UnitIndex', int32(0)) ...
        ]);
    Tag_Data.Data = [Tag_TData Tag_TDInterpretation Tag_Extra];
    
    % Append these to the given (or created) O_wit
    [~, Pair] = WITio.core.wip.append(O_wit, [Tag_DataClassName Tag_Data]);
    
    % Create new wid
    obj = WITio.core.wid(Pair);
end
