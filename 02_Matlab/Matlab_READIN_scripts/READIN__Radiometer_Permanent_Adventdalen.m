
clc
clear
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ----- READING RADIATION DATA FROM RADIOMETER PERMANENTLY INSTALLED IN ADVENTDALEN ----%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% NOTE: the data are fetched directly from the UNIS server, not from the course OneDrive

d1 = '2022-01-19T00:00:00';
d2 = '2022-01-20T00:00:00';


        disp('Fetching data from permanently installed radiometer in Adventdalen')
        k1 = webread(['http://158.39.149.183/Gruvefjellet/?command=DataQuery&uri=Server:Adventdalen_New.Fem_minutt&format=json&mode=date-range&p1=' d1 '&p2=' d2]);

        for i = 1:length(k1.data)
          t = k1.data(i).time;
          RAD(3).time(i)    = datenum(t,'yyyy-mm-ddTHH:MM:SS');
          RAD(3).sw_down(i)   = k1.data(i).vals(1);
          RAD(3).lw_down(i)   = k1.data(i).vals(2);
          RAD(3).sw_up(i)     = k1.data(i).vals(3);
          RAD(3).lw_up(i)     = k1.data(i).vals(4);
        end


% % Calculating surface temp using Stefan Boltzmanns law and taking reflected longwave radiation into account:
    sigmm = 5.67*10^(-8); % boltzmanns constant
    epss  = 0.9; % emissivity
% 
    RAD(3).Tsurf = ((RAD(3).lw_up-(1-epss)*RAD(3).lw_down)./(epss*sigmm)).^(1/4)-273.15;

 
disp(['--------------------------------------------------------------'])
disp([' Done reading files from permanent radiometer in Adventdalen  '])
disp(['--------------------------------------------------------------'])

