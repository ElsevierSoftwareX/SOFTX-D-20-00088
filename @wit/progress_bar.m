% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Default Command Window progress bar for content reading and writing.
function [fun_start, fun_now, fun_end] = progress_bar(N_bytes_max, width_in_characters),
    persistent tictoc N_bytes_next N_bytes_next_casted preferred_class;
    if nargin < 3, width_in_characters = 50; end % By default, use 50 characters wide progress bar
    N_bytes_per_dot = double(N_bytes_max)./width_in_characters;
    N_bytes_next = N_bytes_per_dot;
    preferred_class = class(N_bytes_max); % Prefer same class as N_bytes_max
    N_bytes_next_casted = cast(N_bytes_next, preferred_class);
    fun_start = @progress_bar_start;
    fun_now = @progress_bar_now;
    fun_end = @progress_bar_end;
    function progress_bar_start(N_bytes_now),
        % Initialize the progress bar
        tictoc = tic;
        fprintf([' 0%%' repmat(' ', [1 ceil(width_in_characters./2)-5]) '50%%' repmat(' ', [1 floor(width_in_characters./2)-4]) '100%% complete!\n[']);
        progress_bar_now(N_bytes_now);
    end
    function progress_bar_now(N_bytes_now),
        % Progress the progress bar
        while N_bytes_now >= N_bytes_next_casted,
            fprintf('.');
            N_bytes_next = N_bytes_next + N_bytes_per_dot;
            N_bytes_next_casted = cast(N_bytes_next, preferred_class); % Cast only once
        end
    end
    function progress_bar_end(),
        % Finalize the progress bar
        fprintf('.]\n');
        toc(tictoc);
    end
end
