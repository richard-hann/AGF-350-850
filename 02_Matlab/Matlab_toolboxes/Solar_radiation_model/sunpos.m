% calculates the position of the sun 
% as function of date and time [UTC] and
% geographical coordinates [decimal degrees]
% lat S negative; lon E negative
function[el,az,dist]=sunpos(d,m,y,hh,mm,ss,lat,lon);

giventimeA = ((ss / 60.0 + mm) / 60.0 + hh) / 24.0;
hour = 24.0 * giventimeA;

% Calculate Julian Day
if (m <= 2)
	y = y - 1;
	m = m + 12;
 end % if    
a = 365.0*y - 679004.0;
b = floor(y/400.0) - floor(y/100) + floor(y/4);
mod_jul_day = a + b + floor(30.6001*(m+1)) + d + hour/24.0;
% jul_day_a = mod_jul_day + 2400000.5;
% 2400000.5 is JD of 17.11.1858 00 UTC,
% days in centuries
cen_day = (mod_jul_day - 51544.5)/36525;
% hours in centuries
delta_t = 64.184/(3600*24);
cen_hour = ((hour/24.0 + delta_t)/36525);
% Julian Time since year 2000
Jul_time = cen_hour + cen_day;
		
% Calculating Declination and Rectascension of the Sun
		
m1 =0.993133 + 99.997361*Jul_time;
m2 = m1 - floor(m1);
if (m2 < 0)
  m2 = m2 + 1;
end %if 
mx = 2*pi*m2;
DL = 6893.0*sin(mx) + 72.0*sin(2*mx);
len1 = 0.7859453 + m2 + (6191.2*Jul_time + DL)/(1296000);
len2 = len1 - floor(len1);
if (len2 < 0)
  len2 = len2 + 1;
end %if 
L = 2*pi*len2;
SinL = sin(L);
X = cos(L);
Y = 0.91748*SinL;
Z = 0.39778*SinL;
RHO = sqrt(1.0 - Z*Z);
DEC = atan(Z/RHO);
Rect = (48.0/(2*pi))*atan(Y/(X+RHO));
if (Rect < 0)
   Rect = Rect + 24.0;
end %if		

% Calculating local siderial time
		
mod_jul_0day = floor(mod_jul_day);
time_fac = (mod_jul_day - mod_jul_0day)*24.0 ;
time_0fac = cen_day;
GMST = 6.697374558 + 1.0027379093*time_fac + (8640184.812866 + (0.093104 - 0.0000062*time_0fac)*time_0fac)*time_0fac/3600.0;
LMST = (GMST - lon/15.0)/24.0;
LMST = LMST - floor(LMST);
if (LMST < 0)
  LMST = LMST + 1;
end%if  
LMST_S = LMST*24;
		
% Calculation of the Hour-Angle
		
hour_Angle = (LMST_S - Rect)*2*pi/24.0;
		
% Calculating Horizontal Coordinates
		
sin_p = sin(lat*pi/180.0);
cos_p = cos(lat*pi/180.0);
		
X = cos(DEC)*cos(hour_Angle)*sin_p - sin(DEC)*cos_p;
Y = cos(DEC)*sin(hour_Angle);
Z = cos(DEC)*cos(hour_Angle)*cos_p + sin(DEC)*sin_p;
		
azimuth_sunA = atan(Y/X)*180/pi;
if ((X>0) & (Y<0)) 
    azimuth_sunA = azimuth_sunA + 180;
end %if    
if ((X>0) & (Y>0))
    azimuth_sunA = azimuth_sunA - 180;
end %if    
if (azimuth_sunA < 0)
    azimuth_sunA = azimuth_sunA + 360;
end %if    
		
rhos = sqrt(X*X + Y*Y);
elevat_sunA = atan(Z/rhos)*180/pi;
j = 2 * pi * (d + m * 30) / 365;
az = azimuth_sunA;
el = elevat_sunA;
dist = 1.00011 + 0.034221 * cos(j) + 0.000719 * cos(2 * j) + 0.001280 * sin(j) + 0.000077 * sin(2 * j);
