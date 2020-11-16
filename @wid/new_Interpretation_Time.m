% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function obj = new_Interpretation_Time(O_wit),
    if nargin == 0 || isempty(O_wit), O_wit = wid.new(); end % Create O_wit
    Version = wit.io.wip.get_Root_Version(O_wit);
    
    Tag_DataClassName = wit.io.wit('DataClassName 0', 'TDTimeInterpretation');
    Tag_Data = wit.io.wit('Data 0');
    
    Tag_TData = wit.io.wip.new_TData(Version, sprintf('New %s', Tag_DataClassName.Data));
    Tag_TDInterpretation = wit.io.wit('TDInterpretation', [ ...
        wit.io.wit('Version', int32(0)) ...
        wit.io.wit('UnitIndex', int32(0)) ...
        ]);
    Tag_Data.Data = [Tag_TData Tag_TDInterpretation];
    
    % Append these to the given (or created) O_wit
    [~, Pair] = wit.io.wip.append(O_wit, [Tag_DataClassName Tag_Data]);
    
    % Create new wid
    obj = wid(Pair);
end
