
% run the following script to read in data from the iMET sensor
%   READIN__iMET
clc

%% INPUT: MAKE SURE THAT THE PATH TO THE DATA IS CORRECT IN SET_FILEPATHS

tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename))

run ./../set_filepaths
addpath(genpath(toolboxpath))


cd(DEM_path)
load dem_adventdalen % Loading terrain data for the Adventdalen area
     
        
%%      DRAWING VARIABLES ON A MAP


close all

% select transect ID to be plotted on the map:

qq = 1;

% select variable to be plotted on the map (in this example temperature)
varrn = imet(qq).T; 
lon = imet(qq).lon;
lat = imet(qq).lat;


% ----------- Define the color span (c_span) for the variable ----------------------
% select a sensible range
% HINT: for the range selection, plot first the variable in a separate
% figure to find the maximum and minimum values: plot(imet(qq).T)


% If the variable you plot doesn't fall within the range, no data would be
% plotted! (e.g. range [1 3] for pressure in hPa)

  c_span=[-28 -19];
 
% optional:
% setting all indices in the variable that is outside the c_span to NaN
% kk = find(varrn < c_span(1) | varrn > c_span(2));
% lon(kk) = nan;
% lat(kk) = nan;
% varrn(kk) = nan;


close all

% ---- Plotting data on the map

% Define the longitude and lat
lonlim = [15.5 16.1];
latlim = [78.09 78.280];
hold on
intt = 2;
% Plotting the background map (DEM)-----
contour(dem.lon(1:intt:end,1:intt:end),dem.lat(1:intt:end,1:intt:end),dem.hgt(1:intt:end,1:intt:end),[50:50:1500],'color','k')
contour(dem.lon(1:intt:end,1:intt:end),dem.lat(1:intt:end,1:intt:end),dem.hgt(1:intt:end,1:intt:end),[0.0001 0.0001],'color','k')


% Plot the data (varrn) on the map
hold on
scatter(lon,lat,50,varrn,'filled')

caxis(c_span)

g = colorbar;
set(g,'FontSize',14)
title(g,'\circC','FontSize',14);

set(gca,'FontSize',12)

xlim(lonlim)
ylim(latlim)

box on

% choose colormap:
%  uncommont the one you like the best

cmap = cmocean('haline');
      colormap(gca,cmap)

% cmap = cmocean('thermal');
%       colormap(gca,cmap)

% cmap = bluewhitered_V3;
%       colormap(gca,cmap);
            
% cmap = colorcet('R1');
%       colormap(gca,cmap)





