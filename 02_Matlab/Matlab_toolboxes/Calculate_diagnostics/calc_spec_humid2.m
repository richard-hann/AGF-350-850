
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ----------------------- CALCULATING SPECIFIC HUMIDITY -----------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function Q = calc_pot_temp(T,RH,P)

        
    % Inputs: 
        % T  = temperature in Celcius
        % RH = relative humidity in %
        % P  = pressure in hPa

            % calculating saturation water vapour pressure
                % Equation from: Buck, A. L., New equations for computing vapor pressure and enhancement factor, J. Appl. Meteorol., 20, 1527-1532, 1981)
                % with enhancement factor.
                % valid for the temperature range -40 50 degrees celcius
%                 Es  = (1.0007 + (3.46*10^-6).*P(:)).*6.1121.*exp(((18.729 - T(:)./227.3).*T(:))./(T(:)+257.87));
                
                Es = 6.112 .* exp((17.67 .* T(:))./(T(:) + 243.5));
                
            % calculating water vapour pressure
                E = Es(:).*(RH(:)./100.0); % water vapour pressure

            % calculating specific humidity
                Q = (0.622.*E(:))./(P(:)-(0.378.*E(:))).*1000;
            
                