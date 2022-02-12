

% run the following script to read in data from the drone-mounted iMet.
% Make sure to adapt the path to drone iMet data
%   READIN__iMET




close all

%% SELECT WHICH FILE TO LOAD
qq = 1; % File ID

%% First plot the altitude data so that you can see when the different profiles are taken:
%% USE THIS TO SET THE IDs FOR EACH PROFILE, BELOW
figure(1)
plot(imet(qq).P)


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

% %% for qq=4
% id(1).n = 481:991;  % marine
% id(2).n = 991:1517; % marine
% id(3).n = 1858:2259; %malerdalen
% id(4).n = 2318:3054; %malerdalen
% id(5).n = 3459:3790; %supersite
% id(6).n = 3790:4183; %supersite
% id(7).n = 4183:4473; %supersite
% id(8).n = 4682:5684; %supersite
% id(9).n = 5810:6238; %endalen
% id(10).n = 6238:6849; %endalen

%% Let's plot these temperature and humidity profiles:
%    (note that the RH sensor in this file was broken)

%close all
for i = 1:length(id)
    [z p]=p2alt_UAS(imet(qq).P(id(i).n), 0.05, imet(qq).T(id(i).n),imet(qq).time(id(i).n));

    figure(i+1)
    subplot(1,2,1)
        plot(imet(qq).T(id(i).n),imet(qq).alt(id(i).n))
        xlabel('Temperature [°C]')
        ylabel('GPS Altitude [m]')
    subplot(1,2,2)
        %plot(imet(qq).T(id(i).n),imet(qq).P(id(i).n))
        plot(imet(qq).T(id(i).n),z)
        %set(gca,'Ydir','reverse')
        xlabel('Temperature [°C]')
        ylabel('Pressure ALtitude [m]')
        ylim([-10 130]);
end









