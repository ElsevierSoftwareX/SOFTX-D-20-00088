% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Destroys the specified BUT MATCHING wid-input objects from the Project.
function destroy_Data(obj, varargin),
    if isempty(obj), return; end % Do nothing if empty Project given
    % First, discard all non-wid objects
    bw_valid = cellfun(@(x) isa(x, 'wid'), varargin);
    varargin = varargin(bw_valid);
    % Then, force all input to column vectors and merge
    varargin = cellfun(@(x) x(:), varargin, 'UniformOutput', false);
    destroy_Datas = cat(1, varargin{:}); % Create a long column vector
    % Test for any duplicates by matching same handles
    Datas = obj.Data(:);
    bw_destroy = false(size(Datas));
    for ii = 1:numel(Datas),
        for jj = 1:numel(destroy_Datas),
            if Datas(ii) == destroy_Datas(jj), % Test if SAME HANDLE
                bw_destroy(ii) = true;
                break;
            end
        end
    end
    % Destroy MATCHING wid-input
    delete(Datas(bw_destroy));
end
