
% run the following script to read in data from the HOBO AWS
%   READIN__Radiosondes_MET_Norway

clc
%% INPUT: Choose HOBO ID
qq = 1; % choose which radiosonde station to plot data from
nn = 2; % choose which radiosonde ID to plot data from


%%
close all

figure(1)
sgtitle([radio(qq).station_name '  ' datestr(radio(qq).prof(nn).time)],'interpreter','none')

subplot(3,3,1)
    plot(radio(qq).prof(nn).T-273.15,radio(qq).prof(nn).height) 
    ylim([0 5000])
    xlabel('Temperature (\circC)')
    ylabel('Height (m AGL)')
    grid on

subplot(3,3,2)
    plot(radio(qq).prof(nn).RH,radio(qq).prof(nn).height) 
    ylim([0 5000])
    xlabel('Relative humidity (%)')
    ylabel('Height (m AGL)')
    grid on

subplot(3,3,3)
    plot(radio(qq).prof(nn).WS,radio(qq).prof(nn).height) 
    ylim([0 5000])
    xlabel('Wind speed (m/s)')
    ylabel('Height (m AGL)')
    grid on

subplot(3,3,4)
    plot(radio(qq).prof(nn).WD,radio(qq).prof(nn).height) 
    ylim([0 5000])
    xlabel('Wind direction (\circ)')
    ylabel('Height (m AGL)')
    grid on

subplot(3,3,5)
    plot(radio(qq).prof(nn).TP,radio(qq).prof(nn).height) 
    ylim([0 5000])
    xlabel('Potential Temperature (\circC)')
    ylabel('Height (m AGL)')
    grid on

subplot(3,3,6)
    plot(radio(qq).prof(nn).Q,radio(qq).prof(nn).height) 
    ylim([0 5000])
    xlabel('Specific Humidity (g/kg)')
    ylabel('Height (m AGL)')
    grid on


set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',9,'FontWeight','Bold','LineWidth',1,'layer','top','box','on');
set(gcf,'position',[100 100 1500 600])