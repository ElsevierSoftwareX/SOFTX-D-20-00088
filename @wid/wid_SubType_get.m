% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function out = wid_SubType_get(obj),
    out = '';
    switch(obj.Type),
        case 'TDBitmap',
            out = 'Image';
            if size(obj.Data, 4) > 1, out = 'Volume'; end % CUSTOM
        case 'TDGraph',
            switch(obj.ImageIndex), % VERIFIED 25.7.2016 TO BE THE COMPLETE LIST!
                case 0, out = 'Image';
                    if size(obj.Data, 4) > 1, out = 'Volume'; end % CUSTOM
                case 1, out = 'Line';
                case 2, out = 'Point';
                case 3, out = 'Array';
                case 4, out = 'Histogram';
                case 5, out = 'Time';
                case 6, out = 'Mask';
            end
        case 'TDImage',
            out = 'Image';
            if size(obj.Data, 4) > 1, out = 'Volume'; end % CUSTOM
        case 'TDLinearTransformation', out = 'Linear';
        case 'TDSpaceTransformation', out = 'Space';
        case 'TDSpectralTransformation', out = 'Spectral';
        case 'TDSpaceInterpretation', out = 'Space';
        case 'TDSpectralInterpretation', out = 'Spectral';
        case 'TDTimeInterpretation', out = 'Time';
        case 'TDZInterpretation', out = 'Data';
    end
end
