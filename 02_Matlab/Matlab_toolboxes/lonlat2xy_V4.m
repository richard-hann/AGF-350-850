% ----------------- Finding closest grid points to observations (lon,lat -> x,y) -------------------
function [coords_xx,coords_yy,check_lon,check_lat] = lonlat2xy_V4(obslon,obslat,datalon,datalat)
   
lonn1=obslon;
latt1=obslat;

lonn2 = datalon;
latt2 = datalat;

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

[a,b]=min(d2km(:));

    [coords_xx,coords_yy]=ind2sub(size(lonn2),b);
    
    check_lon = lonn2(coords_xx,coords_yy);
    check_lat = latt2(coords_xx,coords_yy);
       
    
% -------------- DONE FINDING CLOSEST GRID POINTS --------------------------