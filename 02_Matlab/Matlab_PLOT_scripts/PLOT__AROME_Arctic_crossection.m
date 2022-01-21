
 close all
    % plotting vertical cross section
    figure(4)
    hold on
%     tp1=min(ti(:));
%     tp2=max(ti(:));
    
    
    tp1 = -20;
    tp2 =   -5;
    
%     tpp1=min(tpi(:));
%     tpp2=max(tpi(:));
    
    
    contourf(AROME(1).xx,AROME(1).oz,AROME(1).ti,[tp1:0.5:tp2],'LineStyle','none')
    
%     contour(xx,oz,ti,[273 273],'k','LineWidth',2)
    
%     [C,h]=contour(xx,oz,tpi,[round(tpp1):2:round(tpp2)],'ShowText','on','color','w');
%         [C,h]=contour(xx,oz,tpi,[round(tpp1):3:round(tpp2)],'color','w');
%     clabel(C,h,'LabelSpacing',80,'Color','w','FontWeight','bold')

    colorbar
    caxis([tp1 tp2])
    
%     xlim([0 dd])
    
    
%     dd2=[0:2.5:round(dd/2.5)*2.5];
%     set(gca,'xtick',dd2)
    
%     legend('Wind speed (m/s)')
    
%     xlabel('Distance (km)')
    
    ylabel('Height (m ASL)')
    
    colormap(gca,'parula')
