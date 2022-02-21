clear
clc
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ------------------------- READING DATA FROM AROME ARCTIC -----------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% -------- MAKE SURE TO CHOOSE THE RIGHT SETTINGS IN THIS SECTION --------

%% INPUT: MAKE SURE THAT THE PATH TO THE DATA IS CORRECT IN SET_FILEPATHS

% tmp = matlab.desktop.editor.getActive;
% cd(fileparts(tmp.Filename))

[filepath,~,~] = fileparts(mfilename('fullpath'));
cd(filepath)
run ./../set_filepaths

addpath(genpath(toolboxpath))
staticfieldspath=AROME_ARCTIC_path;



%% INPUT Retrieve 2.5 km data (1) or 500 m data (2)
select_resolution = 1;

%% INPUT Setting for what type of files to retrieve
% note, if selecting historical forecast, remember to define the start-time and end-times below
% !!!!! NB: LATEST = 1 ONLY WORKS FOR 2.5 km DATA, and NOT 500m DATA !!!!
LATEST       = 0;  % Choose whether to retrieve historical forecast (0) or latest forecast (1). If 0, set start- and end-time below.


%% INPUT Settings for what type of data to retrieve. 
    % Normally, only one is selecteed at a time
NEARSURFACE     = 0;  % Choose whether to retrieve near-surface data (1) or not (0)
PROFILES        = 0;  % Choose whether to retrieve profile data (1) or not (0)
HORIZONTAL2D    = 1;  % Choose whether to retrieve horizontal 2D data (1) or not (0)
CROSSECTION     = 0;  % Choose whether to retrieve cross-section data (1) or not (0)
PRESSURE_LEVELS = 0;  % Choose whether to retrieve pressure level data (1) or not (0)

% List of pressure levels, 2.5km:
% plevels = ncread('https://thredds.met.no/thredds/dodsC/aromearcticlatest/arome_arctic_extracted_2_5km_latest.nc','pressure');
%   => p_levels = [50,100,150,200,250,300,400,500,700,800,850,925,1000]
p_lvl_start = [10]; % this is the start index in the vector (see vector above)
p_lvl_num   = [4];  % this is the number of vector elements (pressure levels)
p_lvl_int   = [1];  % this is the interval between each pressure level


%% INPUT Settings for what time stamps to retrieve
start_h      = 1; % Start time index in each data file
num_h        = 24; % Number of data-points (hours) to retrieve from each data file
% num_h        = 24;  % Number of data-points (hours) to retrieve from each data file
int_h        = 1; % Time interval between data points in each data file
int_f        = 24; % Time interval in hours between each data file if retrieving historical data. Only relevant for historical data. This is typically the same as num_h.


%%
% If retrieving horizontal2d data, 
% set the intervals between the x and y coordinates here 
% (higher number = coarser grid selection). 
% For example, 1 = every grid point. 3 = every third grid point.
int_x        = 1;
int_y        = 1;


if LATEST == 0
    % Define start- and end-points in time for retrieving the historical data
        starttime = datenum([2022 02 08 00 00 00]); % READ DATA FROM THIS TIME (yyyy mm dd HH MM SS)
        endtime   = datenum([2022 02 10 00 00 00]); % READ DATA UNTIL THIS TIME (yyyy mm dd HH MM SS)
        timevec   = starttime:int_f/24:endtime;
end



%% INPUT ----------------- Station list for point data ---------------
%   Specify list of stations
% NY-ÅLESUND
  STT(1).lon = 11.9312;
  STT(1).lat = 78.9243;
% ISFJORD RADIO  
%   STT(2).lon = 13.61439;
%   STT(2).lat = 78.06150;
% BJØRNØYA
%   STT(3).lon = 19.0050;
%   STT(3).lat = 74.51677;
% -------------------------------------------------------------


%% INPUT ------------- Geographic domain for horizontal 2d data ------
%   Specify min and max longitude and latitudes
    lonlims = [05, 40];
    latlims = [75, 80];
%     lonlims = [00, 45];
%     latlims = [74, 81];
% -------------------------------------------------------------


% ---- Start- and end-points for vertical cross section -------
    startpoint = [15.00 78.35]; % lon lat
    endpoint   = [15.98 78.18]; % lon lat
% -------------------------------------------------------------



% -------------- Specify variables to be retrieved ------------

if NEARSURFACE == 1
    % Names as given in the netcdf files on the MET server
        varnames = {'x_wind_10m','y_wind_10m','surface_air_pressure','air_temperature_2m','relative_humidity_2m'};
    % Define corresponding variable names for Matlab structure
        fldnames = {'u10r','v10r','PSFC','T2','RH2'};
end

if PROFILES == 1
    % Names as given in the netcdf files on the MET server
        varnames = {'x_wind_ml','y_wind_ml','air_temperature_ml','surface_air_pressure','air_temperature_0m','specific_humidity_ml'};
    % Define corresponding variable names for Matlab structure
        fldnames = {'ur','vr','T','PSFC','t0','Q'};
