% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Default Command Window progress bar used in content reading and writing.
% The following case-insensitive extra inputs are parsed:
% '-Width' (= 50): Set to determine progress bar width in characters.
% '-Character' (= '.'): Set to determine progress bar character.
% '-FlipStartEnd' (= false): Set to flip meaning of start and end.
% '-Reverse' (= false): Set to reverse progress bar direction.
% '-OnlyIncreasing' (= false): Set to allow only increasing progress bar.
% '-OnlyDecreasing' (= false): Set to allow only decreasing progress bar.
function [fun_start, fun_now, fun_end] = progress_bar(N_bytes_max, varargin),
    persistent tictoc N_dots_lower N_bytes_lower N_dots_upper N_bytes_upper;
    
    % Parse extra inputs: Width
    parsed = varargin_dashed_str_datas('Width', varargin, -1);
    width_in_characters = 50; % By default, use 50 characters wide progress bar
    if numel(parsed) > 0, width_in_characters = parsed{1}; end
    
    % Parse extra inputs: Character
    parsed = varargin_dashed_str_datas('Character', varargin, -1);
    Character = '.'; % By default, use dot '.'
    if numel(parsed) > 0, Character = parsed{1}; end
    
    % Parse extra inputs: FlipStartEnd
    FlipStartEnd = varargin_dashed_str_exists('FlipStartEnd', varargin);
    
    % Parse extra inputs: Reverse
    Reverse = varargin_dashed_str_exists('Reverse', varargin);
    
    % Parse extra inputs: OnlyIncreasing
    OnlyIncreasing = varargin_dashed_str_exists('OnlyIncreasing', varargin);
    
    % Parse extra inputs: OnlyDecreasing
    OnlyDecreasing = varargin_dashed_str_exists('OnlyDecreasing', varargin);
    
    % Precalculate the number of bytes at each dot
    N_bytes = (0:1./width_in_characters:1).*double(N_bytes_max);
    N_bytes = cast(N_bytes, class(N_bytes_max)); % Prefer same class as N_bytes_max
    
    % Set up the lower and upper limits
    N_dots_lower = 0;
    N_bytes_lower = N_bytes(N_dots_lower + 1);
    N_dots_upper = 1;
    N_bytes_upper = N_bytes(N_dots_upper + 1);
    
    % Determine in which way to update the progress bar
    if Reverse,
        if FlipStartEnd, progress_bar_now = @progress_bar_now_yes_reverse_yes_flip;
        else, progress_bar_now = @progress_bar_now_yes_reverse_no_flip; end
    else,
        if FlipStartEnd, progress_bar_now = @progress_bar_now_no_reverse_yes_flip;
        else, progress_bar_now = @progress_bar_now_no_reverse_no_flip; end
    end
    
    % Return the key functions to operate the progress bar
    fun_start = @progress_bar_start;
    if OnlyIncreasing,
        if FlipStartEnd, fun_now = @progress_bar_now_only_decrease;
        else, fun_now = @progress_bar_now_only_increase; end
    elseif OnlyDecreasing,
        if FlipStartEnd, fun_now = @progress_bar_now_only_increase;
        else, fun_now = @progress_bar_now_only_decrease; end
    else,
        fun_now = @progress_bar_now_either_increase_or_decrease;
    end
    fun_end = @progress_bar_end; % Can be combined with onCleanup when used
    
    function progress_bar_start(N_bytes_now),
        % Initialize the progress bar
        tictoc = tic;
        if Reverse, fprintf([' 100%%' repmat(' ', [1 floor(width_in_characters./2)-4]) '50%%' repmat(' ', [1 ceil(width_in_characters./2)-5]) '0%% complete!\n']);
        else, fprintf([' 0%%' repmat(' ', [1 ceil(width_in_characters./2)-5]) '50%%' repmat(' ', [1 floor(width_in_characters./2)-4]) '100%% complete!\n']); end
        fprintf([' ' repmat(' ', [1 width_in_characters]) ' \n']); % Reserve next line
        progress_bar_now_either_increase_or_decrease(N_bytes_now);
    end
    function progress_bar_now_either_increase_or_decrease(N_bytes_now),
        % Progress the progress bar
        if N_bytes_now >= N_bytes_upper, % If true, then increase dots
            progress_bar_now_increase(N_bytes_now);
        elseif N_bytes_now < N_bytes_lower, % If true, then decrease dots
            progress_bar_now_decrease(N_bytes_now);
        end
    end
    function progress_bar_now_only_increase(N_bytes_now),
        % Progress the progress bar
        if N_bytes_now >= N_bytes_upper, % If true, then increase dots
            progress_bar_now_increase(N_bytes_now);
        end
    end
    function progress_bar_now_only_decrease(N_bytes_now),
        % Progress the progress bar
        if N_bytes_now < N_bytes_lower, % If true, then decrease dots
            progress_bar_now_decrease(N_bytes_now);
        end
    end
    function progress_bar_now_increase(N_bytes_now),
        while true, % Do-while
            if N_dots_upper >= width_in_characters,
                N_dots_upper = width_in_characters;
                N_bytes_upper = N_bytes_now + 1;
                N_dots_lower = width_in_characters;
                N_bytes_lower = N_bytes(N_dots_lower + 1);
                break;
            end
            N_dots_upper = N_dots_upper + 1;
            N_bytes_upper = N_bytes(N_dots_upper + 1);
            if N_bytes_now < N_bytes_upper,
                N_dots_lower = N_dots_upper - 1;
                N_bytes_lower = N_bytes(N_dots_lower + 1);
                break;
            end
        end
        progress_bar_now();
    end
    function progress_bar_now_decrease(N_bytes_now),
        while true, % Do-while
            if N_dots_lower <= 0,
                N_dots_lower = 0;
                N_bytes_lower = N_bytes_now;
                N_dots_upper = 1;
                N_bytes_upper = N_bytes(N_dots_upper + 1);
                break;
            end
            N_dots_lower = N_dots_lower - 1;
            N_bytes_lower = N_bytes(N_dots_lower + 1);
            if N_bytes_now >= N_bytes_lower,
                N_dots_upper = N_dots_lower + 1;
                N_bytes_upper = N_bytes(N_dots_upper + 1);
                break;
            end
        end
        progress_bar_now();
    end
    function progress_bar_now_yes_reverse_yes_flip(),
        fprintf([repmat('\b', [1 width_in_characters+3]) '[' repmat(' ', [1 N_dots_lower]) repmat(Character, [1 width_in_characters-N_dots_lower]) ']\n']);
    end
    function progress_bar_now_yes_reverse_no_flip(),
        fprintf([repmat('\b', [1 width_in_characters+3]) '[' repmat(' ', [1 width_in_characters-N_dots_lower]) repmat(Character, [1 N_dots_lower]) ']\n']);
    end
    function progress_bar_now_no_reverse_yes_flip(),
        fprintf([repmat('\b', [1 width_in_characters+3]) '[' repmat(Character, [1 width_in_characters-N_dots_lower]) repmat(' ', [1 N_dots_lower]) ']\n']);
    end
    function progress_bar_now_no_reverse_no_flip(),
        fprintf([repmat('\b', [1 width_in_characters+3]) '[' repmat(Character, [1 N_dots_lower]) repmat(' ', [1 width_in_characters-N_dots_lower]) ']\n']);
    end
    function progress_bar_end(),
        % Finalize the progress bar
        toc(tictoc);
    end
end