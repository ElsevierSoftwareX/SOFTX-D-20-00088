% BSD 3-Clause License (LICENSE.txt)
% Copyright (c) 2019, Joonas T. Holmi (jtholmi@gmail.com)
% All rights reserved.

function [ValueUnit, varargout] = transform(T, varargin)
    ValueUnit = wip.ArbitraryUnit; % Default ValueUnit
    varargout = cellfun(@double, varargin, 'UniformOutput', false); % Default Value
    
    if isempty(T), return; end % Do nothing if empty Transformation
    T_Data = T.Data; % Load Data-structure only once (to save CPU time)
    
    % Try to recognize StandardUnit or revert back to ArbitraryUnit
    SU = T_Data.TDTransformation.StandardUnit; % Get transformation StandardUnit
    ValueUnit = wip.interpret_StandardUnit(SU); % Unit after transformation
    if strcmp(ValueUnit, SU), % Test whether StardardUnit was recognized or not
        ValueUnit = wip.ArbitraryUnit; % If not, then revert back to ArbitraryUnit
    end
    
    % Specified transformations were reverse engineered to achieve interoperability (13.7.2016)
    switch(T.Type),
        case 'TDLinearTransformation',
            fun = @LinearTransformation;
        case 'TDSpaceTransformation',
            fun = @SpaceTransformation;
            if isempty(ValueUnit), ValueUnit = wip.DefaultSpaceUnit; end
        case 'TDSpectralTransformation',
            fun = @SpectralTransformation;
            if isempty(ValueUnit), ValueUnit = wip.DefaultSpectralUnit; end
        case 'TDLUTTransformation',
            fun = @LUTTransformation;
        otherwise,
            warning_backtrace = warning('query', 'backtrace'); % Store warning state
            warning off backtrace; % Disable the stack trace
            warning('%s: Unimplemented Type found! SKIPPING...', T.Type);
            warning(warning_backtrace); % Restore warning state
            return; % Do nothing
    end
    
    % Interpret input
    varargout = cellfun(fun, varargout, 'UniformOutput', false);
    [ValueUnit, varargout{1:numel(varargout)}] = wip.interpret(T_Data.TDTransformation.InterpretationID, [], ValueUnit, varargout{:});
    
    function Value = LinearTransformation(Value), % Linear-transform pixel values
        TLinear = T_Data.TDLinearTransformation;
        ModelOrigin_D = TLinear.ModelOrigin_D;
        WorldOrigin_D = TLinear.WorldOrigin_D;
        Scale_D = TLinear.Scale_D;
        
        % CALCULUS VERIFIED (15.7.2016)
        % Scale*(p-1-ModelOrigin)+WorldOrigin (in general form)
        Value = Scale_D*(Value-1-ModelOrigin_D)+WorldOrigin_D;
    end
    
    function Value = SpaceTransformation(Value), % Affine-transform pixel values to physical unit (µm)
        TSpace = T_Data.TDSpaceTransformation;
        ModelOrigin = TSpace.ViewPort3D.ModelOrigin(:);
        WorldOrigin = TSpace.ViewPort3D.WorldOrigin(:);
        Scale = reshape(TSpace.ViewPort3D.Scale, [3 3]);
        Rotation = reshape(TSpace.ViewPort3D.Rotation, [3 3]);
        
