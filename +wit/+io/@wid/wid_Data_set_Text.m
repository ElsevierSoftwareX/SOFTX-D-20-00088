% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function wid_Data_set_Text(obj, in),
    % Due to get_Text lossiness, this cannot restore the original binary
    % (or style)! Rather this will restore the default Arial font style.
    out = sprintf('{\\rtf1\\ansi\\ansicpg1252\\deff0\\deflang1033{\\fonttbl{\\f0\\fnil Arial;}}\r\n{\\colortbl ;\\red0\\green0\\blue255;\\red0\\green0\\blue0;\\red0\\green128\\blue0;}\r\n\\viewkind4\\uc1\\pard\\tx2400');
    extra = '';
    nextmaybetitle = false;
    for ii = 1:size(in, 1),
        if ii == 1, % First consider the first line
            if ~all(cellfun(@isempty, in(1,:))), % Header
                out = sprintf('%s\\cf1\\b\\f0\\fs32 %s', out, in{1,1});
                extra = '\cf2\b0\fs16 '; % Only for the first following text
            else,
                out = sprintf('%s\\cf1\\f0\\fs16 ', out);
                nextmaybetitle = true;
            end
        else, % Then consider the other lines
            % First consider the empty lines
            if all(cellfun(@isempty, in(ii,:))),
                out = sprintf('%s\\par %s', out, extra);
                nextmaybetitle = true;
            % Then consider the titles
            elseif nextmaybetitle && all(cellfun(@isempty, in(ii,2:end))),
                out = sprintf('%s\\par \\cf3\\b\\fs20 %s', out, in{ii,1}); % With title font size and color
                extra = '\cf2\b0\fs16 '; % Only for the first following text
                nextmaybetitle = false;
            % Otherwise the text lines
            else,
                out = sprintf('%s\\par %s%s', out, extra, in{ii,1}); % With text font size and color
                for jj = 2:size(in, 2),
                    out = sprintf('%s\\tab %s', out, in{ii,jj});
                end
                extra = ''; % Nothing for the next texts
            end
        end
        if ii == size(in, 1), out = sprintf('%s\\cf0 \r\n', out); % Handling the end of last line
        else, out = sprintf('%s\r\n', out); end
    end
    out = sprintf('%s\\par }\r\n\0', out);
    
    TDStream = obj.Tag.Data.regexp('^TDStream<', true);
    TDStream.regexp('^StreamSize<', true).Data = int32(numel(out)); % int32 required by WITec Project 2.10.3.3
    TDStream.regexp('^StreamData<', true).Data = uint8(out); % uint8 required by WITec Project 2.10.3.3
end
