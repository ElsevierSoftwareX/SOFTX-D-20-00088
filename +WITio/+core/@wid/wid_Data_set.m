% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function wid_Data_set(obj, in),
    switch(obj.Type),
        case 'TDBitmap', obj.wid_Data_set_Bitmap(in);
        case 'TDGraph', obj.wid_Data_set_Graph(in);
        case 'TDImage', obj.wid_Data_set_Image(in);
        case 'TDText', obj.wid_Data_set_Text(in);
        case 'TDLinearTransformation', obj.wid_DataTree_set(in, WITio.core.wid.DataTree_format_TDLinearTransformation(obj));
        case 'TDSpaceTransformation', obj.wid_DataTree_set(in, WITio.core.wid.DataTree_format_TDSpaceTransformation(obj));
        case 'TDSpectralTransformation', obj.wid_DataTree_set(in, WITio.core.wid.DataTree_format_TDSpectralTransformation(obj));
        case 'TDLUTTransformation', obj.wid_DataTree_set(in, WITio.core.wid.DataTree_format_TDLUTTransformation(obj));
        case 'TDSpaceInterpretation', obj.wid_DataTree_set(in, WITio.core.wid.DataTree_format_TDSpaceInterpretation(obj));
        case 'TDSpectralInterpretation', obj.wid_DataTree_set(in, WITio.core.wid.DataTree_format_TDSpectralInterpretation(obj));
        case 'TDTimeInterpretation', obj.wid_DataTree_set(in, WITio.core.wid.DataTree_format_TDTimeInterpretation(obj));
        case 'TDZInterpretation', obj.wid_DataTree_set(in, WITio.core.wid.DataTree_format_TDZInterpretation(obj));
        otherwise, obj.wid_DataTree_set(in); % Unformatted DataTree
    end
end
