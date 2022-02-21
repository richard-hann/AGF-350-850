
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%google.com/search?q=%27http%3A%2F%2F158.39.149.183%2FGruvefjellet%2F%3Fcommand%3DDataQuery%26uri%3DServer%3AGruvefjellet_ny.Res_data%26format%3Djson%26mode%3Ddate-range%26p1%3D2022-02-06T00%3A00%3A00%26p2%3D2022-02-14T00%3A00%3A00%27&oq=%27http%3A%2F%2F158.39.149.183%2FGruvefjellet%2F%3Fcommand%3DDataQuery%26uri%3DServer%3AGruvefjellet_ny.Res_data%26format%3Djson%26mode%3Ddate-range%26p1%3D2022-02-06T00%3A00%3A00%26p2%3D2022-02-14T00%3A00%3A00%27&aqs=chrome..69i57.289j0j4&sourceid=chrome&ie=UTF-8%%%%%%%%
% ---------------------- READING RADIATION DATA FROM PERMANENT UNIS AWS ----------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% Define date range:
d1 = '2022-02-06T00:00:00';
d2 = '2022-02-14T00:00:00';



%% Retrieving data from UNIS stations:

    % Gruvefjellet
        disp('Fetching GRUVEFJELLET')
        k1 = webread(['http://158.39.149.183/Gruvefjellet/?command=DataQuery&uri=Server:Gruvefjellet_ny.Res_data&format=json&mode=date-range&p1=' d1 '&p2=' d2]);
        for i = 1:length(k1.data)
          t = k1.data(i).time;
          AWS_UNIS(1).time(i) = datenum(t,'yyyy-mm-ddTHH:MM:SS') + 1/24;
          AWS_UNIS(1).T02(i)   = cell2mat(k1.data(i).vals(7));
    
          AWS_UNIS(1).T2(i)   = cell2mat(k1.data(i).vals(7));  % LT1m_minutt_Avg    -- Temperature, minute average.         2m above ground? 
          AWS_UNIS(1).RH2(i)  = cell2mat(k1.data(i).vals(12)); % LF_minutt_Avg      -- Relative humidity, minute average.   1.6m above ground?
          AWS_UNIS(1).P(i)    = cell2mat(k1.data(i).vals(13)); % AT_mbar            -- Air pressure
          AWS_UNIS(1).ws10(i) = cell2mat(k1.data(i).vals(15)); % VH_10_minutt       -- Wind speed, 10 min average           2.8m above ground
          AWS_UNIS(1).wd10(i) = cell2mat(k1.data(i).vals(17)); % VR_gr_framh	    -- Wind direction, 10 min average?      2.8m above ground
        end
        AWS_UNIS(1).name = 'GRUVEFJELLET';
        AWS_UNIS(1).lon = 15.6273;
        AWS_UNIS(1).lat = 78.1998;
        AWS_UNIS(1).altitude = 464; % m ASL
        % The meta data on this station are unclear. 
        % Presumably, we have the following setup:
        % LT10cm_gr_C     = 20 cm
        % LT1m_gr_C      = 200 cm
        % LT3m_gr_C      = 260 cm. This sensor does not seem to give any data as of 2022 (NaN in the records)

        

    % Breinosa
        disp('Fetching BREINOSA')
        k2 = webread(['http://158.39.149.183/Gruvefjellet/?command=DataQuery&uri=Server:Breinosa.Table1&format=json&mode=date-range&p1=' d1 '&p2=' d2]);
        for i = 1:length(k2.data)
          t = k2.data(i).time;
          AWS_UNIS(2).time(i) = datenum(t,'yyyy-mm-ddTHH:MM:SS');
          AWS_UNIS(2).T2(i)   = k2.data(i).vals(2);  % AirTC_Avg  -- Temperature average (5 min?)           3.7m above ground
          AWS_UNIS(2).RH2(i)  = k2.data(i).vals(5);  % RH_Avg     -- Relative humidity average (5 min?)     3.7m above ground
          AWS_UNIS(2).P(i)    = k2.data(i).vals(10); % BP_mBar    -- Air pressure
          AWS_UNIS(2).ws10(i) = k2.data(i).vals(7);  % WS_ms_Avg  -- Wind speed average (5 min?)            4.6m above ground
          AWS_UNIS(2).wd10(i) = k2.data(i).vals(8);  % WindDir	  -- Wind direction (average?) 5min?        4.6m above ground
        end
        AWS_UNIS(2).name = 'BREINOSA';
        AWS_UNIS(2).lon=16.043; % location of KHO
        AWS_UNIS(2).lat=78.148; % location of KHO
        AWS_UNIS(2).altitude = 517;% m ASL
        
        
        
    % Villa Fivel
        disp('Fetching VILLA FIVEL')
        k3 = webread(['http://158.39.149.183/Gruvefjellet/?command=DataQuery&uri=Server:Atmos%2041.Min&format=json&mode=date-range&p1=' d1 '&p2=' d2]);
        for i = 1:length(k3.data)
          t = k3.data(i).time;
          AWS_UNIS(3).time(i) = datenum(t,'yyyy-mm-ddTHH:MM:SS') - 2/24;
          AWS_UNIS(3).T2(i)   = k3.data(i).vals(12);    % AirT_C_Avg  -- Temperature, minute average.
          AWS_UNIS(3).RH2(i)  = k3.data(i).vals(21);    % RH          -- Relative humiidty, minute average?
          AWS_UNIS(3).P(i)    = k3.data(i).vals(18);    % BP_mbar_Avg -- Air pressure
          AWS_UNIS(3).ws10(i) = k3.data(i).vals(9);     % WS_ms_Avg	  -- Wind speed, minute average.
          AWS_UNIS(3).wd10(i) = k3.data(i).vals(10);    % WindDir     -- Wind direction, minute average?
        end
        AWS_UNIS(3).name = 'VILLA_FIVEL';
        AWS_UNIS(3).lon=16.02557; 
        AWS_UNIS(3).lat=78.19476;
        
        

        
disp(['------------------------------------------'])
disp([' Done reading data from permanent UNIS AWS'])
disp(['------------------------------------------'])
        
        