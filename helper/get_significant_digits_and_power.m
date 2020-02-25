% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

% Result digits.*10.^power == value up to N_significant digits.
function [digits, power, value] = get_significant_digits_and_power(value, N_significant),
    if nargin < 2, N_significant = 1; end % Get only the most significant digit
    
    % Test value
    if numel(value) ~= 1 || ~isnumeric(value),
        error('Accepting only a scalar numeric ''value'' input!');
    end
    value = double(value); % Force double
    
    % Test N_significant
    if numel(N_significant) ~= 1 || ~isnumeric(N_significant) || ~(N_significant >= 0),
        error('Accepting only a scalar numeric zero or positive ''N_significant'' input!');
    elseif N_significant == 0,
        [digits, power, value] = deal(0);
        return;
    end
    
    % Store sign
    value_sign = sign(value);
    value = abs(value);
    
    % Loop to extract the digits
    digits = 0;
    for ii = 1:N_significant,
        if ii == 1, % Find and evaluate the 10'th power
            power = floor(log10(value));
            e_power = 10 .^ power;
        else, % Decrease the power
            power = power-1;
            e_power = e_power./10;
        end
        digit = floor(value ./ e_power); % Get the next most significant digit
        value = value - digit .* e_power; % Remove the extracted digit
        digits = 10.*digits + digit; % Append to digits
    end
    
    % Restore sign
    digits = value_sign .* digits;
    
    % Recalculate value (up to N_significant digits)
    value = digits .* e_power;
end
