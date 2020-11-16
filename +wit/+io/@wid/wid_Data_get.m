% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function out = wid_Data_get(obj),
    switch(obj.Type),
        case 'TDBitmap', out = obj.wid_Data_get_Bitmap();
        case 'TDGraph', out = obj.wid_Data_get_Graph();
        case 'TDImage', out = obj.wid_Data_get_Image();
        case 'TDText', out = obj.wid_Data_get_Text();
        case 'TDLinearTransformation', out = obj.wid_DataTree_get(wit.io.wid.DataTree_format_TDLinearTransformation(obj));
        case 'TDSpaceTransformation', out = obj.wid_DataTree_get(wit.io.wid.DataTree_format_TDSpaceTransformation(obj));
        case 'TDSpectralTransformation', out = obj.wid_DataTree_get(wit.io.wid.DataTree_format_TDSpectralTransformation(obj));
        case 'TDLUTTransformation', out = obj.wid_DataTree_get(wit.io.wid.DataTree_format_TDLUTTransformation(obj));
        case 'TDSpaceInterpretation', out = obj.wid_DataTree_get(wit.io.wid.DataTree_format_TDSpaceInterpretation(obj));
        case 'TDSpectralInterpretation', out = obj.wid_DataTree_get(wit.io.wid.DataTree_format_TDSpectralInterpretation(obj));
        case 'TDTimeInterpretation', out = obj.wid_DataTree_get(wit.io.wid.DataTree_format_TDTimeInterpretation(obj));
        case 'TDZInterpretation', out = obj.wid_DataTree_get(wit.io.wid.DataTree_format_TDZInterpretation(obj));
        otherwise, out = obj.wid_DataTree_get(); % Unformatted DataTree
    end
end