%         % Pixel coordinates
%         [X, Y, Z] = ndgrid(1:double(SizeX), 1:double(SizeY), 1:double(SizeZ));
% 
%         % Permute so that Y is first (MATLAB notation)
%         X = permute(X, [2 1 3]);
%         Y = permute(Y, [2 1 3]);
%         Z = permute(Z, [2 1 3]);
% 
%         % Default Position
%         Position = [X(:)'; Y(:)'; Z(:)']; % Indices
        
        % CALCULUS VERIFIED (7.7.2016)
        % Rotation*Scale*(p-1-Origin)+WorldOrigin (in general form)
        [SizeX, SizeY, SizeZ] = size(Value);
        Value = permute(Value, [3 1 2]); % Permute 3rd dimension to 1st
        Value(SizeZ+1:3,:,:) = 1; % Append missing dimensions
        Value = bsxfun(@minus, Value(:,:)-1, ModelOrigin); % Substract Origin
        Value = reshape(Rotation*Scale*Value, [3 size(Value, 2)]); % Rotate and Scale
        Value = bsxfun(@plus, Value, WorldOrigin); % Add WorldOrigin
        Value = ipermute(reshape(Value, [3 SizeX SizeY]), [3 1 2]);
    end

    function Value = SpectralTransformation(Value), % Spectral-transform pixel values to physical unit (nm)
        TSpectral = T_Data.TDSpectralTransformation;
        STT = TSpectral.SpectralTransformationType;
        if STT == 0, % Polynomial transformation
            % CALCULUS VERIFIED (4.10.2018) by generating a LUT comparison
            Polynom = TSpectral.Polynom;
            X = Value-1;
            N = numel(Polynom);
            if N > 3, N = 3; end % Mimic behaviour of WITec Project 2.10.3 and ignore third or higher order coefficients
            Value = zeros(size(X));
            for ii = 1:N,
                Value = Value + Polynom(ii).*X.^(ii-1);
            end
        elseif STT == 1,
            nC = TSpectral.nC; % Pixel # at LambdaC (1)
            LambdaC = TSpectral.LambdaC; % Wavelength (nm) at center of array (where exit slit would usually be located)
            Gamma = TSpectral.Gamma; % The included angle or deviation angle or angle between incident and diffracted light (rad)
            Delta = TSpectral.Delta; % CCD inclination angle (rad) [NOTE: Sign convention matches now that of the WITec Project]
            m = TSpectral.m; % Grating diffraction order (1)
            d = TSpectral.d; % Grating groove density (g/mm)
            x = TSpectral.x; % Pixel width (mm)
            f = TSpectral.f; % Instrument focal length (mm) [For CZ and FE monochromators LA = F = LB]
            
            % CALCULUS VERIFIED (6.7.2016)
            % This code section was greatly inspired by Gwyddion-software
            % modules\file\wipfile.c [1] 'wip_pixel_to_lambda'-function
            % code by Daniil Bratashov (2010). It was carefully studied 
            % together with Horiba's website [2]. However, in its original
            % form it calculated a slightly wrong (but significant in the
            % context of Raman spectroscopy) nm-values due to errorneous
            % sign convention.
            % [1] Gwyddion-website: http://gwyddion.net/module-list-nocss.en.php#wipfile
            % [2] Theoretical background: http://www.horiba.com/us/en/scientific/products/optics-tutorial/wavelength-pixel-position/
            Alpha = asin(LambdaC .* m./d ./ (2.*cos(Gamma./2))) - Gamma./2; % Angle of incidence
            L_H = f .* cos(Delta); % Perpendicular distance from grating or focusing mirror to the focal plane (mm)
            H_BLambdaC = f .* sin(Delta); % Distance from the intercept of the normal to the focal plane to the wavelength LambdaC
            H_BLambdaN = x .* (nC - (Value-1)) - H_BLambdaC; % (NOTE: was + H_BLambdaC due to incorrect sign convention of Delta) % Distance from the intercept of the normal to the focal plane to the wavelength LambdaN
            Beta_LambdaC = Gamma + Alpha; % Angle of diffraction at center wavelength
            Beta_H = Beta_LambdaC - Delta; % (NOTE: was + Delta due to incorrect sign convention of Delta) % Angle from L_H to the normal to the grating (this will vary in a scanning instrument)
            Beta_LambdaN = Beta_H - atan2(H_BLambdaN, L_H); % Angle of diffraction at wavelength n % atan2(y,x) = atan(y/x)
            Value = d./m .* (sin(Alpha) + sin(Beta_LambdaN)); % [nm]

%             % Incorrect sign convention above was revealed by the following lsqnonlins
%             fun = @(p) p(1)./p(2).*(sin(asin(p(3).*p(2)./p(1)./(2.*cos(p(4)./2)))-p(4)./2)+sin(p(4)+asin(p(3).*p(2)./p(1)./(2.*cos(p(4)./2)))-p(4)./2+p(5)-atan2(p(6).*(p(8)*nC+p(9)-(N-1))+p(7).*sin(p(5)),p(7).*cos(p(5)))));
%             p_init = [d m LambdaC Gamma Delta x f 1 0]; % params: d m LambdaC Gamma Delta x f nC_scale nC_offset
%             p_optim = lsqnonlin(@(p) data-fun(p), p_init);
% 
%             fun2 = @(p) d./m.*(sin(asin(LambdaC.*m./d./(2.*cos(Gamma./2)))-Gamma./2)+sin(Gamma+asin(LambdaC.*m./d./(2.*cos(Gamma./2)))-Gamma./2+Delta-atan2(x.*(p(1)*nC+p(2)-(N-1))+f.*sin(Delta),f.*cos(Delta))));
%             p_init2 = [1 0]; % params: d m LambdaC Gamma Delta x f nC_scale nC_offset
%             p_optim2 = lsqnonlin(@(p) data-fun2(p), p_init2);
        elseif STT == 2, % Constrained arbitrary-order polynomial transformation
            % CALCULUS VERIFIED (2.4.2019) by generating a LUT comparison
            FreePolynom = TSpectral.FreePolynom;
            FreePolynomOrder = min(double(TSpectral.FreePolynomOrder), numel(FreePolynom)-1); % Prefer smallest
            
            % Preparation
            X = Value-1;
            Value = zeros(size(X));
            
            % Determine value at lower and upper constraint
            X_Start = TSpectral.FreePolynomStartBin;
            X_Stop = max(X_Start, TSpectral.FreePolynomStopBin); % Mimic behaviour of WITec Project 2.10.3
            Value_Start = 0;
            Value_Stop = 0;
            for ii = 1:FreePolynomOrder+1,
                Value_Start = Value_Start + FreePolynom(ii).*X_Start.^(ii-1);
                Value_Stop = Value_Stop + FreePolynom(ii).*X_Stop.^(ii-1);
            end
            
            % Set values at or outside the constraint
            bw_le = X <= X_Start;
            bw_ge = X >= X_Stop;
            Value(bw_le) = Value_Start;
            Value(bw_ge) = Value_Stop;
            
            % Determine values inside
            bw_in = ~bw_le & ~bw_ge;
            for ii = 1:FreePolynomOrder+1,
                Value(bw_in) = Value(bw_in) + FreePolynom(ii).*X(bw_in).^(ii-1);
            end
        else,
            warning('Unimplemented SpectralTransformationType: %d', STT);
        end
    end

    function Value = LUTTransformation(Value), % Look-Up Table -transform pixel values
        TLUT = T_Data.TDLUTTransformation;
        LUT = TLUT.LUT;
        LUTSize = numel(TLUT.LUT); % And ignore TLUT.LUTSize
        
        try,
            Value = interp1(double(1:LUTSize), double(LUT), Value, 'spline', 'extrap'); % Interpolate AND extrapolate using a cubic spline
        catch,
            Value = nan(size(Value));
        end
    end
end
