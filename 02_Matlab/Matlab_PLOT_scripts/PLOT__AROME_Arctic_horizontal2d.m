


clc

close all
% Choose time step(s)
ids = 1; 

% Parameter list
varr = {'T2','TP2','WS10','Q2','RH2','PSFC','MSLP','cc','prec','SHF'};
cbartitle = {'\circC','\circC','m s^{-1}','g kg^{-1}','%','hPa','hPa','%','mm','W m^{-2}'};


    clim(1).WS10    = [0 20];
    clim(1).RH2     = [0 100];
    clim(1).Q2      = [0 5];
    clim(1).T2      = [-14 0];
    clim(1).prec    = [0.5 15];
    clim(1).SHF     = [-700 700];
    
    cint(1).WS10    = 1;
    cint(1).RH2     = 5;
    cint(1).Q2      = 0.5;
    cint(1).T2      = 1;
    cint(1).prec    = 0.5;
    cint(1).SHF     = 20;
    
    
% Choose which parameter should be drawn
vid = 3; % parameter number from the list in "varr" above, for plotting

% Draw wind barbs (1) or not (0)
drawwindbarb = 0;

% Draw wind arrows (1) or not (0)
drawwindarrows = 1;



% Manual or automatic color limits for parameter:
% mcolor=1; % manual
% t1=0;
% t2=15;
mcolor = 0; % automatic


% Choose geographical area to be drawn

% FOR SVALBARD WITH SURROUNDING WATERS, 2.5km horizontal grid resolution
% lonlims=[-8, 45];
% latlims=[73, 84];
% windbarbscale=0.9;
% intt=20;
% hgtint=500:500:2000; % terrain height interval

% FOR SVALBARD WITH SURROUNDING WATERS, zoomed in a bit, 2.5km horizontal grid resolution
% lonlims=[0, 37];
% latlims=[75, 82];
% windbarbscale=0.9;
% intt=20; % interval in grid points for how densely the wind arrows should be plotted
% windarrowscaling = 50; % adjust this for changing the scaling (size) of the wind arrows
% hgtint=500:500:2000; % terrain height interval



% % FOR SPITSBERGEN, 2.5km horizontal grid resolution
% lonlims=[8, 28];
% latlims=[76, 81];
% windbarbscale=1;
% intt=15; % interval for wind arrows in lon and lat directions
% hgtint=500:500:2000; % terrain height interval
% windarrowscaling = 50; % adjust this for changing the scaling (size) of the wind arrows

% FOR ISFJORDEN, 2.5km horizontal grid resolution
% lonlims=[12, 19];
% latlims=[77.9, 78.9];
% windbarbscale=0.8;
% windarrowscaling = 250; % adjust this for changing the scaling (size) of the wind arrows
% intt=3; % interval in grid points for how densely the wind arrows should be plotted
% hgtint=200:200:2000; % terrain height interval

% FOR ADVENTDALEN, 2.5km horizontal grid resolution
% lonlims=[15.1 16.2];
% latlims=[78.18 78.4];
% windbarbscale=1;
% windarrowscaling = 300;
% intt=1; % interval for wind arrows in lon and lat directions
% hgtint=50:100:2000; % terrain height interval


% FOR ADVENTDALEN, 500m horizontal grid resolution
% lonlims=[15.1 16.25];
% latlims=[78.15 78.3];
% windbarbscale=0.9;
% intt=2; % interval in grid points for how densely the wind arrows should be plotted
% windarrowscaling = 900; % adjust this for changing the scaling (size) of the wind arrows
% hgtint=200:100:2000; % terrain height interval



% FOR ADVENTDALEN ++, 2.5km horizontal grid resolution
lonlims=[15.0 16.8];
latlims=[78.0 78.5];
windbarbscale=1;
windarrowscaling = 300;
intt=1; % interval for wind arrows in lon and lat directions
hgtint=50:100:2000; % terrain height interval



% Picking out sub area
idlon=find(AROME(1).LON(:) >= lonlims(1) & AROME(1).LON(:) <= lonlims(2));
idlat=find(AROME(1).LAT(:) >= latlims(1) & AROME(1).LAT(:) <= latlims(2));
idboth=intersect(idlon,idlat);
[xx yy]=ind2sub(size(AROME(1).LON),idboth);

