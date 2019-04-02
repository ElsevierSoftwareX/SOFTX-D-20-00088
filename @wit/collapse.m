% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This function collapses the WIT tree structure into an all summarizing
% READ-only struct. This is an essential tool to reverse engineer new file
% versions for interoperability and implement them into MATLAB. If you want
% to have WRITE+READ version of this, then use wit_debug-class instead.

% This code is deprecated and may be removed in the future revisions due to
% addition of wit-class 'DataTree_get' and 'DataTree_set' static functions.
function S = collapse(obj),
    S = struct();
    for ii = 1:numel(obj),
        Id = sprintf(sprintf('%%0%dd', floor(log10(numel(obj))+1)), ii);
        S.(['Tag_' Id]) = obj(ii);
        S.(['Name_' Id]) = obj(ii).Name;
        if isa(obj(ii).Data, 'wit'),
            S_sub = obj(ii).Data.collapse();
            C_sub = struct2cell(S_sub);
            subfields = cellfun(@(s) sprintf('%s_%s', ['Data_' Id], s), fieldnames(S_sub), 'UniformOutput', false);
            for jj = 1:numel(subfields),
                S.(subfields{jj}) = C_sub{jj};
            end
        else, S.(['Data_' Id]) = obj(ii).Data; end
    end
end
