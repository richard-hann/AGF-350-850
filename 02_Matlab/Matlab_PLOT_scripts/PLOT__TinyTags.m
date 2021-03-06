
%% ===== USE THIS FOR PLOTTING SINGEL TINY TAGS TYPE TT IN A FIGURE =====


%% select the tiny tags that you want to read in 
ttnames = {'TT17'};
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

    % SELECT TEMPERATURE LIMITS
    ylim([-30 25])

    set(gca,'xtick',xticks)
    datetick('x','dd','keeplimits','keepticks')
end

set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',9,'FontWeight','Bold','LineWidth',1,'layer','top','box','on');
set(gcf,'position',[100 100 1500 600])




%% ===== USE THIS FOR PLOTTING SINGEL TINY TAGS TYPE CEB IN A FIGURE =====
%% select the tiny tags that you want to read in 
ttnames = {'CEB1'};

close all
clc

for i = 1:length(ttnames)
    figure(i)

    xticks = TinyTag(1).(char(ttnames{i})).time(1):1:TinyTag(1).(char(ttnames{i})).time(end); 
    hold on
    plot(TinyTag(1).(char(ttnames{i})).time,TinyTag(1).(char(ttnames{i})).T)
    legend('T')

    % SELECT TEMPERATURE LIMITS
    ylim([-30 25])

    set(gca,'xtick',xticks)
    datetick('x','dd','keeplimits','keepticks')
end

set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',9,'FontWeight','Bold','LineWidth',1,'layer','top','box','on');
set(gcf,'position',[100 100 1500 600])



%% ===== USE THIS FOR PLOTTING SINGEL TINY TAGS TYPE TH IN A FIGURE =====
%% select the tiny tags that you want to read in 
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

    % SELECT TEMPERATURE LIMITS
    ylim([-30 25])

%     set(gca,'xtick',xticks)
    datetick('x','dd','keeplimits')
    
    subplot(1,2,2)
%     xticks = TinyTag(1).(char(ttnames{i})).time(1):1:TinyTag(1).(char(ttnames{i})).time(end); 
    hold on
    plot(TinyTag(1).(char(ttnames{i})).time,TinyTag(1).(char(ttnames{i})).RH)
    legend('RH')
    ylim([0 100])
%     set(gca,'xtick',xticks)
    datetick('x','dd','keeplimits')
end

set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',9,'FontWeight','Bold','LineWidth',1,'layer','top','box','on');
set(gcf,'position',[100 100 1500 600])



%% ===== USE THIS FOR PLOTTING MULTIPLE TINY TAGS TYPE TT IN A FIGURE =====

%% select the tiny tags that you want to read in 
% % ttnames = {'TT2','TT7','TT9','TT5','TT4','TT8','TT11','TT10','TT6','TT12'};
ttnames = {'TT2','TT12'};

close all
clc

% xticks = datenum([2021 09 08 00 00 00]):1:datenum([2021 09 12 00 00 00]); 

for i = 1:length(ttnames)
%     figure(i)

    
    hold on
%     plot(TinyTag(1).(char(ttnames{i})).time,TinyTag(1).(char(ttnames{i})).T_black)
    plot(TinyTag(1).(char(ttnames{i})).time,TinyTag(1).(char(ttnames{i})).T_white)
%     legend('T 1','T 2')

      % SELECT LIMITS
      ylim([-25 20])

%     set(gca,'xtick',xticks)
    datetick('x','dd','keeplimits')
    
    legend(ttnames)
end

set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',9,'FontWeight','Bold', 'LineWidth', 1,'layer','top','box','on');
set(gcf,'position',[100 100 1500 600])








%%

% ttnames = {'TT2','TT12','TT4','TT7','TT8','TT3','TT13'};
ttnames = {'TT2','TT3','TT13'};

close all
clc

% xticks = datenum([2021 09 08 00 00 00]):1:datenum([2021 09 12 00 00 00]); 

% for i = 1:length(ttnames)
%     figure(i)

    
    hold on
%     plot(TinyTag(1).(char(ttnames{i})).time,TinyTag(1).(char(ttnames{i})).T_black)
    plot(TinyTag(1).TT2.time,TinyTag(1).TT2.T_black)
%     plot(TinyTag(1).TT12.time,TinyTag(1).TT12.T_white)
%     plot(TinyTag(1).TT4.time,TinyTag(1).TT4.T_black)
%     plot(TinyTag(1).TT7.time,TinyTag(1).TT7.T_black)
%     plot(TinyTag(1).TT8.time,TinyTag(1).TT8.T_black)
    
        plot(TinyTag(1).TT3.time,TinyTag(1).TT3.T_black)
        plot(TinyTag(1).TT13.time,TinyTag(1).TT13.T_black)
    
    
%     legend('T 1','T 2')

      % SELECT LIMITS
      ylim([-25 20])

%     set(gca,'xtick',xticks)
    datetick('x','dd','keeplimits')
    
    legend(ttnames)
% end

set(findobj(gcf,'type','axes'),'FontName','Calibri','FontSize',9,'FontWeight','Bold', 'LineWidth', 1,'layer','top','box','on');
set(gcf,'position',[100 100 1500 600])







