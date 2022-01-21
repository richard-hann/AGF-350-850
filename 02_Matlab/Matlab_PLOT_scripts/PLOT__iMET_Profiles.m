

% run the following script to read in data from the Campbell AWS
%   READIN__iMet


%% First plot the altitude data so that you can see when the different profiles are taken:

close all

qq = 1; % File ID

figure(1)
plot(imet(qq).alt)


%% For the example ("TEST") file 20210908-184113-00053025__CLEANED.csv
% we can see that there profiles for (for example) the following indices:

clear id
id(1).n = 87:240;
id(2).n = 267:470;
id(3).n = 1042:1256;


%% Let's plot these temperature and humidity profiles:
%    (note that the RH sensor in this file was broken)

close all
for i = 1:length(id)
figure(i)

subplot(1,2,1)
    plot(imet(qq).T(id(i).n),imet(qq).alt(id(i).n))
subplot(1,2,2)
    plot(imet(qq).RH(id(i).n),imet(qq).alt(id(i).n))
end









