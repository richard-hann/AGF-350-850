

        
[sz1,sz2] = size(AROME(1).LON);


for j = 1:length(fileurls) % Looping over data files
    display(['reading file ' num2str(j) ' of ' num2str(length(fileurls))])
 
    
        if j==1
            AROME(1).time = [];
            for qz = 1:length(fldnames)
                AROME(1).(fldnames{qz}) = [];
            end
        end
    

     fileurl = char(fileurls(j));
     
        qr = 0;
        try
            filinfo = ncinfo(fileurl);
        catch
        qr = 1;
            display(['WARNING, file ' char(fileurl) ' is missing']);
            display('Inserting NaN for missing data')
        end

        if qr == 0
     
            time = squeeze(ncread(fileurl,'time',start_h,num_h,int_h))./86400 + datenum(1970,1,1);

            AROME(1).time = cat(1,AROME(1).time,time);

            datestr(time)
                        % Start vector indices: longitude, latitude, vertical level, time 
     
                        if PRESSURE_LEVELS == 0
                            start  = [start_lonlat(1) start_lonlat(2) 1 start_h];    count  = [round(count_lonlat(1)./int_x) round(count_lonlat(2)./int_y) 1 num_h];    stride  = [int_x int_y 1 int_h];
                        elseif PRESSURE_LEVELS == 1
                            start  = [start_lonlat(1) start_lonlat(2) p_lvl_start start_h];    count  = [round(count_lonlat(1)./int_x) round(count_lonlat(2)./int_y) p_lvl_num num_h];    stride  = [int_x int_y p_lvl_int int_h];
                        end
%                             start2 = [start_lonlat(1) start_lonlat(2) 1 start_h-int_h];
                    
                            for qz = 1:length(fldnames)
                                n = squeeze(double(ncread(fileurl,varnames{qz},start,count,stride))); 
                                AROME(1).(fldnames{qz}) = cat(3,AROME(1).(fldnames{qz}),n); 
                                disp(['Done reading ' fldnames{qz}])
                            end
                            
                                if isfield(AROME,'u10r') && isfield(AROME,'v10r')
                                % Wind u and v components in the original data are grid-related. 
                                    % Therefore, we rotate here the wind components from grid- to earth-related coordinates.
                                    [AROME(1).u10,AROME(1).v10] = Rotate_uv_components_Arome_Arctic(AROME(1).u10r,AROME(1).v10r,1:size(AROME(1).LON,1),1:size(AROME(1).LON,2),AROME(1).LON);

                                % Calculating wind direction
                                    AROME(1).WD10 = mod(atan2d(-AROME(1).u10,-AROME(1).v10)+360,360);

                                % Calculating wind speed
                                    AROME(1).WS10 = sqrt((AROME(1).u10r.^2)+(AROME(1).v10r.^2));
                                end
                                
                               if isfield(AROME,'ur') && isfield(AROME,'vr')
                                % Wind u and v components in the original data are grid-related. 
                                    % Therefore, we rotate here the wind components from grid- to earth-related coordinates.
                                    [AROME(1).u,AROME(1).v] = Rotate_uv_components_Arome_Arctic(AROME(1).ur,AROME(1).vr,1:size(AROME(1).LON,1),1:size(AROME(1).LON,2),AROME(1).LON);

                                % Calculating wind direction
                                    AROME(1).WD = mod(atan2d(-AROME(1).u,-AROME(1).v)+360,360);

                                % Calculating wind speed
                                    AROME(1).WS = sqrt((AROME(1).ur.^2)+(AROME(1).vr.^2));
                                end
                                
                                if isfield(AROME,'T2') && isfield(AROME,'PSFC')
                                % Calculating potential temperature    
                                    AROME(1).TP2 = calc_pot_temp(AROME(1).T2,AROME(1).PSFC);
                                    AROME(1).TP2 = reshape(AROME(1).TP2,size(AROME(1).T2));
                                end

                                if isfield(AROME,'T2') && isfield(AROME,'RH2') && isfield(AROME,'PSFC')
                                % Calculating specific humidity    
                                    AROME(1).Q2 = calc_spec_humid(AROME(1).T2,AROME(1).RH2,AROME(1).PSFC);
                                    AROME(1).Q2 = reshape(AROME(1).Q2,size(AROME(1).T2));
                                end
                            
        
       
        end
        
end

                                if isfield(AROME,'RH2')
                                    AROME(1).RH2 = AROME(1).RH2.*100; % Scaling relative humidity from 0 to 100 %
                                end
                                if isfield(AROME,'PSFC')
                                    AROME(1).PSFC = AROME(1).PSFC./100; % Converting pressure from Pa to hPa
                                end
                                if isfield(AROME,'T2')
                                    AROME(1).T2 = AROME(1).T2 - 273.15; % Converting temperature from Kelvin to Celcius
                                end
                                if isfield(AROME,'cc')
                                    AROME(1).cc = AROME(1).cc.*100; % Converting cloud fraction from (0-1) to (0-100)
                                end




