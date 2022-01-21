
function [output1,output2,output3,output4] = lonlat2xy_Arome_Arctic(lon,lat,lons,lats,type)

% type = 1: point data
% type = 2: horizontal data

if type == 1 % then point data
 
    % output1 = coords_xx
    % output2 = coords_yy
    % output3 = lon_closest
    % output4 = lat_closest
    
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

    output3 = lons(b);
    output4 = lats(b);    
    
    [xx yy] = ind2sub(size(lons),b); % x and y indices for closest model grid point to each station
    
        output1 = xx;
        output2 = yy;

        
elseif type == 2 % then 2D data
    
    % output1 = start_lonlat
    % output2 = count_lonlat
    % output3 = stride_lonlat
    % output4 = dummy
    
   
    lon1 = lon(1); lon2 = lon(2);
    lat1 = lat(1); lat2 = lat(2);
    
lon_corners  = [lon1 lon2 lon2 lon1];
lat_corners  = [lat1 lat1 lat2 lat2];
    

for qq = 1:length(lon_corners)
    
    latt2 = lats;
    lonn2 = lons;

  clear a b

lonn1 = lon_corners(qq);
latt1 = lat_corners(qq);

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

    [coords_xx(qq) coords_yy(qq)]=ind2sub(size(lons),b);
    
%     AROME_TESTLON(qq)=longitude(coords_xx(qq),coords_yy(qq));
%     AROME_TESTLAT(qq)=latitude(coords_xx(qq),coords_yy(qq));
      
%     AROME_HGT(qq)=hgt(coords_xx(qq),coords_yy(qq));
end

    lonmin_id = min(coords_xx);
        lonmax_id = max(coords_xx);
    latmin_id = min(coords_yy);
        latmax_id = max(coords_yy);
         
%          start_lonlat = [lonmin_id latmin_id]; count_lonlat = [abs(lonmax_id-lonmin_id) abs(latmax_id-latmin_id)]; stride_lonlat=[1 1];
         output1 = [lonmin_id latmin_id]; output2 = [abs(lonmax_id-lonmin_id) abs(latmax_id-latmin_id)]; output3 = [1 1];
         output4 = nan;
      
end
    


