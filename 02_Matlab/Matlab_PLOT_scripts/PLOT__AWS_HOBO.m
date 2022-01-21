
% run the following script to read in data from the HOBO AWS
%   READIN__AWS_HOBO 

clc
%% INPUT: Choose HOBO ID
qq = 1; % AWS_HOBO id, choose which station to plot data from

close all

xticks = AWS_HOBO(qq).time_30min(1):1:AWS_HOBO(qq).time_30min(end);

subplot(2,3,1)
hold on
% plot(AWS_HOBO(qq).time_30min,AWS_HOBO(qq).WD_1_30min)
plot(AWS_HOBO(qq).time_30min,AWS_HOBO(qq).WD_2_30min)
legend('WD 2')
ylim([0 360])
set(gca,'xtick',xticks)
datetick('x','keepticks')

subplot(2,3,2)
hold on
plot(AWS_HOBO(qq).time_30min,AWS_HOBO(qq).WS_1_30min)
plot(AWS_HOBO(qq).time_30min,AWS_HOBO(qq).WS_2_30min)
legend('WS 1','WS 2')
ylim([0 12])
set(gca,'xtick',xticks)
datetick('x','keepticks')

subplot(2,3,3)
hold on
plot(AWS_HOBO(qq).time_30min,AWS_HOBO(qq).T_1_30min)
plot(AWS_HOBO(qq).time_30min,AWS_HOBO(qq).T_2_30min)
legend('T 1','T 2')
ylim([-30 0])
set(gca,'xtick',xticks)
datetick('x','keepticks')

subplot(2,3,4)
hold on
plot(AWS_HOBO(qq).time_30min,AWS_HOBO(qq).RH_1_30min)
plot(AWS_HOBO(qq).time_30min,AWS_HOBO(qq).RH_2_30min)
legend('RH 1','RH 2')
ylim([40 100])
set(gca,'xtick',xticks)
datetick('x','keepticks')

subplot(2,3,5)
hold on
plot(AWS_HOBO(qq).time_30min,AWS_HOBO(qq).Q_1_30min)
plot(AWS_HOBO(qq).time_30min,AWS_HOBO(qq).Q_2_30min)
legend('Q 1','Q 2')
ylim([0 2])
set(gca,'xtick',xticks)
datetick('x','keepticks')

subplot(2,3,6)
hold on
plot(AWS_HOBO(qq).time_30min,AWS_HOBO(qq).TP_1_30min)
plot(AWS_HOBO(qq).time_30min,AWS_HOBO(qq).TP_2_30min)
legend('\theta 1','\theta 2')
ylim([-30 0])
set(gca,'xtick',xticks)
datetick('x','keepticks')


set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',9,'FontWeight','Bold', 'LineWidth', 1,'layer','top','box','on');
set(gcf,'position',[100 100 1500 600])

