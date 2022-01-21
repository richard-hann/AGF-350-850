clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ------------------------ READING DATA FROM CAMPBELL AWS ------------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% INPUT: BEFORE RUNNING SCRIPT, MAKE SURE THAT THE PATH TO THE DATA IS CORRECT IN THE FILE set_filepaths.m


[filepath,~,~] = fileparts(mfilename('fullpath'));
cd(filepath)
run ./../set_filepaths



addpath(genpath(toolboxpath))

% select which of the Campbell stations to read data from here:
cd(AWS_Campbell_1_path)
% cd(AWS_Campbell_2_path)



start_time = datetime(datevec('08-Sep-2021 10:00:00'));
end_time   = datetime(datevec('14-Sep-2021 20:00:00'));


start_30min    = start_time;
end_30min      = end_time;

start_10min    = start_time;
end_10min      = end_time;

start_1min     = start_time;
end_1min       = end_time;


newTimes_1min  = datetime(start_time):minutes(1):datetime(end_time);

newTimes_10min = datetime(start_time):minutes(10):datetime(end_time);

newTimes_30min = datetime(start_time):minutes(30):datetime(end_time);


% sorting out data following recipe from among others:
% https://www.mathworks.com/help/matlab/matlab_prog/clean-timetable-with-missing-duplicate-or-irregular-times.html
secdata_10 = load('Campbell_AWS_1_10sec_ALLDATA.dat');
        timenTRH = datenum(secdata_10(:,1), secdata_10(:,2), secdata_10(:,3), secdata_10(:,4), secdata_10(:,5), secdata_10(:,6)); % time vector
        T1       = secdata_10(:,10);
        RH1      = secdata_10(:,11);
        T2       = secdata_10(:,12);
        RH2      = secdata_10(:,13);


              table1 = timetable(datetime(datevec(timenTRH)),T1 ,RH1 ,T2 ,RH2); 
              table1.Properties.VariableNames = {'T1','RH1','T2','RH2'};
              table2 = sortrows(table1); 
              table3 = unique(table2);
              table4 = table3(timerange(start_time,end_time,'closed'),:);
    
              
              table5_1min_avg   =  retime(table4,newTimes_1min,'mean');
              table5_10min_avg  =  retime(table4,newTimes_10min,'mean');
              table5_30min_avg  =  retime(table4,newTimes_30min,'mean');
              
              
              table5_10sec        =  retime(table4,'regular','fillwithmissing','TimeStep',seconds(10));
              table5_1min         =  retime(table4,'regular','fillwithmissing','TimeStep',minutes(1));
              table5_10min        =  retime(table4,'regular','fillwithmissing','TimeStep',minutes(10));
              table5_30min        =  retime(table4,'regular','fillwithmissing','TimeStep',minutes(30));
              table5_1hr          =  retime(table4,'regular','fillwithmissing','TimeStep',hours(1));
             
             AWS_TRH_1min_avg  = table5_1min_avg;
             AWS_TRH_10min_avg = table5_10min_avg;
             AWS_TRH_30min_avg = table5_30min_avg;
             AWS_TRH_10sec     = table5_10sec;
             AWS_TRH_1min      = table5_1min;
             AWS_TRH_10min     = table5_10min;
             AWS_TRH_30min     = table5_30min;
             AWS_TRH_1hr       = table5_1hr;
             
             clear table5*
              
              
