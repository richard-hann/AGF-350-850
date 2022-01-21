
function [coords_xx,coords_yy,lon_closest,lat_closest] = lonlat2xy_Arome_Arctic_points(lon,lat,lons,lats)

latt2 = lats;
lonn2 = lons;

latt1 = lat;
lonn1 = lon;

radius = 6371;
lat1 = latt1*pi/180;
lat2 = latt2*pi/180;
lon1 = lonn1*pi/180;
lon2 = lonn2*pi/180;
deltaLat = lat2-lat1;
deltaLon = lon2-lon1;
a = sin((deltaLat)./2).^2 + cos(lat1).*cos(lat2) .* sin(deltaLon./2).^2;
c = 2*atan2(sqrt(a),sqrt(1-a));
d1km = radius*c;    %Haversine distance

x = deltaLon.*cos((lat1+lat2)./2);
y = deltaLat;
d2km = radius.*sqrt(x.*x + y.*y);

[a b] = min(d2km(:));

    lon_closest = lons(b);
    lat_closest = lats(b);    
    
    [xx yy] = ind2sub(size(lons),b); % x and y indices for closest model grid point to each station
    
        coords_xx = xx;
        coords_yy = yy;




