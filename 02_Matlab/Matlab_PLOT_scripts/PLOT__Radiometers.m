
% run the following script to read in data from the radiometers
%   READIN__Radiometers
%% INPUT: Set the CB ID (qq) to choose which radiometer you want to plot data from

qq = 2; %


id1 = datenum([2022 02 06 00 00 00]);
id2 = datenum([2022 02 14 00 00 00]);
idd = find(RAD(qq).time >= id1 & RAD(qq).time <= id2);

clc

close all

subplot(2,3,1)
hold on
plot(RAD(qq).time(idd),RAD(qq).sw_down(idd),'-','LineWidth',2)
xlabel('Time (dd)')
ylabel('Shortwave down (W m^{-2})')
ylim([0 360])
datetick('x','dd','keeplimits')
grid on

subplot(2,3,2)
hold on
plot(RAD(qq).time(idd),RAD(qq).sw_up(idd),'-','LineWidth',2)
xlabel('Time (dd)')
ylabel('Shortwave up (W m^{-2})')
ylim([0 360])
datetick('x','dd','keeplimits')
grid on

subplot(2,3,3)
hold on
plot(RAD(qq).time(idd),RAD(qq).lw_down(idd),'-','LineWidth',2)
xlabel('Time (dd)')
ylabel('Longwave down (W m^{-2})')
ylim([100 450])
datetick('x','dd','keeplimits')
grid on

subplot(2,3,4)
hold on
plot(RAD(qq).time(idd),RAD(qq).lw_up(idd),'-','LineWidth',2)
xlabel('Time (dd)')
ylabel('Longwave up (W m^{-2})')
ylim([100 450])
datetick('x','dd','keeplimits')
grid on

subplot(2,3,5)
hold on
plot(RAD(qq).time(idd),RAD(qq).Tsurf(idd),'-','LineWidth',2)
xlabel('Time (dd)')
ylabel('Surface temperature (\circC)')
ylim([-30 0])
datetick('x','dd','keeplimits')
grid on


set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',12,'FontWeight','Bold', 'LineWidth', 1,'layer','top','box','on');
set(gcf,'position',[100 100 1500 600])

