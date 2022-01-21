
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------------------- READING RADIATION DATA FROM PERMANENT UNIS AWS ----------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% Define date range:
d1 = '2022-01-19T00:00:00';
d2 = '2022-01-20T00:00:00';

%% Retrieving data from UNIS stations:

    % Gruvefjellet
        disp('Fetching GRUVEFJELLET')
        k1 = webread(['http://158.39.149.183/Gruvefjellet/?command=DataQuery&uri=Server:Gruvefjellet_ny.Res_data&format=json&mode=date-range&p1=' d1 '&p2=' d2]);
        for i = 1:length(k1.data)
          t = k1.data(i).time;
          AWS_UNIS(1).time(i) = datenum(t,'yyyy-mm-ddTHH:MM:SS') + 1/24;
          AWS_UNIS(1).T02(i)   = cell2mat(k1.data(i).vals(7));
    
          AWS_UNIS(1).T2(i)   = cell2mat(k1.data(i).vals(7));
          AWS_UNIS(1).RH2(i)  = cell2mat(k1.data(i).vals(12));
          AWS_UNIS(1).P(i)    = cell2mat(k1.data(i).vals(13));
          AWS_UNIS(1).ws10(i) = cell2mat(k1.data(i).vals(15));
          AWS_UNIS(1).wd10(i) = cell2mat(k1.data(i).vals(17));
        end
        AWS_UNIS(1).name = 'GRUVEFJELLET';
        AWS_UNIS(1).lon = 15.6273;
        AWS_UNIS(1).lat = 78.1998;


    % Breinosa
        disp('Fetching BREINOSA')
        k2 = webread(['http://158.39.149.183/Gruvefjellet/?command=DataQuery&uri=Server:Breinosa.Table1&format=json&mode=date-range&p1=' d1 '&p2=' d2]);
        for i = 1:length(k2.data)
          t = k2.data(i).time;
          AWS_UNIS(2).time(i) = datenum(t,'yyyy-mm-ddTHH:MM:SS');
          AWS_UNIS(2).T2(i)   = k2.data(i).vals(2);
          AWS_UNIS(2).RH2(i)  = k2.data(i).vals(5);
          AWS_UNIS(2).P(i)    = k2.data(i).vals(10);
          AWS_UNIS(2).ws10(i) = k2.data(i).vals(7);
          AWS_UNIS(2).wd10(i) = k2.data(i).vals(8);
        end
        AWS_UNIS(2).name = 'BREINOSA';
        AWS_UNIS(2).lon=16.043; % location of KHO
        AWS_UNIS(2).lat=78.148; % location of KHO
        
        
    % Villa Fivel
        disp('Fetching VILLA FIVEL')
        k3 = webread(['http://158.39.149.183/Gruvefjellet/?command=DataQuery&uri=Server:Atmos%2041.Min&format=json&mode=date-range&p1=' d1 '&p2=' d2]);
        for i = 1:length(k3.data)
          t = k3.data(i).time;
          AWS_UNIS(3).time(i) = datenum(t,'yyyy-mm-ddTHH:MM:SS') - 2/24;
          AWS_UNIS(3).T2(i)   = k3.data(i).vals(12);
          AWS_UNIS(3).RH2(i)  = k3.data(i).vals(21);
          AWS_UNIS(3).P(i)    = k3.data(i).vals(18);
          AWS_UNIS(3).ws10(i) = k3.data(i).vals(9);
          AWS_UNIS(3).wd10(i) = k3.data(i).vals(10);
        end
        AWS_UNIS(3).name = 'VILLA_FIVEL';
        AWS_UNIS(3).lon=16.02557; 
        AWS_UNIS(3).lat=78.19476;
        
        

        
disp(['------------------------------------------'])
disp([' Done reading data from permanent UNIS AWS'])
disp(['------------------------------------------'])
        
        