secdata_1 = load('Campbell_AWS_1_1sec_ALLDATA.dat');
        timenWSWD = datenum(secdata_1(:,1), secdata_1(:,2), secdata_1(:,3), secdata_1(:,4), secdata_1(:,5), secdata_1(:,6)); % time vector
        WS1 = secdata_1(:,9);
        WD1 = secdata_1(:,10);
        WS2 = secdata_1(:,11);
        WD2 = secdata_1(:,12);
        
            U1 = WS1.*cos((270-WD1)*pi/180);
            V1 = WS1.*sin((270-WD1)*pi/180);
            U2 = WS2.*cos((270-WD2)*pi/180);
            V2 = WS2.*sin((270-WD2)*pi/180); 

              table1 = timetable(datetime(datevec(timenWSWD)),U1,V1,U2,V2);
              table1.Properties.VariableNames = {'U1','V1','U2','V2'};
              table2 = sortrows(table1); 
              table3 = unique(table2);
              table4 = table3(timerange(start_time,end_time,'closed'),:);
   

              table5_1min_avg   =  retime(table4,newTimes_1min,'mean');
              table5_10min_avg  =  retime(table4,newTimes_10min,'mean');
              table5_30min_avg  =  retime(table4,newTimes_30min,'mean');
              
              
              table5_1sec         =  retime(table4,'regular','fillwithmissing','TimeStep',seconds(1));
              table5_10sec        =  retime(table4,'regular','fillwithmissing','TimeStep',seconds(10));
              table5_1min         =  retime(table4,'regular','fillwithmissing','TimeStep',minutes(1));
              table5_10min        =  retime(table4,'regular','fillwithmissing','TimeStep',minutes(10));
              table5_30min        =  retime(table4,'regular','fillwithmissing','TimeStep',minutes(30));
              table5_1hr          =  retime(table4,'regular','fillwithmissing','TimeStep',hours(1));

              flds = {'1min_avg','10min_avg','30min_avg','1sec','10sec','1min','10min','30min','1hr'};
              for ii = 1:length(flds)
                  
                  tbl = ['table5_' char(flds(ii))];
                    u1 = eval(['table5_' char(flds(ii)) '.U1;']); v1 = eval(['table5_' char(flds(ii)) '.V1;']);
                    u2 = eval(['table5_' char(flds(ii)) '.U2;']); v2 = eval(['table5_' char(flds(ii)) '.V2;']);
                    
                    eval([tbl '.WS1 = sqrt((u1.^2) + (v1.^2));'])
                    eval([tbl '.WD1 = mod(atan2d(-u1,-v1)+360,360);'])
                    eval([tbl '.WS2 = sqrt((u2.^2) + (v2.^2));']);
                    eval([tbl '.WD2 = mod(atan2d(-u2,-v2)+360,360);'])
                    
              end
              
             AWS_WSWD_1min_avg  = table5_1min_avg;
             AWS_WSWD_10min_avg = table5_10min_avg;
             AWS_WSWD_30min_avg = table5_30min_avg;
             AWS_WSWD_1sec      = table5_1sec;
             AWS_WSWD_10sec     = table5_10sec;
             AWS_WSWD_1min      = table5_1min;
             AWS_WSWD_10min     = table5_10min;
             AWS_WSWD_30min     = table5_30min;
             AWS_WSWD_1hr       = table5_1hr;
              
               AWS_CB_1min_avg   = synchronize(AWS_TRH_1min_avg,AWS_WSWD_1min_avg);
               AWS_CB_10min_avg  = synchronize(AWS_TRH_10min_avg,AWS_WSWD_10min_avg);
               AWS_CB_30min_avg  = synchronize(AWS_TRH_10min_avg,AWS_WSWD_30min_avg);
               AWS_CB_10sec      = synchronize(AWS_TRH_10sec,AWS_WSWD_10sec);
               AWS_CB_1min       = synchronize(AWS_TRH_1min,AWS_WSWD_1min);
               AWS_CB_10min      = synchronize(AWS_TRH_10min,AWS_WSWD_10min);
               AWS_CB_30min      = synchronize(AWS_TRH_30min,AWS_WSWD_30min);
               AWS_CB_1hr        = synchronize(AWS_TRH_1hr,AWS_WSWD_1hr);
               
               AWS_CB_1sec       = AWS_WSWD_1sec;
               
               AWS_CB_all        = synchronize(AWS_CB_1min_avg,AWS_CB_10min_avg,AWS_CB_30min_avg,AWS_CB_1sec,AWS_CB_10sec,AWS_CB_30min,AWS_CB_1hr);
               
               
               flds_all = {'1min_avg','10min_avg','30min_avg','10sec','1min','10min','30min','1hr'};
               flds_var = {'T1','T2','RH1','RH2','WS1','WS2','WD1','WD2','Time'};
               
               for ii = 1:length(flds_var)
                   for jj = 1:length(flds_all)
                       if strcmp(flds_var{ii},'Time')
                           AWS_CB(1).([flds_var{ii} '_' flds_all{jj}])      = datenum(eval(['AWS_CB_' flds_all{jj} '.' flds_var{ii}]));
                       else 
                           AWS_CB(1).([flds_var{ii} '_' flds_all{jj}])      = eval(['AWS_CB_' flds_all{jj} '.' flds_var{ii}]);
                       end
                   end
               end
            
               
disp(['------------------------------------'])
disp(['Done reading files from Campbell AWS'])
disp(['------------------------------------'])
               
% clearvars -except AWS_CB*
               
               

                
                
                
                