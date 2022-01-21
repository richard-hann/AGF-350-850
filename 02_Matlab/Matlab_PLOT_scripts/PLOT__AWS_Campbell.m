
% run the following script to read in data from the Campbell AWS
%   READIN__AWS_Campbell
%% INPUT: Set the CB ID (qq) to choose which Campbell station you want to plot data from
qq = 1; 


xticks = AWS_CB(qq).Time_30min(1):5:AWS_CB(qq).Time_30min(end);

clc
       

close all

subplot(2,2,1)
hold on
plot(AWS_CB(qq).Time_30min,AWS_CB(qq).WD1_30min)
plot(AWS_CB(qq).Time_30min,AWS_CB(qq).WD2_30min)
legend('WD 1','WD 2')
ylim([0 360])
set(gca,'ytick',[0:45:360])
set(gca,'xtick',xticks)
datetick('x')

subplot(2,2,2)
hold on
plot(AWS_CB(qq).Time_30min,AWS_CB(qq).WS1_30min)
plot(AWS_CB(qq).Time_30min,AWS_CB(qq).WS2_30min)
legend('WS 1','WS 2')
ylim([0 15])
set(gca,'xtick',xticks)
datetick('x')

subplot(2,2,3)
hold on
plot(AWS_CB(qq).Time_30min,AWS_CB(qq).T1_30min)
plot(AWS_CB(qq).Time_30min,AWS_CB(qq).T2_30min)
legend('T 1','T 2')
ylim([-5 10])
set(gca,'xtick',xticks)
datetick('x')

subplot(2,2,4)
hold on
plot(AWS_CB(qq).Time_30min,AWS_CB(qq).RH1_30min)
plot(AWS_CB(qq).Time_30min,AWS_CB(qq).RH2_30min)
legend('RH 1','RH 2')
ylim([40 100])
set(gca,'xtick',xticks)
datetick('x')


set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',9,'FontWeight','Bold', 'LineWidth', 1,'layer','top','box','on');
arrayfun(@(x) grid(x,'on'), findobj(gcf,'Type','axes'))
set(gcf,'position',[100 100 1500 600])







