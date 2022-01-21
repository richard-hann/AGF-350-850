
% Script that retrieves near-surface point data from Arome Arctic
%   The script is run by the main script "READIN_Arome_Arctic_point_data

       
for j=1:length(fileurls) % Looping over data files
    display(['reading file ' num2str(j) ' of ' num2str(length(fileurls))])
    
    for qq=1:length(STT)
        display(['      reading station data ' num2str(qq) ' of ' num2str(length(STT))])

        fileurl = char(fileurls(j));
        
        if j==1
            AROME(qq).time=[];
            for qz = 1:length(fldnames)
                AROME(qq).(fldnames{qz}) = [];
            end
        end
        
        qr = 0;
       
        try   % Checking if file exists
            filinfo=ncinfo(fileurl);
        catch % if not, then insert NaNs
            qr=1;
            disp(['WARNING, file ' char(fileurl) ' is missing']);
            displ('Inserting NaN for missing data')
        end
     
          if qr == 0 % if file exists, then read data
              n = squeeze(ncread(fileurl,'time',start_h,num_h,int_h))./86400 + datenum(1970,1,1);                AROME(qq).time=[AROME(qq).time(:)' n(:)'];    disp('Done reading time')
              start = [coords_xx(qq) coords_yy(qq) 1 start_h]; count=[1 1 1 num_h]; stride=[1 1 1 int_h];
            % Retrieving variables from MET Norway server thredds.met.no
            for i=1:length(varnames) % reading data, looping over files
                n = squeeze(double(ncread(fileurl,varnames{i},start,count,stride))); AROME(qq).(fldnames{i}) = [AROME(qq).(fldnames{i})(:)' n(:)']; disp(['Done reading ' fldnames{i}])
            end
          end
    end
end

for i = 1:length(STT)
    
    if isfield(AROME,'RH2')
        AROME(i).RH2 = AROME(i).RH2.*100; % Scaling relative humidity from 0 to 100 %
    end
    if isfield(AROME,'PSFC')
        AROME(i).PSFC = AROME(i).PSFC./100; % Converting pressure from Pa to hPa
    end
    if isfield(AROME,'T2')
        AROME(i).T2 = AROME(i).T2 - 273.15; % Converting temperature from Kelvin to Celcius
    end
   
    if isfield(AROME,'u10r') && isfield(AROME,'v10r')
    % Wind u and v components in the original data are grid-related. 
        % Therefore, we rotate here the wind components from grid- to earth-related coordinates.
        [AROME(qq).u10,AROME(qq).v10] = Rotate_uv_components_Arome_Arctic(AROME(qq).u10r,AROME(qq).v10r,coords_xx(qq),coords_yy(qq),AROME_static(1).LON);
        
    % Calculating wind direction
        AROME(qq).WD10 = mod(atan2d(-AROME(qq).u10,-AROME(qq).v10)+360,360);
        
    % Calculating wind speed
        AROME(qq).WS10 = sqrt((AROME(qq).u10r.^2)+(AROME(qq).v10r.^2));
    end
    
    if isfield(AROME,'T2') && isfield(AROME,'PSFC')
    % Calculating potential temperature    
        AROME(qq).TP2 = calc_pot_temp(AROME(qq).T2,AROME(qq).PSFC);
    end
       
    if isfield(AROME,'T2') && isfield(AROME,'RH2') && isfield(AROME,'PSFC')
    % Calculating specific humidity    
        AROME(qq).Q2 = calc_spec_humid(AROME(qq).T2,AROME(qq).RH2,AROME(qq).PSFC);
    end
        
end 
   
