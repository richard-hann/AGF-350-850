
% This is a model of downwelling shortwave radiation at the surface with no cloud cover.

% !!!! IMPORTANT !!!!
% Make sure that these scripts are in your Matlab Path:
% READIN_Radiation_Portable_and_SEB.m (in the   Fieldwork/Matlab/scripts  folder on the Google Drive)
% sunpos.m (in the   Fieldwork/Matlab/Toolboxes  folder on the Google Drive)



clear 
clc

% READING RADIATION DATA
    READIN_Radiation_Portable_and_SEB

% defining time vector
	commontime = RAD(1).time_30min;


dr = 173;    % the day of summer solstice
dy = 365.25; % the average nuber of days per year
S = 1370;    % incoming solar irradiance toa

lat = 78.0574;   % latitude degrees (positive north)
lon = -13.5900;  % longitude degrees (positive west)

clear el az dist
for i=1:length(commontime)
k = datevec(commontime(i));
[el(i),az(i),dist(i)] = sunpos(k(3),k(2),k(1),k(4),k(5),k(6),lat,lon);
end
sin_psin=el;
sin_psirad=deg2rad(sin_psin);

% Transmissivity no clouds
T_k = (0.6 + 0.2*sin_psirad);
K = S.*T_k.*sin_psirad;
for i= 1:length(K)
    if K(i) < 0
        K(i) = 0;
    end
end

%%

modelled_radiation = K;


% PLOTTING RESULTS

close all
hold on

plot(commontime,modelled_radiation)
plot(commontime,RAD(1).sw_down_30min)
datetick('x')

