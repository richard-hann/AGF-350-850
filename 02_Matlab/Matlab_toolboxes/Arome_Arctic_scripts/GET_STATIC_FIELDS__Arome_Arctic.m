
    

[filepath,~,~] = fileparts(mfilename('fullpath'));
cd(filepath)

cd('../../../../Data/2020_data/AROME_ARCTIC')
% cd('Data')

% % FOR 500m domain
%    AA_longitude_full_500m_2020 = ncread(char(fileurls(1)),'longitude');
%    AA_latitude_full_500m_2020 = ncread(char(fileurls(1)),'latitude');
%    AA_topo_height_full_500m_2020 = ncread(char(fileurls(1)),'surface_geopotential');
%    AA_lsm_full_500m_2020 = ncread(char(fileurls(1)),'land_area_fraction');
%    
%    save AA_longitude_full_500m_2020 AA_longitude_full_500m_2020
%    save AA_latitude_full_500m_2020 AA_latitude_full_500m_2020
%    save AA_topo_height_full_500m_2020 AA_topo_height_full_500m_2020
%    save AA_lsm_full_500m_2020 AA_lsm_full_500m_2020
   
% for 2.5km domain
file = 'https://thredds.met.no/thredds/dodsC/aromearcticlatest/arome_arctic_full_2_5km_latest.nc'; 
   AA_longitude_full    = ncread(file,'longitude');
   AA_latitude_full     = ncread(file,'latitude');
   AA_topo_height_full  = ncread(file,'surface_geopotential');
   AA_lsm               = ncread(file,'land_area_fraction');
%    save AA_longitude_full AA_longitude_full
%    save AA_latitude_full AA_latitude_full
%    save AA_topo_height_full AA_topo_height_full
%    save AA_lsm AA_lsm


% for 2.5km domain 'extracted'
file = 'https://thredds.met.no/thredds/dodsC/aromearcticlatest/arome_arctic_extracted_2_5km_latest.nc'; 
   AA_longitude_extracted    = ncread(file,'longitude');
   AA_latitude_extracted     = ncread(file,'latitude');
   AA_topo_height_extracted  = ncread(file,'surface_geopotential');
   AA_lsm_extracted          = ncread(file,'surface_snow_sublimation_amount_acc');
   
   %%

%    surface_snow_sublimation_amount_acc
   
%    arome_arctic_extracted_2_5km_latest.nc
   