end

if HORIZONTAL2D == 1
%     % Names as given in the netcdf files on the MET server
%         varnames = {'x_wind_10m','y_wind_10m','surface_air_pressure','air_temperature_2m','relative_humidity_2m','cloud_area_fraction','precipitation_amount_acc','integral_of_surface_downward_sensible_heat_flux_wrt_time'};
%     % Define corresponding variable names for Matlab structure
%         fldnames = {'u10r','v10r','PSFC','T2','RH2','cc','prec','SHF'};
        

% %     % Names as given in the netcdf files on the MET server
%         varnames = {'x_wind_10m','y_wind_10m','integral_of_surface_downward_sensible_heat_flux_wrt_time','integral_of_surface_downward_latent_heat_flux_wrt_time'};
% %     % Define corresponding variable names for Matlab structure
%         fldnames = {'u10r','v10r','SHF','LHF'};


    % Names as given in the netcdf files on the MET server
        varnames = {'x_wind_10m','y_wind_10m','air_temperature_2m'};
    % Define corresponding variable names for Matlab structure
        fldnames = {'u10r','v10r','T2'};       
end

if PRESSURE_LEVELS == 1
    % Names as given in the netcdf files on the MET server
        varnames = {'x_wind_pl','y_wind_pl'};
    % Define corresponding variable names for Matlab structure
        fldnames = {'ur','vr'};       
end

if CROSSECTION == 1
    % Names as given in the netcdf files on the MET server
        varnames = {'x_wind_ml','y_wind_ml','air_temperature_ml','surface_air_pressure','air_temperature_0m','specific_humidity_ml'};
    % Define corresponding variable names for Matlab structure
        fldnames = {'ur','vr','T','PSFC','t0','Q'};
end

% -------------------------------------------------------------------



%% --------------- THIS SECTION IS NORMALLY NOT CHANGED -------------------

% adding necessary toolboxes
    addpath(genpath(toolboxpath))
    addpath(genpath(staticfieldspath))

% Loading static fields
cd(staticfieldspath)
    if select_resolution == 1 
        load AA_longitude_full;              AROME_static(1).LON = AA_longitude_full;          clear AA_longitude_full
        load AA_latitude_full;               AROME_static(1).LAT = AA_latitude_full;           clear AA_latitude_full
        load AA_topo_height_full;            AROME_static(1).HGT = AA_topo_height_full./9.81;  clear AA_topo_height_full
        load AA_lsm;                         AROME_static(1).LSM = AA_lsm;                     clear AA_lsm
    elseif select_resolution == 2
        load AA_longitude_full_500m_2020;    AROME_static(1).LON = AA_longitude_full_500m_2020;                 clear AA_longitude_full_500m_2020
        load AA_latitude_full_500m_2020;     AROME_static(1).LAT = AA_latitude_full_500m_2020;                  clear AA_latitude_full_500m_2020
        load AA_topo_height_full_500m_2020;  AROME_static(1).HGT = AA_topo_height_full_500m_2020(:,:,1)./9.81;  clear AA_topo_height_full_500m_2020
        load AA_lsm_full_500m_2020;          AROME_static(1).LSM = AA_lsm_full_500m_2020(:,:,1);                clear AA_lsm_full_500m_2020
    end

    % Storing names of data files in a structure called 'fileurls'
    clear fileurls
if LATEST==1 % MOST RECENT FILES
    if PRESSURE_LEVELS == 0
        fileurls{1}='https://thredds.met.no/thredds/dodsC/aromearcticlatest/arome_arctic_full_2_5km_latest.nc';
    elseif PRESSURE_LEVELS == 1
        fileurls{1}='https://thredds.met.no/thredds/dodsC/aromearcticlatest/arome_arctic_extracted_2_5km_latest.nc';
    end
    
else % THEN HISTORICAL (ARCHIVED FILES)
    for i = 1:length(timevec)
        kk = datevec(timevec(i));
            if select_resolution == 1
                if PRESSURE_LEVELS == 0
                    fileurls{i} = ['https://thredds.met.no/thredds/dodsC/aromearcticarchive/' datestr(kk,'yyyy/mm/dd/')     'arome_arctic_full_2_5km_' datestr(kk,'yyyymmdd') 'T' datestr(kk,'HH') 'Z.nc'];
                elseif PRESSURE_LEVELS == 1
                    fileurls{i} = ['https://thredds.met.no/thredds/dodsC/aromearcticarchive/' datestr(kk,'yyyy/mm/dd/')     'arome_arctic_extracted_2_5km_' datestr(kk,'yyyymmdd') 'T' datestr(kk,'HH') 'Z.nc'];
                end
            elseif select_resolution == 2
                if PRESSURE_LEVELS == 0
