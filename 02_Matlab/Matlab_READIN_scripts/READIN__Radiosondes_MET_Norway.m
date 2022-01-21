
clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ------------------------- READING DATA FROM RADIOSONDES ------------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% RADIOSONDE data can be downloaded from this URL: https://thredds.met.no/thredds/catalog/remotesensingradiosonde/catalog.html



%% INPUT: MAKE SURE THAT THE PATH TO THE DATA IS CORRECT IN SET_FILEPATHS
[filepath,~,~] = fileparts(mfilename('fullpath'));
cd(filepath)
run ./../set_filepaths

%% INPUT: PATH TO FILE AND FILE:
%       make sure this is set correctly before you attempt to run the script!
  

cd(Radiosondes_met_norway_path);

files = dir('*.nc');


for ii = 1:length(files)
 
    radio(ii).station_name = fileinfo(1).Attributes(8).Value;
    radio(ii).lat          = fileinfo(1).Attributes(10).Value.*100;
    radio(ii).lon          = fileinfo(1).Attributes(11).Value.*100;
    
    fileinfo(1).Attributes(8).Value
    
 % GETTING INFORMATION ABOUT THE FILE, INCLUDING PARAMETER NAMES ETC, AND
 %  STORING IT IN THE STRUCTURE "fileinfo".
 fileinfo = ncinfo(files(ii).name);

% Reading time in the data file
 tm = ncread(file,'time');

% Reading the other variables from the data file
for nn = 1:length(tm)
    start = [1 nn]; count = [inf 1]; stride = [1 1];
    
    radio(ii).prof(nn).time      = double(ncread(file,'time',nn,1,1))./24/60/60 + datenum([1970 01 01 00 00 00]);
    
    radio(ii).prof(nn).T      = ncread(file,'air_temperature',start,count,stride);
    radio(ii).prof(nn).TD     = ncread(file,'dew_point_temperature',start,count,stride);
    radio(ii).prof(nn).RH     = ncread(file,'relative_humidity',start,count,stride);
    radio(ii).prof(nn).WS     = ncread(file,'wind_speed',start,count,stride);
    radio(ii).prof(nn).WD     = ncread(file,'wind_from_direction',start,count,stride);
    radio(ii).prof(nn).P      = ncread(file,'air_pressure',start,count,stride);
    radio(ii).prof(nn).height = ncread(file,'altitude',start,count,stride);
    
end

% Calculating potential temperature and specific humidity
for nn = 1:length(tm)
    T  = radio(ii).prof(nn).T - 273.15;
    RH = radio(ii).prof(nn).RH;
    P  = abs(radio(ii).prof(nn).P);

    radio(ii).prof(nn).TP = calc_pot_temp(T,P);    
    radio(ii).prof(nn).Q  = calc_spec_humid(T,RH,P);
end

end

disp(['-----------------------------------'])
disp(['Done reading files from RADIOSONDES'])
disp(['-----------------------------------'])






