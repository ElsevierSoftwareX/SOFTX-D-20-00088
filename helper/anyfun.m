% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.

function [ varargout ] = anyfun( FUN, varargin )
%ANYFUN Uses arrayfun/cellfun with whatever Name-Value Pairs are found.
%NOTE: The function is flexible. Inputs may be of any type and size as long
%as they may consistently be repmat'd to exactly the same size. Dimension
%size consistent repmat is done with dim_size_consistent_repmat-function.
    
    permuteInput = false; % By default: Do NOT permute the input
    useCellFun = false; % By default: Do USE arrayfun for a slight speed-up

    % Find Name-Value Pair arguments
    str = {'UniformOutput', 'ErrorHandler', 'PermuteInput', 'UseCellFun'};
    bw_2nd = mod(2:nargin, 2) ~= mod(nargin, 2); % Consider every second (starting from the end)
    bw_char = cellfun(@ischar, varargin) & bw_2nd; % Potential Names
    bw_char(1:(2.*find(~bw_char(bw_2nd), 1, 'last'))) = false; % Ignore Names that are in between
    [bw_builtin_pairs, bw_all_pairs] = deal(false(size(bw_char))); % Logical maps
    for ii = 1:numel(str),
        bw_name = false(size(bw_char));
        bw_name(bw_char) = cellfun(@(x) strcmpi(x, str{ii}), varargin(bw_char)); % Locate the Name (ignore case)
        bw_value = [0 bw_name(1:end-1)-bw_name(2:end)] > 0; % Shift to locate the Value
        bw_pair = bw_name | bw_value;
        bw_all_pairs = bw_pair | bw_all_pairs;
        if ii > 2, % Set values to custom Pairs
            value = varargin(bw_value);
            if ~isempty(value),
                if isequal(value{1}, 0) || isequal(value{1}, 1),
                    switch ii,
                        case 3, permuteInput = value{1};
                        case 4, useCellFun = value{1};
                    end
                else error(sprintf('Input #%d expected to be a logical value for the parameter ''%s''.', find(bw_value, 1, 'first')+1), str{ii}); end
            end
        else bw_builtin_pairs = bw_pair | bw_builtin_pairs; end
    end
    builtin_pairs = varargin(bw_builtin_pairs); % Separate built-in Pairs from other Pair and non-Pair arguments
    varargin = varargin(~bw_all_pairs); % Keep only the non-Pair arguments
    
    % Permute the dimensions here if the user wants all input permutations
    if permuteInput,
        ind_params = fast_num2cell(1:numel(varargin));
        varargin = cellfun(@(x, y) permute(x(:), [2:y 1 (y+1):2]), varargin, ind_params, 'UniformOutput', false);
    end
    
    % Perform a dimension size consistent repmat OR throw an error!
    [varargin{1:end}] = dim_size_consistent_repmat(varargin{1:end});
    
    if useCellFun, % Use cellfun
        bw_cell = cellfun(@iscell, varargin); % Convert all non-cells to cells using num2cell
        varargin(~bw_cell) = cellfun(@fast_num2cell, varargin(~bw_cell), 'UniformOutput', false); % May be slow
        [varargout{1:nargout}] = cellfun( FUN, varargin{:}, builtin_pairs{:} );
    else % Use arrayfun
        [varargout{1:nargout}] = arrayfun( FUN, varargin{:}, builtin_pairs{:} );
    end
    
    %% MEMBER FUNCTIONS
    function [mat_cell] = fast_num2cell(mat) % == num2cell(mat)
        mat_cell = cell(size(mat));
        for jj = 1:numel(mat), mat_cell{jj} = mat(jj); end
    end
end
