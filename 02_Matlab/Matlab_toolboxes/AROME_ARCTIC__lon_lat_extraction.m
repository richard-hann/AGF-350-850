    

hgt = AROME(1).HGT;

if exist('lonlims') && exist('latlims')

lon1=lonlims(1); lon2=lonlims(2);
    lat1=latlims(1); lat2=latlims(2);
    
lons=[lon1 lon2 lon2 lon1];
lats=[lat1 lat1 lat2 lat2];
    

for qq=1:length(lons)
    latt2=latitude;
    lonn2=longitude;

  clear a b

lonn1=lons(qq);
latt1=lats(qq);

radius=6371;
lat1=latt1*pi/180;
lat2=latt2*pi/180;
lon1=lonn1*pi/180;
lon2=lonn2*pi/180;
deltaLat=lat2-lat1;
deltaLon=lon2-lon1;
a=sin((deltaLat)./2).^2 + cos(lat1).*cos(lat2) .* sin(deltaLon./2).^2;
c=2*atan2(sqrt(a),sqrt(1-a));
d1km=radius*c; % Haversine distance

x=deltaLon.*cos((lat1+lat2)./2);
y=deltaLat;
d2km=radius.*sqrt(x.*x + y.*y);

[a b]=min(d2km(:));

    [coords_xx(qq) coords_yy(qq)]=ind2sub(size(longitude),b);
    
    AROME_TESTLON(qq)=longitude(coords_xx(qq),coords_yy(qq));
    AROME_TESTLAT(qq)=latitude(coords_xx(qq),coords_yy(qq));
      
%     AROME_HGT(qq)=hgt(coords_xx(qq),coords_yy(qq));
end

    lonmin_id=min(coords_xx);
        lonmax_id=max(coords_xx);
    latmin_id=min(coords_yy);
        latmax_id=max(coords_yy);

        
%          start_lonlat=[lonmin_id-1 latmin_id-1]; count_lonlat=[abs(lonmax_id-lonmin_id)+1 abs(latmax_id-latmin_id)+1]; stride_lonlat=[1 1];
         
         
         start_lonlat=[lonmin_id latmin_id]; count_lonlat=[abs(lonmax_id-lonmin_id) abs(latmax_id-latmin_id)]; stride_lonlat=[1 1];
         
end



if exist('STT') % THEN STATION DATA
    
   

for qq=1:length(STT)
    clear a b 
    
    lons=STT(qq).lon; % station lon
    lats=STT(qq).lat; % station lat
    
    latt2=latitude; % model grid latitude
    lonn2=longitude; % model grid longitude

  

lonn1=lons;
latt1=lats;

radius=6371;
lat1=latt1*pi/180;
lat2=latt2*pi/180;
lon1=lonn1*pi/180;
lon2=lonn2*pi/180;
deltaLat=lat2-lat1;
deltaLon=lon2-lon1;
a=sin((deltaLat)./2).^2 + cos(lat1).*cos(lat2) .* sin(deltaLon./2).^2;
c=2*atan2(sqrt(a),sqrt(1-a));
d1km=radius*c; % Haversine distance

x=deltaLon.*cos((lat1+lat2)./2);
y=deltaLat;
d2km=radius.*sqrt(x.*x + y.*y);

[a b]=min(d2km(:));

    [coords_xx(qq) coords_yy(qq)]=ind2sub(size(longitude),b);
    
    AROME_TESTLON(qq)=longitude(coords_xx(qq),coords_yy(qq));
    AROME_TESTLAT(qq)=latitude(coords_xx(qq),coords_yy(qq));
      
    AROME_HGT(qq)=hgt(coords_xx(qq),coords_yy(qq));
    
%     lonmin_id=min(coords_xx);
%     latmin_id=min(coords_yy);

%          start(qq).nn=[lonmin_id latmin_id]; % count_lonlat=[abs(lonmax_id-lonmin_id) abs(latmax_id-latmin_id)]; stride_lonlat=[1 1];
         start(qq).nn=[coords_xx(qq) coords_yy(qq)]; % count_lonlat=[abs(lonmax_id-lonmin_id) abs(latmax_id-latmin_id)]; stride_lonlat=[1 1];

end

   
         
end
    
    
    
    
    
    

         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         