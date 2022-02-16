
% run the following script to read in data from the Campbell AWS
%   READIN__AWS_Campbell
%% INPUT: Set the CB ID (qq) to choose which Campbell station you want to plot data from
qq = 1; 


% xticks = AWS_CB(qq).Time_30min(1):2:AWS_CB(qq).Time_30min(end);

clc
       


id1 = datenum([2022 02 07 00 00 00]);
id2 = datenum([2022 02 14 00 00 00]);
idd = find(AWS_CB(qq).Time_30min >= id1 & AWS_CB(qq).Time_30min <= id2);


close all

subplot(2,2,1)
hold on
plot(AWS_CB(qq).Time_30min(idd),AWS_CB(qq).WD1_30min(idd))
plot(AWS_CB(qq).Time_30min(idd),AWS_CB(qq).WD2_30min(idd))
legend('WD 1','WD 2')
ylim([0 360])
set(gca,'ytick',[0:45:360])
datetick('x','dd','keeplimits')

subplot(2,2,2)
hold on
plot(AWS_CB(qq).Time_30min(idd),AWS_CB(qq).WS1_30min(idd))
plot(AWS_CB(qq).Time_30min(idd),AWS_CB(qq).WS2_30min(idd))
legend('WS 1','WS 2')
ylim([0 15])
datetick('x','dd','keeplimits')

subplot(2,2,3)
hold on
plot(AWS_CB(qq).Time_30min(idd),AWS_CB(qq).T1_30min(idd))
plot(AWS_CB(qq).Time_30min(idd),AWS_CB(qq).T2_30min(idd))
legend('T 1','T 2')
ylim([-25 0])
datetick('x','dd','keeplimits')


subplot(2,2,4)
hold on
plot(AWS_CB(qq).Time_30min(idd),AWS_CB(qq).RH1_30min(idd))
plot(AWS_CB(qq).Time_30min(idd),AWS_CB(qq).RH2_30min(idd))
legend('RH 1','RH 2')
ylim([40 100])
datetick('x','dd','keeplimits')


set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',9,'FontWeight','Bold', 'LineWidth', 1,'layer','top','box','on');
arrayfun(@(x) grid(x,'on'), findobj(gcf,'Type','axes'))
set(gcf,'position',[100 100 1500 600])







