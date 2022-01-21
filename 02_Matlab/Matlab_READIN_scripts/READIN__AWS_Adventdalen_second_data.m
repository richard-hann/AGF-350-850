

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ------------ READING DATA FROM PERMANENT UNIS AWS ----%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




% CAUTION: it takes a long time to download these 1 sec data 
% (about 5 seconds for one hour of data, on a good internet connection)
% Choose the date range carefully. We recomend you start with a small
% range, and then increase it.

% Define date range:
d1 = '2022-01-19T00:00:00';
% d2 = '2022-01-20T00:00:00';
d2 = '2022-01-19T01:00:00';

    % Adventdalen 10m mast SECOND data
        disp('Fetching ADVENTDALEN DATA')
        k4 = webread(['http://158.39.149.183/Gruvefjellet/?command=DataQuery&uri=Server:Adventdalen_New.Sekund&format=json&mode=date-range&p1=' d1 '&p2=' d2]);
        for i = 1:length(k4.data)
          t = k4.data(i).time;
          AWS_UNIS(4).time(i)        = datenum(t,'yyyy-mm-ddTHH:MM:SS'); % Time vector
          AWS_UNIS(4).T2(i)          = k4.data(i).vals(4);  % T3           Temperature at 2 m (Rotronic Hydroclip sensor)
          AWS_UNIS(4).T2_pt1000(i)   = k4.data(i).vals(2);  % T1           Temperature at 2 m (PT1000 sensor)   
          AWS_UNIS(4).T10(i)         = k4.data(i).vals(6);  % T4           Temperature at 10 m (Rotronic Hydroclip sensor)
          AWS_UNIS(4).T10_pt1000(i)  = k4.data(i).vals(3);  % T2           Temperature at 10 m (PT1000 sensor)
          AWS_UNIS(4).RH2(i)         = k4.data(i).vals(5);  % LF1          Relative humidity at 2 m (Rotronic Hydroclip sensor)
          AWS_UNIS(4).RH10(i)        = k4.data(i).vals(7);  % LF2          Relative humidity at 10 m (Rotronic Hydroclip sensor)
          AWS_UNIS(4).P(i)           = k4.data(i).vals(8);  % AT           Atmospheric pressure
          AWS_UNIS(4).ws2(i)         = k4.data(i).vals(9);  % VH1          Wind speed at 2m
          AWS_UNIS(4).wd2(i)         = k4.data(i).vals(10); % VR1          Wind direction at 2m
          AWS_UNIS(4).ws10(i)        = k4.data(i).vals(11); % VH2          Wind speed at 10m
          AWS_UNIS(4).wd10(i)        = k4.data(i).vals(12); % VR2          Wind direction at 10m
        end
        AWS_UNIS(4).name = 'ADVENTDALEN_UNIS_second_data';
        AWS_UNIS(4).lon=15.833; 
        AWS_UNIS(4).lat=78.201;
      
        
         
disp(['-----------------------------------'])
disp([' Done reading second data from permanent UNIS AWS in Adventdalen'])
disp(['-----------------------------------'])

