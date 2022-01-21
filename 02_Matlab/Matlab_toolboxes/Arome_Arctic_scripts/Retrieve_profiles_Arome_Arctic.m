
% Script that retrieves profile point data from Arome Arctic
%   The script is run by the main script "READIN_Arome_Arctic_point_data



AROME(1).time = [];

for qr = 1:length(STT) % use this line to read in all stations
% for qr = 1  % use this line to read in only selected stations
    nn = 1;
    for ff = 1:length(fileurls)
        filename=fileurls{ff};
        
        for qrr = start_h:num_h
        
            n = squeeze(ncread(filename,'time',qrr,1,1))./86400 + datenum(1970,1,1); 
            AROME(qr).time = [AROME(qr).time n];

            start = [coords_xx(qr) coords_yy(qr)  1 qrr]; count = [1 1 inf 1]; stride = [1 1 1 int_h]; 


            % Retrieving variables from MET Norway server thredds.met.no
            for i=1:length(varnames)
                AROME(qr).prof(nn).(fldnames{i}) = squeeze(double(ncread(filename,varnames{i},start,count,stride)));
                disp(['Done reading variable   ' fldnames{i} '   from file ' filename ' on thredds server'])
            end

            % Wind u and v components in the original data are grid-related. 
            % Therefore, we rotate here the wind components from grid- to earth-related coordinates.
               [AROME(qr).prof(nn).u,AROME(qr).prof(nn).v] = Rotate_uv_components_Arome_Arctic(AROME(qr).prof(nn).ur,AROME(qr).prof(nn).vr,coords_xx(qr),coords_yy(qr),AROME_static(1).LON);

            % Calculating wind direction
               AROME(qr).prof(nn).WD = mod(atan2d(-AROME(qr).prof(nn).u,-AROME(qr).prof(nn).v)+360,360);

            % Calculating wind speed
               AROME(qr).prof(nn).WS = sqrt((AROME(qr).prof(nn).ur.^2) + (AROME(qr).prof(nn).vr.^2));

            % Converting specific humidity from kg/kg to g/kg 
               AROME(qr).prof(nn).Q = AROME(qr).prof(nn).Q.*1000; 
            
            % Calculating height levels and pressure
                hybrid = ncread(filename,'hybrid'); 
                ap = ncread(filename,'ap');
                b = ncread(filename,'b');
               [AROME(qr).prof(nn).height,AROME(qr).prof(nn).P] = Calculate_height_levels_and_pressure_Arome_Arctic(hybrid,ap,b,AROME(qr).prof(nn).t0,AROME(qr).prof(nn).PSFC,AROME(qr).prof(nn).T);
                 
            % Calculating potential temperature
               AROME(qr).prof(nn).TP = (AROME(qr).prof(nn).T)'.*(1000./(AROME(qr).prof(nn).P./100)).^.287;

            % Converting pressure from Pa to hPa
                AROME(qr).prof(nn).P = AROME(qr).prof(nn).P./100;

            % Converting temperature from Kelvin to Celcius    
                AROME(qr).prof(nn).T  = AROME(qr).prof(nn).T  - 273.15;
                AROME(qr).prof(nn).TP = AROME(qr).prof(nn).TP - 273.15;
               
               
               
            nn = nn + 1;
    
        end
    end

end



    