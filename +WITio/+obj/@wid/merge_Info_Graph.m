% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function Info_Graph_merged = merge_Info_Graph(obj, dim),
    Infos = [obj.Info];
    Graphs = {Infos.Graph};
    Graph_classes = cellfun(@class, Graphs, 'UniformOutput', false);
    Graph_classes = unique(Graph_classes);
    if numel(unique(Graph_classes)) > 1,
        error('FAIL: Cannot merge Graphs of multiple classes (%s) together!', WITio.fun.indep.mystrjoin(Graph_classes, ', '));
    end
    % IMPLEMENTATION IDEA for parse_consistently_or_abort:
    % uint64/int64 can contain EXACTLY itself, uint32/int32, uint16/int16, uint8/int8 and logical.
    % double can contain EXACTLY itself, single, uint32, int32, uint16, int16, uint8, int8 and logical.
    % single can contain EXACTLY itself, uint16, int16, uint8, int8 and logical.
    % uint32/int32 can contain EXACTLY itself, uint16/int16, uint8/int8 and logical.
    % uint16/int16 can contain EXACTLY itself, uint8/int8 and logical.
    % uint8/int8 can contain EXACTLY itself and logical.
    % logical can contain EXACTLY itself.
    % otherwise require element-by-element testing to quarantee EXACTNESS or ABORT.
    [Graphs{1:numel(obj)}] = WITio.fun.dim_size_consistent_repmat(Graphs{:}); % Repmat consistently to permit direct cat-merging
    SizeConsistent = size(Graphs{1});
    if nargin < 2, % If no dim is given, then automatically add a new dimension or use 2nd or 1st dimension if singletons
        if SizeConsistent(end) == 1,
            if SizeConsistent(1) == 1, dim = 1;
            else, dim = numel(SizeConsistent); end
        else, dim = numel(SizeConsistent) + 1; end
    end
    Info_Graph_merged = cat(dim, Graphs{:});
end
