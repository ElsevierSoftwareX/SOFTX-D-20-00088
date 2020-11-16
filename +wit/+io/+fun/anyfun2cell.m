% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function varargout = anyfun2cell(FUN, varargin),
%ANYFUN2CELL Uses anyfun with 'UniformOutput' == false -flag. NOTE: The
%function is flexible. Inputs may be of any type and size as long as they
%may consistently be repmat'd to exactly the same size. Dimension size
%consistent repmat is done with dim_size_consistent_repmat-function.
    [varargout{1:nargout}] = wit.io.fun.anyfun(FUN, varargin{:}, 'UniformOutput', false);
end
