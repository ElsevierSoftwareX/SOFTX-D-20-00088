% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function wid_SubType_set(obj, in),
    switch(obj.Type),
        case 'TDGraph',
            switch(in), % VERIFIED 25.7.2016 TO BE THE COMPLETE LIST!
                case 'Image', obj.ImageIndex = 0;
                case 'Line', obj.ImageIndex = 1;
                case 'Point', obj.ImageIndex = 2;
                case 'Array', obj.ImageIndex = 3;
                case 'Histogram', obj.ImageIndex = 4;
                case 'Time', obj.ImageIndex = 5;
                case 'Mask', obj.ImageIndex = 6;
                case 'Volume', obj.ImageIndex = 0; % CUSTOM
            end
    end
end
