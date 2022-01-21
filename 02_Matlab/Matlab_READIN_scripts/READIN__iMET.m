clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ------------------------ READING DATA FROM iMET XQ2 sensor ---------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% INPUT: BEFORE RUNNING SCRIPT, MAKE SURE THAT THE PATH TO THE DATA IS CORRECT IN THE FILE set_filepaths.m


[filepath,~,~] = fileparts(mfilename('fullpath'));
cd(filepath)
run ./../set_filepaths


addpath(genpath(toolboxpath))

% cd(iMET_drones_path)
cd(iMET_transects_path)

  
gn = 1;


% storing all filenames in structure kk
kk = dir('*.csv');
% kk = dir('20210908-184113-00053025__CLEANED.csv');
% kk = dir('20210909-202340-00053025__CLEANED.csv');
% kk = dir('20210914-070501-00053025__CLEANED.csv');

for qq=1:length(kk) % looping over files
%     for qq = 1 % looping over files

    imet(qq).name = kk(qq).name;
   
ff = csvimport(imet(qq).name); % reading file

k = find(cellfun('isempty',ff(2:end,1))==0);

ff = ff(k,:);


try 
    kz = findstr(ff{1+1,41},'/');
    fullfile = 1;
    id1 = 41;
    id2 = 42;
catch
    kz = findstr(ff{1+1,5},'/');
    fullfile = 0;
    id1 = 5;
    id2 = 6;
end
   
if kz(1) == 3 && kz(2) == 6
    tformat = 'dd/mm/yyyy HH:MM:SS'; 
elseif kz(1) == 2 && kz(2) == 5
    tformat = 'dd/mm/yyyy HH:MM:SS'; 
else
    tformat = 'yyyy/mm/dd HH:MM:SS';
end

if strcmp(imet(qq).name(1:10),'AGF350_850')
    tformat = 'mm/dd/yyyy HH:MM:SS';
end

if fullfile == 1
    for i=1:length(ff)-1
        try
            imet(qq).time(i) = datenum([ff{i+1,id1} ' ' ff{i+1,id2}],tformat);
        catch
            imet(qq).time(i) = nan; 
        end
    end
elseif fullfile == 0
    for i=1:length(ff)-1
        try
            imet(qq).time(i) = datenum([ff{i+1,id1} ' ' ff{i+1,id2}],tformat);
        catch
            imet(qq).time(i) = nan; 
        end
    end 
end


try

    imet(qq).P   = cell2mat(ff(2:end,id1-4)); % Pressure
    imet(qq).T   = cell2mat(ff(2:end,id1-3)); % Temperature
    imet(qq).RH  = cell2mat(ff(2:end,id1-2)); % Relative humidity
    imet(qq).RHT = cell2mat(ff(2:end,id1-1)); % Temperature (from the RH sensor)
    imet(qq).lon = cell2mat(ff(2:end,id1+2)); % Longitude (from GPS)
    imet(qq).lat = cell2mat(ff(2:end,id1+3)); % Latitude (from GPS)
    imet(qq).alt = cell2mat(ff(2:end,id1+4)); % Altitude (above sea level, from GPS)
    
catch
    
    imet(qq).P   = str2num(char(ff(2:end,id1-4))); % Pressure
    imet(qq).T   = str2num(char(ff(2:end,id1-3))); % Temperature
    imet(qq).RH  = str2num(char(ff(2:end,id1-2))); % Relative humidity
    imet(qq).RHT = str2num(char(ff(2:end,id1-1))); % Temperature (from the RH sensor)
    imet(qq).lon = str2num(char(ff(2:end,id1+2))); % Longitude (from GPS)
    imet(qq).lat = str2num(char(ff(2:end,id1+3))); % Latitude (from GPS)
    imet(qq).alt = str2num(char(ff(2:end,id1+4))); % Altitude (above sea level, from GPS)
    
end

    % Calculating specific humidity
    imet(qq).Q = calc_spec_humid(imet(qq).T,imet(qq).RH,imet(qq).P);
    
    % Calculating potential temperature
    imet(qq).TP = calc_pot_temp(imet(1).T,imet(1).P);
    
    % Filtering unrealistic values from the GPS data
    imet(qq).lat(imet(qq).lat > 80 | imet(qq).lat < 70) = nan;
    imet(qq).lon(imet(qq).lon > 30 | imet(qq).lat < 0) = nan;
    
    imet(qq).alt(imet(qq).alt < -100 | imet(qq).alt > 1000) = nan;
       
    end

    
disp(['------------------------------------'])
disp(['--- Done reading files from iMet ---'])
disp(['------------------------------------'])





