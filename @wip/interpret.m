% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [ValueUnit, varargout] = interpret(I, Unit_new, Unit_old, varargin),
    % * If Unit_old is empty, then default interpretation is assumed.
    % * Both Unit_new and Unit_old can either be UnitIndex (number input)
    % or ValueUnit (character input). Any mixture of those is accepted.
    % * Fields such as 'TDSpectralInterpretation' and 'TDZInterpretation'
    % will consume first extra input because of needed extra parameter.
    % * NOTE: ERRORS ON INVALID VALUES OF Unit_new or Unit_old!
    % MAY HAVE PERFORMANCE BOTTLENECKS (19.10.2017)
    if nargin < 2, Unit_new = []; end % Default Unit_new
    if nargin < 3, Unit_old = []; end % Default Unit_old
    
    PixelUnit = wip.ArbitraryUnit; % Treated same way as the default units
    
    ValueUnit = []; % Default ValueUnit
    varargout = cellfun(@double, varargin, 'UniformOutput', false); % Default Value
    
    if ~isempty(Unit_old) && ischar(Unit_old), ValueUnit = Unit_old; end % If given Unit_old is ValueUnit_old
    
    if isempty(I), return; end % Do nothing if empty Interpretation
    
    if isa(I, 'wid'),
        Type = I.Type; % Get its Type
        I = I.Data; % Get its Data-struct
    end
    if isstruct(I), % If Interpretation-struct
        if isempty(Unit_old), Unit_old = I.TDInterpretation.UnitIndex; end
        if isempty(Unit_new), Unit_new = I.TDInterpretation.UnitIndex; end
    elseif iscell(I) && numel(I) == 2, % If cell-array (where 1st == Type, 2nd == x0).
        Type = I{1};
    elseif ischar(I), % If string == Type
        Type = I;
        I = {Type, NaN}; % Create cell-array (where 1st == Type, 2nd == x0)
    else,
        warning('Invalid I! Should be wid, cell-array or string. SKIPPING...');
        return;
    end
    
    % Specified interpretations were reverse engineered to achieve interoperability (13.7.2016)
    Types = {'TDSpaceInterpretation', 'TDSpectralInterpretation', 'TDTimeInterpretation', 'TDZInterpretation'};
    bw_find = ~cellfun(@isempty, strfind(Types, Type));
    if sum(bw_find) == 1, Type = Types{bw_find};
    elseif sum(bw_find) > 1, error('TWO OR MORE MATCHES FOUND for interpretation type pattern (''%s'')!', Type);
    else, error('NO MATCH FOUND for interpretation type pattern (''%s'')!', Type); end
    skipMatching = false; % False except true for ZInterpretation
    switch(Type),
        case Types{1}, % SpaceInterpretation
            Units = {wip.interpret_StandardUnit('m'), @(x) 1e-6.*x, @(y) 1e6.*y; ... % m
                wip.interpret_StandardUnit('mm'),     @(x) 1e-3.*x, @(y) 1e3.*y; ... % mm
                wip.interpret_StandardUnit('µm'),     @(x) x,       @(y) y; ... % µm % DEFAULT
                wip.interpret_StandardUnit('nm'),     @(x) 1e3.*x,  @(y) 1e-3.*y; ... % nm
                wip.interpret_StandardUnit('Å'),      @(x) 1e4.*x,  @(y) 1e-4.*y; ... % Å
                wip.interpret_StandardUnit('pm'),     @(x) 1e6.*x,  @(y) 1e-6.*y}; % pm
            ValueUnit = Units{3,1}; % Default ValueUnit
        case Types{2}, % SpectralInterpretation
            if isstruct(I), x0 = I.TDSpectralInterpretation.ExcitationWaveLength;
            else, x0 = I{2}; end
            % FOLLOWING EVALUATION CAN BE PERFORMANCE BOTTLENECK! (19.10.2017)
            Units = {wip.interpret_StandardUnit('nm'),   @(x) x,                           @(y) y; ... % nm % DEFAULT
                wip.interpret_StandardUnit('µm'),        @(x) 1e-3.*x,                     @(y) 1e3.*y; ... % µm
                wip.interpret_StandardUnit('1/cm'),      @(x) 1e7./x,                      @(y) 1e7./y; ... % 1/cm
                wip.interpret_StandardUnit('rel. 1/cm'), @(x) 1e7.*(1./x0-1./x),           @(y) 1./(1./x0-1e-7.*y); ... % rel. 1/cm
                wip.interpret_StandardUnit('eV'),        @(x) 1.23984193e3./x,             @(y) 1.23984193e3./y; ... % eV
                wip.interpret_StandardUnit('meV'),       @(x) 1.23984193e6./x,             @(y) 1.23984193e6./y; ... % meV
                wip.interpret_StandardUnit('rel. eV'),   @(x) -1.23984193e3.*(1./x0-1./x), @(y) 1./(1./x0+y./1.23984193e3); ... % rel. eV
                wip.interpret_StandardUnit('rel. meV'),  @(x) -1.23984193e6.*(1./x0-1./x), @(y) 1./(1./x0+y./1.23984193e6)}; % rel. meV
            ValueUnit = Units{1,1}; % Default ValueUnit
        case Types{3}, % TimeInterpretation
            Units = {wip.interpret_StandardUnit('h'), @(x) x./3600, @(y) 3600.*y; ... % h
                wip.interpret_StandardUnit('min'),    @(x) x./60,   @(y) 60.*y; ... % min
                wip.interpret_StandardUnit('s'),      @(x) x,       @(y) y; ... % s % DEFAULT
                wip.interpret_StandardUnit('ms'),     @(x) 1e3.*x,  @(y) 1e-3.*y; ... % ms
                wip.interpret_StandardUnit('µs'),     @(x) 1e6.*x,  @(y) 1e-6.*y; ... % µs
                wip.interpret_StandardUnit('ns'),     @(x) 1e9.*x,  @(y) 1e-9.*y; ... % ns
                wip.interpret_StandardUnit('ps'),     @(x) 1e12.*x, @(y) 1e-12.*y; ... % ps
                wip.interpret_StandardUnit('fs'),     @(x) 1e15.*x, @(y) 1e-15.*y}; % fs
            ValueUnit = Units{3,1}; % Default ValueUnit
        case Types{4}, % ZInterpretation
            if isstruct(I),
                x0 = I.TDZInterpretation.UnitName;
                % Try to recognize StandardUnit but allow non-StandardUnits
                x0 = wip.interpret_StandardUnit(x0);
            elseif isnan(I{2}), x0 = wip.ArbitraryUnit;
            else, x0 = wip.interpret_StandardUnit(I{2}); end
            Units = {x0, @(x) x, @(y) y};
            skipMatching = true;
            ValueUnit = wip.ArbitraryUnit; % Default ValueUnit
    end
    
    % Interpret input (and convert OLD to DEFAULT)
    if ~isempty(Unit_old), % Interpret input if Unit_old is non-empty
        if ischar(Unit_old), % If given Unit_old is ValueUnit_old
            if ~skipMatching, % Skip only for ZInterpretation
                bw_find = strcmp(Units(:,1), wip.interpret_StandardUnit(Unit_old)); % First test if a Standard Unit
                if sum(bw_find) ~= 1, bw_find = ~cellfun(@isempty, strfind(Units(:,1), Unit_old)); end % Otherwise widen the search
                if sum(bw_find) == 1, varargout = cellfun(Units{bw_find,3}, varargout, 'UniformOutput', false);
                elseif sum(bw_find) > 1, error('TWO OR MORE MATCHES FOUND for old unit pattern (''%s'')!', Unit_old);
                elseif isempty(strfind(PixelUnit, Unit_old)), error('NO MATCH FOUND for old unit pattern (''%s'')!', Unit_old); end
            end
        else, % If given Unit_old is UnitIndex_old
            if Unit_old >= 0 && Unit_old <= size(Units, 1)-1, % After this, change index notation to MATLAB convention
                varargout = cellfun(Units{Unit_old+1,3}, varargout, 'UniformOutput', false);
            else, error('Old unit index (%g) IS OUT OF RANGE [%g, %g]!', Unit_old, 0, size(Units, 1)-1); end
        end
    end
    
    % Interpret output (and convert DEFAULT to NEW)
    if ~isempty(Unit_new), % Interpret output if Unit_new is non-empty
        if ischar(Unit_new), % If given Unit_new is ValueUnit_new
            if skipMatching, % Only for ZInterpretation
                ValueUnit = wip.interpret_StandardUnit(Unit_new);
            else, % Otherwise
                bw_find = strcmp(Units(:,1), wip.interpret_StandardUnit(Unit_new)); % First test if a Standard Unit
                if sum(bw_find) ~= 1, bw_find = ~cellfun(@isempty, strfind(Units(:,1), Unit_new)); end % Otherwise widen the search
                if sum(bw_find) == 1,
                    ValueUnit = Units{bw_find,1};
                    varargout = cellfun(Units{bw_find,2}, varargout, 'UniformOutput', false);
                elseif sum(bw_find) > 1, error('TWO OR MORE MATCHES FOUND for new unit pattern (''%s'')!', Unit_new);
                elseif isempty(strfind(PixelUnit, Unit_new)), error('NO MATCH FOUND for new unit pattern (''%s'')!', Unit_new); end
            end
        else, % If given Unit_new is UnitIndex_new
            if Unit_new >= 0 && Unit_new <= size(Units, 1)-1, % After this, change index notation to MATLAB convention
                ValueUnit = Units{Unit_new+1,1};
                varargout = cellfun(Units{Unit_new+1,2}, varargout, 'UniformOutput', false);
            else, error('New unit index (%g) IS OUT OF RANGE [%g, %g]!', Unit_new, 0, size(Units, 1)-1); end
        end
    end
end
