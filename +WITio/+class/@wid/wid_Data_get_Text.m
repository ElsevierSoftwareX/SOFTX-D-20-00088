% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function out = wid_Data_get_Text(obj),
    Data = obj.Tag.Data.regexp('^StreamData<TDStream<', true);
    if isempty(Data.Data), Data.reload(); end
    in = Data.Data;
    
    % Convert input to text (20.6.2017: All font information is lost!)
    in = char(in);

    % Test if this is correctly formatted text
    if ~strncmp(in, '{\rtf1', 6),
        error('Unsupported TDText format detected!');
    end

    % VERIFIED (12.7.2016)
    % Parsing approximately according to RTF-formatting to obtain text
    % tokens (assuming relevant data does NOT contain {}-groupings).
    out = regexprep(in, '^[^\{]*\{(.*)\}[^\}]*$', '$1'); % Keep data after first { and before last }
    out = regexprep(out, '\\''([0-9a-fA-F]{2})', '${char(hex2dec($1))}'); % Parse hexadecimal ANSI codes in RTF-format and replace with corresponding characters
    out = regexprep(out, '\\\~', ' '); % Handle 'nonbreaking space'-escape
    out = regexprep(out, '\\\_', '-'); % Handle 'nonbreaking hyphen'-escape
    out = regexprep(out, '\\\-|\\\*', ''); % Remove other escapes
    out = regexprep(out, '^.*\}([^\}]*)$', '\\par $1'); % Replace everything until last } with \par to account for the first line of text
    out = regexprep(out, '(?!\\par |\\tab )(\\[a-z]+(-?[0-9]+)? ?)', ''); % Remove all RTF-commands except for \par and \tab
    out = regexprep(out, '[\a\b\f\r\n\t\v]', ''); % Remove special characters: \a, \b, \f, \n, \r, \t, \v
    out = regexp(out, '(\\par [^\\]*)(\\tab [^\\]+)*', 'tokens'); % Break text into \par-\tab groups
%     out = regexp(out, '(\\par [^\\]+)(\\tab [^\\]+)*', 'tokens'); % Replaced with above line to accept the empty lines % Break text into \par-\tab groups
    out = regexprep(cat(1, out{1:end-1}), '\\par ||\\tab ', ''); % Merge cell groups and remove \par and \tab RTF-commands
%     out = regexprep(cat(1, out{:}), '\\par ||\\tab ', ''); % Replaced with above line to deny the last accepted (non-existant) empty line % Merge cell groups and remove \par and \tab RTF-commands
end
