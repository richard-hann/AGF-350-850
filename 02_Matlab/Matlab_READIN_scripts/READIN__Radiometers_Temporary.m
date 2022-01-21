
clc
clear
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ----------------------- READING RADIATION DATA FROM RADIOMETERS -----------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INPUT: BEFORE RUNNING SCRIPT, MAKE SURE THAT THE PATH TO THE DATA IS CORRECT IN THE FILE set_filepaths.m


[filepath,~,~] = fileparts(mfilename('fullpath'));
cd(filepath)

run ./../set_filepaths
addpath(genpath(toolboxpath))


% Dataset 1 = Temporary radiometer 1. This radiometer does not have a memory card
% Dataset 2 = Temporary radiometer 2. This radiometer has a memory card


for qq = 1:2 % looping over data sets


if qq == 1
% INPUT: File Location
cd(Radiometer_Temporary_1_path)
   
elseif qq == 2
% INPUT: File location
cd(Radiometer_Temporary_2_path)

end


zk = dir('*.dat'); % Storing all names of log files in the data folder in a structure 'zk'

% preparing structure RAD for parameter input
RAD(qq).time_a=[];
RAD(qq).sw_down_a=[];
RAD(qq).sw_up_a=[];
RAD(qq).lw_down_a=[];
RAD(qq).lw_up_a=[];
RAD(qq).bat_volt_a=[];
RAD(qq).logger_T_a=[];


% Reading radiation data

for j=1:length(zk) % looping over all the data files
filet=zk(j).name;

fill = char(filet);

fid = fopen(filet, 'r'); % open file
l = fread(fid,'*char');  % read file
fclose(fid)              % close file
str=l';

      % removing unwanted symbols from data
      k=char(str);
        pp=findstr(k,'"');
      k(pp)=' ';
        pp=findstr(k,',');
      k(pp)=' ';
       k = strrep(k,'NAN','-9999');
      % done removing unwanted symbols from data

   % reading data file
   hlines=4;   % This is the number of headerlines in the file, we do not want to read these

  
      [year_n, month_n, day_n, hour_n, min_n, sec_n, rec_number,sw_down,sw_up,what1,what2,logger_T,lw_down,lw_up, logger_V] = strread(k,'%4f- %2f- %2f %2f: %2f: %2f %s %f %f %f %f %f %f %f %f','headerlines',hlines);
 
  
 % making time vector     
 timenumber = datenum(year_n, month_n, day_n, hour_n, min_n, sec_n);
  
 % Concatenating (putting together) data from each of the data files
RAD(qq).time_a     = [RAD(qq).time_a(:)' timenumber(:)'];
RAD(qq).sw_down_a  = [RAD(qq).sw_down_a(:)' sw_down(:)'];   % downwelling shortwave radiation
RAD(qq).sw_up_a    = [RAD(qq).sw_up_a(:)' sw_up(:)'];       % upwelling shortwave radiation
RAD(qq).lw_down_a  = [RAD(qq).lw_down_a(:)' lw_down(:)'];   % downwelling longwave radiation
RAD(qq).lw_up_a    = [RAD(qq).lw_up_a(:)' lw_up(:)'];       % upwelling longwave radiation
% RAD(qq).bat_volt_a = [RAD(qq).bat_volt_a(:)' bat_volt(:)'];
RAD(qq).logger_T_a = [RAD(qq).logger_T_a(:)' logger_T(:)']; % logger temperature
 
end
 
% Sorting data from the files in case they are not in the right order
 [a b] = sort(RAD(qq).time_a);
RAD(qq).time       = RAD(qq).time_a(b);
RAD(qq).sw_down    = RAD(qq).sw_down_a(b);      % downwelling shortwave radiation
RAD(qq).sw_up      = RAD(qq).sw_up_a(b);        % upwelling shortwave radiation
RAD(qq).lw_down_nn = RAD(qq).lw_down_a(b);      % downwelling longwave radiation
RAD(qq).lw_up_nn   = RAD(qq).lw_up_a(b);        % upwelling longwave radiation
RAD(qq).logger_T   = RAD(qq).logger_T_a(b);     % logger temperature


    RAD(qq).lw_down    = RAD(qq).lw_down_nn;
    RAD(qq).lw_up      = RAD(qq).lw_up_nn;


RAD(qq).lw_up(RAD(qq).lw_up < -100) = nan;

% % CORRECTING TIME (if logger time is wrong)
% % utcstart=datenum('20150412144300','yyyymmddHHMMSS');
% % RAD(qq).time=RAD(qq).timen-(RAD(qq).timen(qq)-utcstart);
% RAD(qq).time=RAD(qq).timen;

% Removing temporary fields from the RAD structure
RAD = rmfield(RAD,{'sw_down_a','lw_down_a','lw_up_a','sw_up_a','bat_volt_a','logger_T_a','lw_down_nn','lw_up_nn','time_a'});


% Calculating surface temp using Stefan Boltzmanns law and taking reflected longwave radiation into account:
    sigmm = 5.67*10^(-8); % boltzmanns constant
    epss  = 0.9; % emissivity

    RAD(qq).Tsurf = ((RAD(qq).lw_up-(1-epss)*RAD(qq).lw_down)./(epss*sigmm)).^(1/4)-273.15;

   
end

% clearvars -except RAD*

disp(['-----------------------------------'])
disp(['Done reading files from radiometers'])
disp(['-----------------------------------'])

