% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% This is a simple wrapper for WITio.obj.wip.read.
function varargout = read(varargin), % For reading WIT-formatted WID-files!
    % WITec Project/Data (*.WIP/*.WID) -file data reader. Returns the
    % selected data when the Project Manager -window (if opened) is CLOSED.
    % 0) Input is parsed into files and extra case-insensitive options:
    % *Option '-all': Skip Project Manager and load all data in the files.
    % *Option '-ifall': Inquery the user whether or not to do '-all'.
    % *Option '-append': Appends all subsequent projects into the first
    % project. Before WITio v2.0.0 this was the default behaviour when
    % multiple files were read. Since WITio v2.0.0 it has been disabled and
    % replaced by new default behaviour, namely file batch mode, in which
    % the projects are kept separate.
    % *Option '-LimitedRead': If given, then limit file content reading to
    % the specified number of bytes per Data and skip any exceeding Data.
    % The skipped Data is read from file later only if requested by a user.
    % If given without a number, then the limit is set to 4096.
    % *Options '-DataUnit', '-SpaceUnit', '-SpectralUnit' and '-TimeUnit':
    % Force the output units. This is very useful for automated processing.
    % *Option '-Manager': Passes the given inputs to Project Manager:
    % (1) by providing the inputs in a single cell, i.e. {'-all'}, OR
    % (2) by writing the related single-dashed strings as double-dashed,
    % i.e. '-all' becomes '--all'. For instance, it can be used to load all
    % data with specified Type / SubType.
    % 1) If the file input is omitted, then a file browsing GUI is opened.
    % 2) The specified file is loaded, processed and shown in a new window.
    % 3) Project Manager -window allows preview of all data in the project.
    % 4) The selected items in Project Manager -window are returned.
    [varargout{1:nargout}] = WITio.read(varargin);
end