xi=min(xx):max(xx);
yi=min(yy):max(yy);

    lons=AROME(1).LON(xi,yi);
    lats=AROME(1).LAT(xi,yi);
    hgt=AROME(1).HGT(xi,yi);
    lsm=AROME(1).LSM(xi,yi);




m_proj('lambert','long',lonlims,'lat',latlims);

for id = ids
    
    
    if vid == 10
        varn = (AROME(1).(varr{vid})(xi,yi,id) - AROME(1).(varr{vid})(xi,yi,id-1)); 
    else
        varn = AROME(1).(varr{vid})(xi,yi,id);
    end
    
    
    
    figure(id)    

        x1 = clim(1).(varr{vid})(1);
        x2 = clim(1).(varr{vid})(2);
        xii = cint(1).(varr{vid});
    
hold on
m_contourf(lons,lats,varn,x1:xii:x2,'LineStyle','none')
caxis([x1 x2])
m_contour(lons,lats,hgt,hgtint,'color',[0.5 0.5 0.5],'Linewidth',2)
m_contour(lons,lats,hgt,hgtint,'color',[0.3 0.3 0.3],'linewidth',1)
m_contour(lons,lats,lsm,[0.1 0.1],'color','k','linewidth',1)

if strcmp(varr{vid},'T2') % Marking 0 isotherm 
    m_contour(lons,lats,varn,[0 0],'color','k','LineStyle','--')
end

sz=size(varn);
    idx=1:intt:sz(1);
    idy=1:intt:sz(2);

if drawwindarrows == 1   
if isfield(AROME,'WS10')
    sz=size(AROME(1).u10);

%         intt = 22; 
        
    idx = 1:intt:sz(1);
    idy = 1:intt:sz(2);
	
        uu = squeeze(AROME(1).u10(idx,idy,id))./windarrowscaling;
        vv = squeeze(AROME(1).v10(idx,idy,id))./windarrowscaling;

    lonss = AROME(1).LON(idx,idy); 
    latss = AROME(1).LAT(idx,idy);
    m_quiver(lonss,latss,uu,vv,0,'color',[0.5 0.5 0.5],'LineWidth',2.8);
    m_quiver(lonss,latss,uu,vv,0,'color',[0.95 0.95 0.95],'LineWidth',1.2);

end
end


% setting colormaps:  
    if strcmp(varr{vid},'WS10')
%         colormap(gca,'parula')
            cmap = colorcet('R2');
            colormap(gca,cmap)
%             cmocean('speed')
    elseif strcmp(varr{vid},'T2')
            cmap = bluewhitered_V3;
            colormap(gca,cmap);
%         cmocean('thermal')
%         colormap(gca,'parula')
%         colormap(gca,bluewhitered_V3(30))
    elseif strcmp(varr{vid},'TP2')
        cmocean('thermal')
    elseif strcmp(varr{vid},'Q2')
        cmocean('haline')
    elseif strcmp(varr{vid},'RH2')
        cmocean('haline')
    elseif strcmp(varr{vid},'PSFC')
        cmocean('solar')
    elseif strcmp(varr{vid},'MSLP')
        cmocean('solar')
    elseif strcmp(varr{vid},'cc')
        RGB=cmocean('deep');
        colormap(gca,RGB(1:end-90,:))
    elseif strcmp(varr{vid},'SHF') 
        cmocean('thermal')
    elseif strcmp(varr{vid},'prec')    
        cmap = cptcmap('precip_11lev.cpt','ncol',length(linspace(t1,t2,15)));
            colormap(gca,cmap(1:end,:))
    end

% m_contfbar(gca,1.05,[0.2,0.8],varn,linspace(t1,t2,20)) 
ax = m_contfbar(gca,1.03,[0.2,0.8],varn,x1:xii:x2,'FontSize',12);
tt = title(ax,cbartitle{vid},'FontSize',14); st = get(tt,'position'); set(tt,'position',[st(1) st(2)*1.1 st(3)]);

title([varr{vid} ' ' datestr(AROME(1).time(id))])


m_grid('tickdir','in');
set(gca,'FontSize',12)

end
% m_grid('box','fancy','tickdir','in');




