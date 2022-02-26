

%% INPUT: MAKE SURE THAT THE PATH TO THE DATA IS CORRECT IN SET_FILEPATHS

tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename))

run ./../set_filepaths
addpath(genpath(toolboxpath))


cd(DEM_path)
load dem_nordenskioldland % Loading terrain data for the Adventdalen area
     

%%

close all
lonlims=[14, 18];
latlims=[77.9, 78.4];

m_proj('lambert','long',lonlims,'lat',latlims);

cint = [-300:25:-25 5 100:100:1100];

m_contourf(dem(1).lon,dem(1).lat,dem(1).hgt,cint);

caxis([cint(1) cint(end)]);   
colormap([m_colmap('blues',32);m_colmap('bland',128)]);

m_grid('box','fancy','tickdir','out','grid','none','fontsize',14);

m_contfbar( [.3 .7],.98, dem(1).hgt,cint,...
            'axfrac',.02,'endpiece','no','levels','match');


