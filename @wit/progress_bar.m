% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Default Command Window progress bar used in content reading and writing.
function [fun_start, fun_now, fun_end] = progress_bar(N_bytes_max, width_in_characters),
    persistent tictoc N_dots_next N_bytes_next;
    if nargin < 3, width_in_characters = 50; end % By default, use 50 characters wide progress bar
    
    % Precalculate the number of bytes at each dot
    N_bytes = (0:1./(width_in_characters-1):1).*double(N_bytes_max);
    N_bytes = cast(N_bytes, class(N_bytes_max)); % Prefer same class as N_bytes_max
    
    % Set up the next limit
    N_dots_next = 1;
    N_bytes_next = N_bytes(N_dots_next);
    
    % Return the key functions to operate the progress bar
    fun_start = @progress_bar_start;
    fun_now = @progress_bar_now;
    fun_end = @progress_bar_end; % Can be combined with onCleanup when used
    
    function progress_bar_start(N_bytes_now),
        % Initialize the progress bar
        tictoc = tic;
        fprintf([' 0%%' repmat(' ', [1 ceil(width_in_characters./2)-5]) '50%%' repmat(' ', [1 floor(width_in_characters./2)-4]) '100%% complete!\n[']);
        progress_bar_now(N_bytes_now);
    end
    function progress_bar_now(N_bytes_now),
        % Progress the progress bar
        while N_bytes_now >= N_bytes_next,
            if N_dots_next >= width_in_characters, break; end
            fprintf('.');
            N_dots_next = N_dots_next + 1;
            N_bytes_next = N_bytes(N_dots_next);
        end
    end
    function progress_bar_end(),
        % Finalize the progress bar
        fprintf(['.' repmat(' ', [1 width_in_characters-N_dots_next]) ']\n']);
        toc(tictoc);
    end
end
