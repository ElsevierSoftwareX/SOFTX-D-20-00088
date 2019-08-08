% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Adds the specified wid-input objects to the Project, avoiding adding
% duplicates.
function add_Data(obj, varargin),
    if isempty(obj), return; end % Do nothing if empty Project given
    % First, discard all non-wid objects
    bw_valid = cellfun(@(x) isa(x, 'wid'), varargin);
    varargin = varargin(bw_valid);
    % Then, force all input to column vectors and merge
    varargin = cellfun(@(x) x(:), varargin, 'UniformOutput', false);
    add_Datas = cat(1, varargin{:}); % Create a long column vector
    % Test for any duplicates by matching same handles
    Datas = obj.Data(:);
    bw_add = true(size(add_Datas));
    for ii = 1:numel(add_Datas),
        for jj = 1:numel(Datas),
            if add_Datas(ii) == Datas(jj), % Test if SAME HANDLE
                bw_add(ii) = false;
                break;
            end
        end
    end
    % Add but remove duplicates and keep the ordering
    obj.Data = [Datas; add_Datas(bw_add)];
end
