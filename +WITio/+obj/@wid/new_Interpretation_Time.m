% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function obj = new_Interpretation_Time(O_wit),
    if nargin == 0 || isempty(O_wit), O_wit = WITio.obj.wid.new(); end % Create O_wit
    Version = WITio.obj.wip.get_Root_Version(O_wit);
    
    Tag_DataClassName = WITio.obj.wit('DataClassName 0', 'TDTimeInterpretation');
    Tag_Data = WITio.obj.wit('Data 0');
    
    Tag_TData = WITio.obj.wip.new_TData(Version, sprintf('New %s', Tag_DataClassName.Data));
    Tag_TDInterpretation = WITio.obj.wit('TDInterpretation', [ ...
        WITio.obj.wit('Version', int32(0)) ...
        WITio.obj.wit('UnitIndex', int32(0)) ...
        ]);
    Tag_Data.Data = [Tag_TData Tag_TDInterpretation];
    
    % Append these to the given (or created) O_wit
    [~, Pair] = WITio.obj.wip.append(O_wit, [Tag_DataClassName Tag_Data]);
    
    % Create new wid
    obj = WITio.obj.wid(Pair);
end
