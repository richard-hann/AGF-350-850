
clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ------------------------ READING DATA FROM MET NORWAY AWS ----------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Warning: this script is not very well documented. It reads data directly from MET Norway's "Frost" API
%% you might prefer downloading the data from: seklima.met.no


%% -------------------------  USER INPUT -----------------
 
% CHOOSE START AND END TIME FOR THE DOWNLOAD:
 startv = [2022 01 19 00 00 00];
 endv   = [2022 01 20 00 00 00];

% SELECT VARIABLES THAT YOU WANT TO DOWNLOAD
%       see below for instructions on how to find out which variables are available at a certain station
varn = {'surface_air_pressure','air_temperature','wind_speed','wind_from_direction','relative_humidity','sum(precipitation_amount PT1H)','sum(precipitation_amount PT6H)','sum(precipitation_amount PT12H)','surface_snow_thickness'}; 
vars = {'PSFC','T','WS','WD','RH','RR1','RR6','RR12','snowdepth'};

% SELECT WHICH STATIONS THAT YOU WANT TO DOWNLOAD DATA FROM  
%       see list with names below
% stnum = [99840,99870,99790,99752,99910,99880,99927,99765,99735,99935,99740,99754,99720,99938,99710,99760,99884,99874,99763,99895,99770,99843];
stnum = [99870];


%% ---------------------------------------------------------


% % Uncomment and run the following lines to find out what data are available from a given station:
  %   Choose the right station by changing the station ID (here SN99870)
% a = webread('https://frost.met.no/observations/availableTimeSeries/v0.jsonld?sources=SN99870&referencetime=2021-01-01',opts);
%  for i = 1:length(a.data)
%     disp([a.data{i,1}.elementId   '   ' a.data{i,1}.timeResolution])
%  end
% NOTE: some variables might be missing even though they are listed


% INFORMATION AND PICTURES OF SOME OF THE STATIONS:
% https://www.coat.no/Forskning/Data/COAT-v%C3%A6rstasjoner

% LIST OF STATIONS 
%       (most stations in Svalbard, but the list might not be complete)
% stnum = [99840]; % LONGYEAR LUFTHAVN
% stnum = [99870]; % ADVENTDALEN
% stnum = [99790]; % ISFJORD RADIO
% stnum = [99752]; % SØRKAPP ØYA
% stnum = [99910]; % NY-ÅLESUND
% stnum = [99880]; % PYRAMIDEN
% stnum = [99927]; % VERLEGENHUGEN
% stnum = [99765]; % AKSELØYA
% stnum = [99735]; % EDGEØYA
% stnum = [99935]; % KARL XII-ØYA
% stnum = [99740]; % KONGSØYA
% stnum = [99754]; % HORNSUND
% stnum = [99720]; % HOPEN
% stnum = [99938]; % KVITØYA
% stnum = [99710]; % BJØRNØYA
% stnum = [99760]; % SVEAGRUVA
% stnum = [99890]; % KAFFIØYRA
% stnum = [99884]; % KLAUVA
% stnum = [99874]; % JANSSONHAUGEN VEST
% stnum = [99763]; % REINDALSPASSET
% stnum = [99895]; % KVADEHUKEN II
% stnum = [99770]; % ISTJØRNDALEN
% stnum = [99843]; % PLATÅBERGET III




% ------------------------------ Do not touch ---------------
validfrom = datestr(startv,'yyyy-mm-ddTHH');
validto   = datestr(endv,'yyyy-mm-ddTHH');
referencetime = [validfrom '/' validto];
starttime = datetime(startv);
endtime   = datetime(endv);
newTimes = datetime(starttime):hours(1):datetime(endtime);

 opts = weboptions('ContentType', 'json','username','eddc3c74-7a9d-4c7a-a735-b16774458354');

 url_obs       = 'https://frost.met.no/observations/v0.jsonld?';
 url_obs_avail = 'https://frost.met.no/observations/availableTimeSeries/v0.jsonld?';
 url_info      = 'https://frost.met.no/sources/v0.jsonld?';
% -----------------------------------------------------------


for st = 1:length(stnum)
    
    
    for vv = 1:length(varn)
    
        varnn = char(varn{vv});
        varss = char(vars{vv});
     

        % https://frost.met.no/reference#!/observations/observations
            
           
            stinfo = webread(url_info,opts,'ids',['SN' num2str(stnum(st))],'types','SensorSystem');
            AWS(st).name = stinfo.data.name;
              
            try % does not work for Kronprins Haakon (and probably also not for other ships)
                a = stinfo.data.geometry.coordinates;
                    AWS(st).lon = a(1);
                    AWS(st).lat = a(2); 
                    AWS(st).station_elevation_above_sea_level = stinfo.data.masl;
            catch
            end
          

            if vv == 1
                disp(['Fetching data from ' AWS(st).name])
            end
            

            % Choosing time resolution, depending on variable requested
            if contains(char(varn{vv}),'PT6H')
                timeres = 'PT6H';
            elseif contains(char(varn{vv}),'PT12H')
                timeres = 'PT12H';
            else
                timeres = 'PT1H';
            end
            
            
            
            try
                
                disp(['     ' char(varn{vv}) ])
                rgb = webread(url_obs,opts,'sources',['SN' num2str(stnum(st))],'referencetime',referencetime,'elements',char(varn{vv}),'timeresolutions',timeres);

                
                
                
                clear varib timei
                for i = 1:length(rgb.data)
                        varib(i) = rgb.data(i).observations(1).value(1);
                        timei(i) = datenum(rgb.data(i).referenceTime,'yyyy-mm-ddTHH:MM:SS');
                end
                
                
                
                if ~contains(varss,'RR')
                                      
                        table1 = timetable(datetime(datevec(timei)),varib'); 
                        table1.Properties.VariableNames = {varss};
                        table2 = sortrows(table1);
                        table3 = unique(table2);
                        table4 = table3(timerange(starttime,endtime,'closed'),:);
                        table5 = retime(table4,newTimes,'fillwithmissing','TimeStep',hours(1));
                
                        AWS(st).(varss) = table5.(varss);
                
                else
                    
                    AWS(st).([varss '_' timeres]) = varib;
                    AWS(st).(['time_' timeres]) = timei;
                    
                end
                
            
            catch
                
                disp(['           WARNING: Weather element ' char(varn{vv}) ' not available at station ' num2str(stnum(st)) ' ' AWS(st).name])
                
                if contains(varss,'RR')
                
                    AWS(st).([varss '_' timeres]) = nan;
                    AWS(st).(['time_' timeres])   = nan;
                
                else
                    
                    AWS(st).(varss) = nan;
                    
                end
                
                
                
%                 AWS(st).([varss '_' timeres '_observation_level_in_m']) = nan;
            end
            

    end
    
    AWS(st).time = datenum(table5.Time);
    
end




for i = 1:length(AWS)
   
    try
        AWS(i).TP = calc_pot_temp(AWS(i).T,AWS(i).PSFC);
    catch
    end
    try
        AWS(i).Q = calc_spec_humid(AWS(i).T,AWS(i).RH,AWS(i).PSFC);
    catch
    end
        
end



AWS_MET = AWS;

clear AWS