%                     fileurls{i} = ['https://thredds.met.no/thredds/dodsC/metusers/yuriib/AGF-DCCCL/AS500_' datestr(kk,'yyyymmddHH') '.nc'];
                    fileurls{i} = ['https://thredds.met.no/thredds/dodsC/metusers/yuriib/UNIS-2022/AS500_' datestr(kk,'yyyymmddHH') '.nc'];
                elseif PRESSURE_LEVELS == 1
%                     fileurls{i} = ['https://thredds.met.no/thredds/dodsC/metusers/yuriib/AGF-DCCCL/AS500_' datestr(kk,'yyyymmddHH') '_fp.nc'];
                    fileurls{i} = ['https://thredds.met.no/thredds/dodsC/metusers/yuriib/UNIS-2022/AS500_' datestr(kk,'yyyymmddHH') '_fp.nc'];
                end
            end
    end
end

% Finding nearest model grid points (x,y) to the longitude and latitude coordinates of the stations in the station list

if NEARSURFACE == 1 || PROFILES == 1 
    clear coords_* *_closest
    for i = 1:length(STT)
        [coords_xx(i),coords_yy(i),lon_closest(i),lat_closest(i)] = lonlat2xy_Arome_Arctic(STT(i).lon,STT(i).lat,AROME_static(1).LON,AROME_static(1).LAT,1);

        AROME(i).lon_model = lon_closest(i);
        AROME(i).lat_model = lat_closest(i);

        AROME(i).lon_actual = STT(i).lon;
        AROME(i).lat_actual = STT(i).lat;

        AROME(i).HGT_model = AROME_static(1).HGT(coords_xx(i),coords_yy(i));
        AROME(i).LSM_model = AROME_static(1).LSM(coords_xx(i),coords_yy(i));
    end
end


if HORIZONTAL2D == 1 || PRESSURE_LEVELS == 1
    clear start_lonlat count_lonlat stride_lonlat
        [start_lonlat,count_lonlat,stride_lonlat] = lonlat2xy_Arome_Arctic(lonlims,latlims,AROME_static(1).LON,AROME_static(1).LAT,2);
        
            idx = start_lonlat(1):(start_lonlat(1)+(count_lonlat(1)));
            idy = start_lonlat(2):(start_lonlat(2)+(count_lonlat(2)));
            idxx = idx(1:int_x:int_x*round((count_lonlat(1)./int_x)));
            idyy = idy(1:int_y:int_y*round((count_lonlat(2)./int_y)));
            
                AROME(1).LON = AROME_static(1).LON(idxx,idyy);
                AROME(1).LAT = AROME_static(1).LAT(idxx,idyy);
                AROME(1).HGT = AROME_static(1).HGT(idxx,idyy);
                AROME(1).LSM = AROME_static(1).LSM(idxx,idyy);
end

if CROSSECTION == 1
    clear start_lonlat count_lonlat stride_lonlat
    lonlims=[min([startpoint(1) endpoint(1)]) max([startpoint(1) endpoint(1)])];
    latlims=[min([startpoint(2) endpoint(2)]) max([startpoint(2) endpoint(2)])];
        [start_lonlat,count_lonlat,stride_lonlat] = lonlat2xy_Arome_Arctic(lonlims,latlims,AROME_static(1).LON,AROME_static(1).LAT,2);
            start_lonlat = start_lonlat-2;
            count_lonlat = count_lonlat+5;
            
            idx = start_lonlat(1):(start_lonlat(1)+(count_lonlat(1)));
            idy = start_lonlat(2):(start_lonlat(2)+(count_lonlat(2)));
            idxx = idx(1:int_x:int_x*round((count_lonlat(1)./int_x)));
            idyy = idy(1:int_y:int_y*round((count_lonlat(2)./int_y)));
            
                AROME(1).LON = AROME_static(1).LON(idxx,idyy);
                AROME(1).LAT = AROME_static(1).LAT(idxx,idyy);
                AROME(1).HGT = AROME_static(1).HGT(idxx,idyy);
                AROME(1).LSM = AROME_static(1).LSM(idxx,idyy);
                
        close all
        hold on
        contourf(AROME(1).LON,AROME(1).LAT,AROME(1).HGT)
        plot([startpoint(1) endpoint(1)],[startpoint(2) endpoint(2)],'r') % marking location of cross section
        plot(AROME(1).LON(:),AROME(1).LAT(:),'.c') % marking model grid points with dots
end

      
if NEARSURFACE == 1 % Retrieving near-surface data
    Retrieve_nearsurface_Arome_Arctic
end

if PROFILES == 1 % Retrieving profile data
    Retrieve_profiles_Arome_Arctic
end

if HORIZONTAL2D == 1 || PRESSURE_LEVELS == 1  % Retrieving horizontal 2D data
    Retrieve_horizontal2d_Arome_Arctic
end

if CROSSECTION == 1 % Retrieving cross section data
    Retrieve_crossection_Arome_Arctic
end


% clearvars -except AROME* STT*

