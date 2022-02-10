

% run the following script to read in data from the drone-mounted iMet.
% Make sure to adapt the path to drone iMet data
%   READIN__iMET


%% First plot the altitude data so that you can see when the different profiles are taken:

close all


qq = 2; % File ID

figure(1)
plot(imet(qq).alt)


%% For the example ("TEST") file 20210908-184113-00053025__CLEANED.csv
% we can see that there profiles for (for example) the following indices:
clear id
id(1).n = 1:1162;
id(2).n = 1163:2224;

clear id
%% for qq=1
% id(1).n = 317:612;    %supersite
% id(2).n = 613:900;    %supersite
% id(3).n = 900:1178;   %supersite
% id(4).n = 1178:1700;  %supersite
% id(5).n = 1700:2120;  %supersite
% 
% %% for qq=2
% id(1).n = 558:959;      %marine
% id(2).n = 1045:1555;    %marine
% id(3).n = 2000:2659;    %supersite
% id(4).n = 2759:2870;    %supersite
% id(5).n = 3384:3722;    %supersite
% id(6).n = 3914:4429;    %supersite
% id(7).n = 4762:5151;    %endalen
% id(8).n = 5151:5791;    %endalen

%% Let's plot these temperature and humidity profiles:
%    (note that the RH sensor in this file was broken)

%close all
for i = 1:length(id)
figure(i+1)
subplot(1,2,1)
    plot(imet(qq).T(id(i).n),imet(qq).alt(id(i).n))
    xlabel('Temperature [°C]')
    ylabel('GPS Altitude [m]')
subplot(1,2,2)
    plot(imet(qq).T(id(i).n),imet(qq).P(id(i).n))
    set(gca,'Ydir','reverse')
    xlabel('Temperature [°C]')
    ylabel('Pressure [hPa]')
end









