

ttnames = {'TT1'};
% ttnames = {'TT2','TT11','TT11'};

close all
clc

for i = 1:length(ttnames)
    figure(i)

    xticks = TinyTag(1).(char(ttnames{i})).time(1):1:TinyTag(1).(char(ttnames{i})).time(end); 
    hold on
    plot(TinyTag(1).(char(ttnames{i})).time,TinyTag(1).(char(ttnames{i})).T_black)
    plot(TinyTag(1).(char(ttnames{i})).time,TinyTag(1).(char(ttnames{i})).T_white)
    legend('T 1','T 2')
    ylim([-20 20])
    set(gca,'xtick',xticks)
    datetick('x','keepticks')
end

set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',9,'FontWeight','Bold','LineWidth',1,'layer','top','box','on');
set(gcf,'position',[100 100 1500 600])




%%

ttnames = {'CEB1'};

close all
clc

for i = 1:length(ttnames)
    figure(i)

    xticks = TinyTag(1).(char(ttnames{i})).time(1):1:TinyTag(1).(char(ttnames{i})).time(end); 
    hold on
    plot(TinyTag(1).(char(ttnames{i})).time,TinyTag(1).(char(ttnames{i})).T)
    legend('T')
    ylim([-20 20])
    set(gca,'xtick',xticks)
    datetick('x','keepticks')
end

set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',9,'FontWeight','Bold','LineWidth',1,'layer','top','box','on');
set(gcf,'position',[100 100 1500 600])



%%

ttnames = {'TH1'};

close all
clc

% xticks = datenum([2020 02 09 00 00 00]):1:datenum([2020 02 18 00 00 00]); 

for i = 1:length(ttnames)
    figure(i)
    
    subplot(1,2,1)
%     xticks = TinyTag(1).(char(ttnames{i})).time(1):1:TinyTag(1).(char(ttnames{i})).time(end); 
    hold on
    plot(TinyTag(1).(char(ttnames{i})).time,TinyTag(1).(char(ttnames{i})).T)
    legend('T')
    ylim([-20 20])
%     set(gca,'xtick',xticks)
    datetick('x','keepticks')
    
    subplot(1,2,2)
%     xticks = TinyTag(1).(char(ttnames{i})).time(1):1:TinyTag(1).(char(ttnames{i})).time(end); 
    hold on
    plot(TinyTag(1).(char(ttnames{i})).time,TinyTag(1).(char(ttnames{i})).RH)
    legend('RH')
    ylim([0 100])
%     set(gca,'xtick',xticks)
    datetick('x','keepticks')
end

set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',9,'FontWeight','Bold','LineWidth',1,'layer','top','box','on');
set(gcf,'position',[100 100 1500 600])



%% PLOTTING MULTIPLE TTs

% % ttnames = {'TT2','TT7','TT9','TT5','TT4','TT8','TT11','TT10','TT6','TT12'};
% ttnames = {'TT2','TT13','TT11'};
% 
% close all
% clc
% 
% % xticks = datenum([2021 09 08 00 00 00]):1:datenum([2021 09 12 00 00 00]); 
% 
% for i = 1:length(ttnames)
% %     figure(i)
% 
%     
%     hold on
%     plot(TinyTag(1).(char(ttnames{i})).time,TinyTag(1).(char(ttnames{i})).T_black)
% %     plot(TinyTag(1).(char(ttnames{i})).time,TinyTag(1).(char(ttnames{i})).T_white)
% %     legend('T 1','T 2')
%     ylim([0 15])
% %     set(gca,'xtick',xticks)
%     datetick('x','keepticks')
%     
%     legend(ttnames)
% end
% 
% set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',9,'FontWeight','Bold', 'LineWidth', 1,'layer','top','box','on');
% set(gcf,'position',[100 100 1500 600])
















