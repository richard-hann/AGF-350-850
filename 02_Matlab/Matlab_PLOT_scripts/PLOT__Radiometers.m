
% run the following script to read in data from the radiometers
%   READIN__Radiometers
%% INPUT: Set the CB ID (qq) to choose which radiometer you want to plot data from

qq = 3; %


clc

close all

subplot(2,3,1)
hold on
plot(RAD(qq).time,RAD(qq).sw_down,'-','LineWidth',2)
xlabel('Time (dd.mm)')
ylabel('Shortwave down (W m^{-2})')
ylim([0 360])
datetick('x')
grid on

subplot(2,3,2)
hold on
plot(RAD(qq).time,RAD(qq).sw_up,'-','LineWidth',2)
xlabel('Time (dd.mm)')
ylabel('Shortwave up (W m^{-2})')
ylim([0 360])
datetick('x')
grid on

subplot(2,3,3)
hold on
plot(RAD(qq).time,RAD(qq).lw_down,'-','LineWidth',2)
xlabel('Time (dd.mm)')
ylabel('Longwave down (W m^{-2})')
ylim([100 450])
datetick('x')
grid on

subplot(2,3,4)
hold on
plot(RAD(qq).time,RAD(qq).lw_up,'-','LineWidth',2)
xlabel('Time (dd.mm)')
ylabel('Longwave up (W m^{-2})')
ylim([100 450])
datetick('x')
grid on

subplot(2,3,5)
hold on
plot(RAD(qq).time,RAD(qq).Tsurf,'-','LineWidth',2)
xlabel('Time (dd.mm)')
ylabel('Surface temperature (\circC)')
ylim([-20 15])
datetick('x')
grid on


set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',12,'FontWeight','Bold', 'LineWidth', 1,'layer','top','box','on');
set(gcf,'position',[100 100 1500 600])

