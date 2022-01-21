% SCRIPT FOR MAKING VERTICAL CROSS SECTIONS BASED ON THE AROME ARCTIC DATA

i = 1;

start = [start_lonlat(1) start_lonlat(2) 1 1]; count = [count_lonlat(1) count_lonlat(2) inf num_h]; stride = [1 1 1 int_h]; 

filename = fileurls{i};


% Extracting variables
for i = 1:length(varnames)
    AROME(1).(fldnames{i}) = double(ncread(filename,varnames{i},start,count,stride));
    disp(['Done reading variable   ' fldnames{i} '   from file ' filename ' on thredds server'])
end

if isfield(AROME,'ur') && isfield(AROME,'vr')
% Wind u and v components in the original data are grid-related. 
    % Therefore, we rotate here the wind components from grid- to earth-related coordinates.
    [AROME(1).u,AROME(1).v] = Rotate_uv_components_Arome_Arctic(AROME(1).ur,AROME(1).vr,1:size(AROME(1).LON,1),1:size(AROME(1).LON,2),AROME(1).LON);

% Calculating wind direction
    AROME(1).WD = mod(atan2d(-AROME(1).u,-AROME(1).v)+360,360);

% Calculating wind speed
    AROME(1).WS = sqrt((AROME(1).ur.^2)+(AROME(1).vr.^2));
end

% Calculating height levels and pressure
    hybrid = ncread(filename,'hybrid'); 
    ap = ncread(filename,'ap');
    b = ncread(filename,'b');
    [AROME(1).height,AROME(1).P] = Calculate_height_levels_Arome_Arctic_3D(hybrid,ap,b,AROME(1).t0,AROME(1).PSFC,AROME(1).T);

% Converting specific humidity from kg/kg to g/kg 
    AROME(1).Q = AROME(1).Q.*1000; 
    
% Calculating potential temperature
    AROME(1).TP = (AROME(1).T).*(1000./(AROME(1).P./100)).^.287;

% Converting pressure from Pa to hPa
    AROME(1).P = AROME(1).P./100;
    
% Converting temperature from Kelvin to Celcius    
    AROME(1).T  = AROME(1).T  - 273.15;
    AROME(1).TP = AROME(1).TP - 273.15;
    
    
% % Calculating distance between end and start points
% % using that (d2km) to find out how many points to use for the
% % interpolation
    
    latlon1=startpoint(2:-1:1);
    latlon2=endpoint(2:-1:1);
  
    radius=6371;
    lat1=latlon1(1)*pi/180;
    lat2=latlon2(1)*pi/180;
    lon1=latlon1(2)*pi/180;
    lon2=latlon2(2)*pi/180;
    deltaLat=lat2-lat1;
    deltaLon=lon2-lon1;
    a=sin((deltaLat)/2)^2 + cos(lat1)*cos(lat2) * sin(deltaLon/2)^2;
    c=2*atan2(sqrt(a),sqrt(1-a));
    d1km=radius*c;    %Haversine distance

    x=deltaLon*cos((lat1+lat2)/2);
    y=deltaLat;
    d2km=radius*sqrt(x*x + y*y); %Pythagoran distance
    
    
    if select_resolution == 1
        dd = d2km/2.5;
    elseif select_resolution == 2
        dd = d2km/0.5;
    end

    lons = linspace(startpoint(1),endpoint(1),dd);
    lats = linspace(startpoint(2),endpoint(2),dd);
     
%     % Interpolating the surface height on to the cross section
        hgs     = scatteredInterpolant(AROME(1).LON(:), AROME(1).LAT(:), AROME(1).HGT(:),'linear','none');
        hgss    = hgs(lons, lats)';

      % Interpolating the atmospheric data on to the cross section 
    clear oz ti wsi qi tpi
    zz = 1;
% %     for i=40:65 % looping from level 40 to level 65 (this is skipping the uppermost level). Change from 20 to a lower number to include higher levels

k = size(squeeze(AROME(1).T),3);
nlevels  = 20; % number of vertical levels to retrieve
for i = k:-1:(k-20)
     
        ht = squeeze(AROME(1).height(:,:,i));
        tt = squeeze(AROME(1).T(:,:,i));
        tp = squeeze(AROME(1).TP(:,:,i));
        ws = squeeze(AROME(1).WS(:,:,i));
        q = squeeze(AROME(1).Q(:,:,i));
         
        s = scatteredInterpolant(AROME(1).LON(:), AROME(1).LAT(:), ht(:));
            oz(zz,:) = s(lons, lats);
        
        s2 = scatteredInterpolant(AROME(1).LON(:), AROME(1).LAT(:), ht(:), tt(:));
            ti(zz,:) = s2(lons, lats, oz(zz,:));
        s2 = scatteredInterpolant(AROME(1).LON(:), AROME(1).LAT(:), ht(:), tp(:));
            tpi(zz,:) = s2(lons, lats, oz(zz,:));
        s2 = scatteredInterpolant(AROME(1).LON(:), AROME(1).LAT(:), ht(:), ws(:));
            wsi(zz,:) = s2(lons, lats, oz(zz,:));
        s2 = scatteredInterpolant(AROME(1).LON(:), AROME(1).LAT(:), ht(:), q(:));
            qi(zz,:) = s2(lons, lats, oz(zz,:)); 
        
        zz = zz+1;
        
end

  hg = repmat(hgss,1,size(oz,1))';  
  oz = oz+hg;
   x = linspace(lons(1),lons(end),size(oz,2))';
  xx = repmat(x,1,size(oz,1))';
    
  
AROME(1).ti  = ti;
AROME(1).tpi = ti;
AROME(1).wsi = wsi;
AROME(1).qi  = qi;

AROME(1).oz  = oz;
AROME(1).xx  = xx;


    
    